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
  bool _isUserProfileVisible = false;
  String _selectedUserId = '';
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
        if (_isUserProfileVisible) {
          _hideUserProfile();
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
    });
  }

  void _hideUserProfile() {
    setState(() {
      _isUserProfileVisible = false;
      _selectedUserId = '';
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

    setState(() {
      _isLoading = true;
      _searchResults = [];
    });

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

      // auth_uidリストを収集
      final authUids = querySnapshot.docs
          .map((doc) => doc.data()['auth_uid'] as String?)
          .where((uid) => uid != null)
          .toSet();

      if (authUids.isNotEmpty) {
        // Usersコレクションから関連するユーザー情報を取得
        final userQuerySnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('auth_uid', whereIn: authUids.toList())
            .get();

        // auth_uidをキーにしたユーザーデータのマップを作成
        final userMap = {
          for (var doc in userQuerySnapshot.docs)
            doc.data()['auth_uid']: doc.data()
        };

        // 投稿データを組み立て
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
          // 検索結果が存在する場合、_searchResultsに保存
          _searchResults = querySnapshot.docs.map((doc) => doc.id).toList();
        } else {
          // 検索結果が存在しない場合、_searchResultsは空のまま
          _searchResults = [];
        }
      });
    }else if (_selectedCategory == 'グループ') {
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
    return const Center(child: CircularProgressIndicator(valueColor:  AlwaysStoppedAnimation<Color>(Color(0xFF0ABAB5))));
  }

  // 検索クエリが存在するが結果がない場合
  if (_searchQuery.isNotEmpty && _searchResults.isEmpty) {
    return const Center(child: Text('結果が見つかりませんでした。'));
  }

  if (_selectedCategory == '教科' && _searchResults.isEmpty) {
    return _buildSubjectListView(_subjectList); // 教科一覧を表示
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
        _performSearch(); // 必要であれば投稿データを追加で取得
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
                            style: const TextStyle(fontSize: 25, color: Colors.black),
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
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '@${post['user_id'] ?? 'ID Unknown'}',
                                style: const TextStyle(fontSize: 13, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    post['createdAt'] != null ? _timeAgo(post['createdAt']) : '',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 64.0),
                child: Text(
                  post['description'] ?? '内容なし',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),
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
      return ListTile(
        title: Text(subjectName),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubjectDetailsScreen(subjectName: subjectName),
            ),
          );
        },
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
            title: Text(result['user_name']?.toString() ?? 'Unknown'), // 型安全性を確保
            subtitle: Text('@${result['user_id']?.toString() ?? 'ID Unknown'}'),
            onTap: () => _showUserProfile(result['auth_uid']),
          );
        } else {
          return const SizedBox.shrink(); // 不明な型の場合は何も表示しない
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
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80.0), // 検索バー + タブバーの高さ
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '検索ワードを入力してください',
                    suffixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;

                      // プロフィール画面を閉じる
                      if (_isUserProfileVisible) {
                        _hideUserProfile();
                      }

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
                      if (_selectedCategory == '投稿' || _selectedCategory == '教科' || _selectedCategory == 'グループ') {
                        // 投稿検索はエンターキーで実行
                        _performSearch();
                      }
                    });
                  },
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF0ABAB5), // インジケーターの色
                labelColor: const Color(0xFF0ABAB5), // 選択中のタブの色
                unselectedLabelColor: Colors.grey, // 未選択のタブの色
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
      body: Column(
        children: [
          if (!_isUserProfileVisible)
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
          if (_isUserProfileVisible)
            Expanded(
              child: UserProfileScreen(
                userId: _selectedUserId,
                onBack: _hideUserProfile,
              ),
            ),
        ],
      ),
    );
  }
}