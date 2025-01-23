import '/import.dart';
import 'display_subjects.dart';
import 'display_groups.dart';
import 'user_profile_screen.dart';
import 'dart:async';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> 
    with SingleTickerProviderStateMixin {
  String _selectedCategory = 'ユーザー';
  String _searchQuery = '';
  List<dynamic> _searchResults = [];
  List<String> _subjectList = [];
  final List<Map<String, String>> _groupList = []; // グループ一覧
  List<String> _cachedSubjectList = []; // 教科のキャッシュ
  bool _isLoading = false;

  // ユーザープロファイルを表示する場合のフラグとユーザーID
  bool _isUserProfileVisible = false;
  String _selectedUserId = '';

  // SubjectDetailsScreen を表示する場合のフラグと教科名
  bool _isSubjectDetailsVisible = false;
  String? _selectedSubjectName;

  Timer? _debounce;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    _fetchSubjects().then((_) {
      if (_selectedCategory == '教科' && _searchQuery.isEmpty) {
        _performSearch(); // 初期表示のため実行
      }
    });

    _tabController.addListener(_onTabChanged);
    // 現在選択されているタブを設定
    _selectedCategory = ['投稿', 'ユーザー', 'グループ', '教科', 'タグ'][_tabController.index];
    if (_searchQuery.isNotEmpty) {
      _performSearch();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  final Map<String, List<dynamic>> _tabResults = {
    '投稿': [],
    'ユーザー': [],
    'グループ': [],
    '教科': [],
    'タグ': [],
  };

  void _onTabChanged() {
    if (mounted) {
      setState(() {
        _selectedCategory = ['投稿', 'ユーザー', 'グループ', '教科', 'タグ'][_tabController.index];
        if (_selectedCategory == '教科' && _searchQuery.isEmpty) {
          _searchResults = List.from(_cachedSubjectList); // キャッシュを使用
        } else {
          _searchResults = []; // 他のカテゴリはリセット
        }
        _isLoading = false;  // ローディング状態をリセット

        // タブ移動したら、他の画面表示は閉じる
        if (_isUserProfileVisible) {
          _hideUserProfile();
        }
        if (_isSubjectDetailsVisible) {
          _hideSubjectDetails();
        }
      });

      // タブ変更時に検索を実行
      if (_searchQuery.isNotEmpty) {
        _performSearch();
      }
    }
  }

  void _showUserProfile(String userId) {
    setState(() {
      _isUserProfileVisible = true;
      _selectedUserId = userId;

      // 他の画面を閉じる
      if (_isSubjectDetailsVisible) {
        _hideSubjectDetails();
      }
    });
  }

  void _hideUserProfile() {
    setState(() {
      _isUserProfileVisible = false;
      _selectedUserId = '';
    });
  }

  // SubjectDetailsScreen 表示/非表示
  void _showSubjectDetails(String subjectName) {
    setState(() {
      _isSubjectDetailsVisible = true;
      _selectedSubjectName = subjectName;

      // 他の画面を閉じる
      if (_isUserProfileVisible) {
        _hideUserProfile();
      }
    });
  }

  void _hideSubjectDetails() {
    setState(() {
      _isSubjectDetailsVisible = false;
      _selectedSubjectName = null;
    });
  }

  Future<void> _fetchSubjects() async {
    try {
      final subjectsSnapshot =
          await FirebaseFirestore.instance.collection('subjects').get();
      final subjects = subjectsSnapshot.docs.map((doc) => doc.id).toList();

      setState(() {
        _subjectList = subjectsSnapshot.docs.map((doc) => doc.id).toList();
        _cachedSubjectList = List.from(subjects);
      });
    } catch (e) {
      print('教科一覧の取得エラー: $e');
    }
  }

  Future<void> _performSearch() async {
    if (_searchQuery.isEmpty) {
      setState(() {
      _searchResults = [];
    });
    return; // 空の検索ワードの場合は何も表示しない
  }

    try {
      final normalizedQuery = _normalizeString(_searchQuery);

      if (_selectedCategory == 'ユーザー') {
        final querySnapshot =
            await FirebaseFirestore.instance.collection('Users').get();
        final filteredResults = querySnapshot.docs
            .where((doc) {
              final data = doc.data();
              final userName = data['user_name']?.toString() ?? '';
              final userId = data['user_id']?.toString() ?? '';
              return _calculateMatchScore(normalizedQuery, userName, userId) > 0;
            })
            .map((doc) => doc.data())
            .toList();

        setState(() {
          _searchResults = filteredResults;
        });
      } else if (_selectedCategory == '投稿') {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('Timeline')
            .where('description', isGreaterThanOrEqualTo: normalizedQuery)
            .where('description', isLessThan: '$normalizedQuery\uf8ff')
            .orderBy('createdAt', descending: true)
            .get();

        final authUids = querySnapshot.docs
            .map((doc) => doc.data()['auth_uid'] as String?)
            .where((uid) => uid != null)
            .toSet();

        if (authUids.isNotEmpty) {
          final userQuerySnapshot = await FirebaseFirestore.instance
              .collection('Users')
              .where('auth_uid', whereIn: authUids.toList())
              .get();

          final userMap = {
            for (var doc in userQuerySnapshot.docs)
              doc.data()['auth_uid']: doc.data()
          };

          final results = querySnapshot.docs.map((postDoc) {
            final postData = postDoc.data();
            final userData = userMap[postData['auth_uid']];

            return {
              'post_id': postDoc.id,
              'description': postData['description'] ?? '',
              'auth_uid': postData['auth_uid'] ?? '',
              'user_name': userData?['user_name'] ?? 'Unknown',
              'user_id': userData?['user_id'] ?? 'ID Unknown',
              'createdAt': postData['createdAt'],
              'like_count': postData['like_count'] ?? 0,
            };
          }).toList();

          setState(() {
            _tabResults[_selectedCategory] = results;
            _searchResults = results;
          });
        }
      } else if (_selectedCategory == '教科') {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('subjects')
            .where(FieldPath.documentId, isGreaterThanOrEqualTo: _searchQuery)
            .where(FieldPath.documentId, isLessThan: '$_searchQuery\uf8ff')
            .get();

        setState(() {
          if (querySnapshot.docs.isNotEmpty) {
            _searchResults = querySnapshot.docs.map((doc) => doc.id).toList();
          } else {
            _searchResults = [];
          }
        });
      } else if (_selectedCategory == 'グループ') {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('Groups')
            .where('groupName', isEqualTo: _searchQuery)
            .get();

        setState(() {
          _searchResults = querySnapshot.docs.map((doc) => doc.data()).toList();
        });
      } else if (_selectedCategory == 'タグ') {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('Tags')
            .where('tagName', isEqualTo: _searchQuery)
            .get();

        setState(() {
          _searchResults = querySnapshot.docs.map((doc) => doc.data()).toList();
        });
      }
    } catch (e) {
      print('検索エラー: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _normalizeString(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll('あ', 'a')
        .replaceAll('い', 'i');
  }

  String _timeAgo(Timestamp timestamp) {
    final now = DateTime.now();
    final dateTime = timestamp.toDate();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}秒前';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}時間前';
    } else {
      return '${difference.inDays}日前';
    }
  }

  int _calculateMatchScore(String query, String target1, String target2) {
    int score = 0;
    final normalizedTarget1 = _normalizeString(target1);
    final normalizedTarget2 = _normalizeString(target2);

    if (normalizedTarget1 == query) score += 100;
    if (normalizedTarget1.contains(query)) score += 50;
    if (normalizedTarget2 == query) score += 80;
    if (normalizedTarget2.contains(query)) score += 40;

    return score;
  }

  Widget _buildSearchResultsOrSubjects() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0ABAB5)),
        ),
      );
    }

    if (_searchQuery.isNotEmpty && _searchResults.isEmpty) {
      return const Center(child: Text('結果が見つかりませんでした。'));
    }

    // 教科タブで検索クエリが空 → 教科一覧
    if (_selectedCategory == '教科' && _searchResults.isEmpty) {
      return _buildSubjectListView(_subjectList);
    }

    if (_selectedCategory == '投稿') {
      return _buildPostListView();
    } else if (_selectedCategory == '教科') {
      return _buildSubjectListView(
        _searchResults.cast<String>() // 型変換して渡す
      );
    } else {
      return _buildGeneralListView();
    }
  }

  Widget _buildPostListView() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            !_isLoading) {
          _performSearch();
        }
        return false;
      },
      child: ListView.separated(
        itemCount: _searchResults.length,
        separatorBuilder: (context, index) => Divider(
          color: Colors.grey[300],
          thickness: 1,
          height: 1,
        ),
        itemBuilder: (context, index) {
          if (index >= _searchResults.length) {
            return const SizedBox.shrink();
          }
          final post = _searchResults[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 投稿の上部: ユーザー情報 + 時刻
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showUserProfile(post['auth_uid']);
                          },
                          child: CircleAvatar(
                            radius: 27,
                            backgroundColor: Colors.grey[200],
                            child: Text(
                              post['user_name'] != null
                                  ? post['user_name'][0]
                                  : '?',
                              style: const TextStyle(fontSize: 23, color: Colors.black),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  post['user_name'] ?? 'Unknown',
                                  style: const TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '@${post['user_id'] ?? 'ID Unknown'}',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      post['createdAt'] != null ? _timeAgo(post['createdAt']) : '',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                // 投稿本文
                Padding(
                  padding: const EdgeInsets.only(left: 64.0),
                  child: Text(
                    post['description'] ?? '内容なし',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                // いいねボタンなど
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        post['is_liked'] == true
                            ? Icons.thumb_up_alt
                            : Icons.thumb_up_alt_outlined,
                        color: post['is_liked'] == true ? Colors.blue : Colors.grey,
                      ),
                      onPressed: () {
                        // 必要であれば、いいね処理を実装
                      },
                    ),
                    Text('${post['like_count'] ?? 0}'),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubjectListView(List<String> listToDisplay) {
    if (listToDisplay.isEmpty) {
      return const Center(child: Text('該当するデータがありません。'));
    }

    return ListView.builder(
      itemCount: listToDisplay.length,
      itemBuilder: (context, index) {
        final subjectName = listToDisplay[index];
        return Container(
          constraints: const BoxConstraints(
            maxHeight: 45, // 最大高さを設定
            ),
            child: ListTile(
            title: Text(
              subjectName,
              style: const TextStyle(
                fontSize: 15
              )
            ),
            onTap: () {
            // Expanded で SubjectDetailsScreen を表示する
            _showSubjectDetails(subjectName);
            },
          ),
        );
      },
    );
  }

  Widget _buildGeneralListView() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        if (index >= _searchResults.length) {
          return const SizedBox.shrink();
        }
        final result = _searchResults[index];

        if (_selectedCategory == 'ユーザー') {
          if (result is Map<String, dynamic>) {
            return ListTile(
              title: Text(result['user_name']?.toString() ?? 'Unknown'),
              subtitle: Text('@${result['user_id']?.toString() ?? 'ID Unknown'}'),
              onTap: () => _showUserProfile(result['auth_uid']),
            );
          } else {
            return const SizedBox.shrink();
          }
        } else if (_selectedCategory == 'グループ') {
          final group = _searchResults[index];
          return ListTile(
            title: Text(group['groupName'] ?? 'グループ名なし'),
            subtitle: Text('作成者: ${group['createdBy'] ?? '不明'}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupDetailsPage(
                    groupId: group['groupId'],
                    groupName: group['groupName'],
                  ),
                ),
              );
            },
          );
        } else if (_selectedCategory == 'タグ') {
          return ListTile(
            title: Text(result['tagName'] ?? 'タグなし'),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 検索結果部分と SubjectDetailsScreen / UserProfileScreen を切り替える
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0), // 検索バー + タブバーの高さ
          child: Column(
            children: [
              // ===== 検索バー =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '検索ワードを入力してください',
                     hintStyle: const TextStyle(fontSize: 14),
                    suffixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      // 画面表示を一度検索に戻す
                      if (_isUserProfileVisible) _hideUserProfile();
                      if (_isSubjectDetailsVisible) _hideSubjectDetails();

                      if (_selectedCategory == 'ユーザー') {
                        if (_debounce?.isActive ?? false) _debounce!.cancel();
                        _debounce = Timer(const Duration(milliseconds: 500), () {
                          if (mounted) {
                            _performSearch();
                          }
                        });
                      }
                    });
                  },
                  onSubmitted: (value) {
                    setState(() {
                      _searchQuery = value;
                      // 画面表示を一度検索に戻す
                      if (_isUserProfileVisible) _hideUserProfile();
                      if (_isSubjectDetailsVisible) _hideSubjectDetails();

                      if (_selectedCategory == '投稿' || 
                          _selectedCategory == '教科' || 
                          _selectedCategory == 'グループ') {
                        _performSearch();
                      }
                    });
                  },
                ),
              ),
              // ===== タブバー =====
              TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF0ABAB5),
                labelColor: const Color(0xFF0ABAB5),
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(
                  fontSize: 14, // 選択中のタブのテキストサイズ
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 12, // 非選択中のタブのテキストサイズ
                ),
                tabs: const [
                  Tab(text: '投稿'),
                  Tab(text: 'ユーザー'),
                  Tab(text: 'グループ'),
                  Tab(text: '教科'),
                  Tab(text: 'タグ'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // ====== 検索結果（TabBarView） ======
          Offstage(
            offstage: _isUserProfileVisible || _isSubjectDetailsVisible,
            child: Column(
              children: [
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSearchResultsOrSubjects(), // 投稿
                      _buildSearchResultsOrSubjects(), // ユーザー
                      _buildSearchResultsOrSubjects(), // グループ
                      _buildSearchResultsOrSubjects(), // 教科
                      _buildSearchResultsOrSubjects(), // タグ
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ====== ユーザープロフィール画面 ======
          Offstage(
            offstage: !_isUserProfileVisible,
            child: _isUserProfileVisible
                ? Column(
                    children: [
                      Expanded(
                        child: UserProfileScreen(
                          userId: _selectedUserId,
                          onBack: _hideUserProfile,
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),

          // ====== SubjectDetailsScreen 画面 ======
          Offstage(
            offstage: !_isSubjectDetailsVisible,
            child: _isSubjectDetailsVisible && _selectedSubjectName != null
                ? Column(
                    children: [
                      Expanded(
                        child: SubjectDetailsScreenWithBack(
                          subjectName: _selectedSubjectName!,
                          onBack: _hideSubjectDetails,
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/// SubjectDetailsScreen に戻るボタンを付けたラッパー
/// - 実装例：AppBar などで戻る操作をして onBack() を呼ぶ
class SubjectDetailsScreenWithBack extends StatelessWidget {
  final String subjectName;
  final VoidCallback onBack;

  const SubjectDetailsScreenWithBack({
    Key? key,
    required this.subjectName,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 画面上の AppBar に戻るボタン
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      body: SubjectDetailsScreen(subjectName: subjectName),
    );
  }
}
