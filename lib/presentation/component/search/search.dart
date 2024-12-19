import '/import.dart';
import 'display_subjects.dart';
import 'display_groups.dart';
import 'user_profile_screen.dart';
import 'package:collection/collection.dart';
import 'dart:async';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> 
  with SingleTickerProviderStateMixin {
  String _selectedCategory = 'ユーザー';
  String _searchQuery = '';
  List<dynamic> _searchResults = [];
  List<String> _subjectList = [];
  List<Map<String, String>> _groupList = []; // グループ一覧
  bool _isLoading = false;
  bool _isUserProfileVisible = false;
  String _selectedUserId = '';
  Timer? _debounce;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _fetchSubjects();
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

  Map<String, List<dynamic>> _tabResults = {
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
        _searchResults = _tabResults[_selectedCategory] ?? [];
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
      setState(() {
        _subjectList = subjectsSnapshot.docs.map((doc) => doc.id).toList();
      });
    } catch (e) {
      print('教科一覧の取得エラー: $e');
    }
  }

    void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _searchResults = [];
    });

    if (_searchQuery.isNotEmpty) {
      _performSearch();
    }
  }

  Future<void> _performSearch() async {
    if (_searchQuery.isEmpty) return;

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
          .where('description', isLessThan: normalizedQuery + '\uf8ff')
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
            .where(FieldPath.documentId, isLessThan: _searchQuery + '\uf8ff')
            .get();

        setState(() {
          _searchResults = querySnapshot.docs;
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

void _onSearchChanged(String value) {
  setState(() {
    _searchQuery = value;

    // ユーザー検索中にプロフィール画面が表示されている場合は閉じる
    if (_isUserProfileVisible) {
      _hideUserProfile();
    }

    if (_selectedCategory == 'ユーザー') {
      // ユーザー検索のみリアルタイム検索
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(Duration(milliseconds: 500), () {
        if (mounted) {
          _performSearch();
        }
      });
    }
  });
}


  void _onSearchSubmitted(String value) {
  setState(() {
    _searchQuery = value;
    if (_selectedCategory == '投稿') {
      _performSearch(); // エンターキーで検索を実行
    }
  });
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

  Widget _buildSearchUI() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: '検索ワードを入力してください',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            onSubmitted: (value) {
              setState(() {
                _searchQuery = value;
                _performSearch();
              });
            },
          ),
        ),
        Expanded(child: _buildSearchResultsOrSubjects()),
      ],
    );
  }

Widget _buildSearchResultsOrSubjects() {
  if (_isLoading) {
    return Center(child: CircularProgressIndicator());
  }

  if (_searchQuery.isNotEmpty && _searchResults.isEmpty) {
    return Center(child: Text('結果が見つかりませんでした。'));
  }

  // 投稿カテゴリの場合、タイムラインと同じレイアウトを使用
  if (_selectedCategory == '投稿') {
    if (_searchResults.isEmpty) {
      return Center(child: Text('投稿は見つかりませんでした。'));
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            !_isLoading) {
          // スクロール位置が一番下に到達した場合、次の投稿を取得
          _performSearch(); // 必要であれば投稿データを追加で取得
        }
        return false;
      },
      child: ListView.separated(
        itemCount: _searchResults.length,
        separatorBuilder: (context, index) => Divider(
          color: Colors.grey[300], // 線の色を指定
          thickness: 1, // 線の太さを指定
          height: 1, // 線の高さ
        ),
        itemBuilder: (context, index) {
          if (index >= _searchResults.length) {
            return SizedBox.shrink();
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
                              style: TextStyle(fontSize: 25, color: Colors.black),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  post['user_name'] ?? 'Unknown',
                                  style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '@${post['user_id'] ?? 'ID Unknown'}',
                                  style: TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      post['createdAt'] != null ? _timeAgo(post['createdAt']) : '',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 64.0),
                  child: Text(
                    post['description'] ?? '内容なし',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(height: 10),
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

  // その他のカテゴリ
  if (_searchResults.isEmpty) {
    return Center(child: Text('該当するデータがありません。'));
  }

  return ListView.builder(
    itemCount: _searchResults.length,
    itemBuilder: (context, index) {
      if (index >= _searchResults.length) {
        return SizedBox.shrink();
      }
      final result = _searchResults[index];
      if (_selectedCategory == 'ユーザー') {
        return ListTile(
          title: Text(result['user_name'] ?? 'Unknown'),
          subtitle: Text('@${result['user_id'] ?? 'ID Unknown'}'),
          onTap: () => _showUserProfile(result['auth_uid']),
        );
      } else if (_selectedCategory == 'グループ') {
        final group = _searchResults[index];
        return ListTile(
          title: Text(group['groupName'] ?? 'グループ名なし'),
          subtitle: Text('作成者: ${group['createdBy']}'),
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
      } else if (_selectedCategory == '教科' && _searchQuery.isEmpty) {
        final subjectName = _subjectList[index];
        return ListTile(
          title: Text(subjectName),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    SubjectDetailsScreen(subjectName: subjectName),
              ),
            );
          },
        );
      } else if (_selectedCategory == 'タグ') {
        return ListTile(
          title: Text(result['tagName'] ?? 'タグなし'),
        );
      }
      return SizedBox.shrink();
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(80.0), // 検索バー + タブバーの高さ
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '検索ワードを入力してください',
                    suffixIcon: Icon(Icons.search),
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
                        // ユーザー検索のみリアルタイム検索
                        if (_debounce?.isActive ?? false) _debounce!.cancel();
                        _debounce = Timer(Duration(milliseconds: 500), () {
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
                      if (_selectedCategory == '投稿') {
                        // 投稿検索はエンターキーで実行
                        _performSearch();
                      }
                    });
                  },
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: Color(0xFF0ABAB5), // インジケーターの色
                labelColor: Color(0xFF0ABAB5), // 選択中のタブの色
                unselectedLabelColor: Colors.grey, // 未選択のタブの色
                tabs: [
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