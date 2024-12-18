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
  with SingleTickerProviderStateMixin{
  String _selectedCategory = 'ユーザー';
  String _searchQuery = '';
  List<dynamic> _searchResults = [];
  List<String> _subjectList = [];
  List<Map<String, String>> _groupList = []; // グループ一覧
  bool _isLoading = false;
  bool _isUserProfileVisible = false;
  String _selectedUserId = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
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

    // グループ一覧を取得
Future<void> _fetchGroups() async {
  setState(() {
    _isLoading = true; // ローディング状態を開始
  });

  try {
    final groupsSnapshot =
        await FirebaseFirestore.instance.collection('Groups').limit(10).get();
        print(groupsSnapshot.docs);
    setState(() {
      // ドキュメントからデータを安全に取得
      _groupList = groupsSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'groupName': data['groupName']?.toString() ?? 'グループ名なし',
          'createdBy': data['createdBy']?.toString() ?? '作成者不明',
          'groupId': doc.id, // ドキュメントIDをグループIDとして扱う
        };
      }).toList();

      _searchResults = _groupList; // 結果を更新
    });
  } catch (e) {
    print('グループ一覧の取得エラー: $e');
  } finally {
    setState(() {
      _isLoading = false; // ローディング状態を終了
    });
  }
}

  void _onCategorySelected(String category) {
      if (category == 'グループ') {
      _fetchGroups(); // グループ一覧を取得
    } else {// 他のカテゴリの場合の処理はここに追加
      _searchResults = [];
    }
    setState(() {
      _selectedCategory = category;
      _searchResults = []; // 結果をリセット
    });

    // 検索クエリが空でない場合に検索を実行
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
        final querySnapshot =
            await FirebaseFirestore.instance.collection('Timeline').get();
        final filteredResults = querySnapshot.docs
            .where((doc) {
              final data = doc.data();
              final description = data['description']?.toString() ?? '';
              return _calculateMatchScore(normalizedQuery, description, '') > 0;
            })
            .map((doc) => doc.data())
            .toList();

        setState(() {
          _searchResults = filteredResults;
        });
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      if (_isUserProfileVisible) {
        _hideUserProfile();
      }
    });

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: 500), () {
      _performSearch();
    });
  }

  String _normalizeString(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll('あ', 'a')
        .replaceAll('い', 'i');
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
            onChanged: _onSearchChanged,
            onSubmitted: (value) => _performSearch(),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['投稿', 'ユーザー', 'グループ', '教科', 'タグ'].map((category) {
            return GestureDetector(
              onTap: () => _onCategorySelected(category),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: _selectedCategory == category
                      ? Color(0xFF0ABAB5)
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: _selectedCategory == category
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
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

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];

        if (_selectedCategory == 'ユーザー') {
          return ListTile(
            title: Text(result['user_name'] ?? 'Unknown'),
            subtitle: Text('@${result['user_id'] ?? 'ID Unknown'}'),
            onTap: () => _showUserProfile(result['auth_uid']),
          );
        } else if (_selectedCategory == '投稿') {
          return ListTile(
            title: Text(result['description'] ?? '内容なし'),
            subtitle: Text('@ ${result['user_id'] ?? '不明'}'),
          );
        } else if (_selectedCategory == '教科' && _searchQuery.isEmpty) {
      return ListView.builder(
        itemCount: _subjectList.length,
        itemBuilder: (context, index) {
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
        },
      );
    } else if (_selectedCategory == 'グループ') {
              final group = _searchResults[index]; // すでにListView.builderのループ内
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
            } else if (_selectedCategory == 'タグ') {
          return ListTile(
            title: Text(result['tagName'] ?? 'タグなし'),
          );
        }
        return SizedBox.shrink();
      },
    );
  }
  
    Widget _buildUserProfile() {
    return Expanded(
      child: UserProfileScreen(userId: _selectedUserId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (!_isUserProfileVisible) ...[
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
                onChanged: _onSearchChanged,
                onSubmitted: (value) => _performSearch(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['投稿', 'ユーザー', 'グループ', '教科', 'タグ'].map((category) {
                return GestureDetector(
                  onTap: () => _onCategorySelected(category),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: _selectedCategory == category
                          ? Color(0xFF0ABAB5)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: _selectedCategory == category
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
           ] else ...[
        Expanded(
            child: UserProfileScreen(
              userId: _selectedUserId,
              onBack: _hideUserProfile, // 戻る矢印でプロフィール画面を閉じる
            ),
          ),
        ],
        // 検索結果表示
        if (!_isUserProfileVisible)
          Expanded(
            child: _buildSearchResultsOrSubjects(),
          ),
        ],
      ),
    );
  }
}