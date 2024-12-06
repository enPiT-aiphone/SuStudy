import '/import.dart';
import 'display_subjects.dart';
import 'display_user.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _selectedCategory = 'ユーザー'; // 現在選択されているカテゴリ
  String _searchQuery = ''; // 検索クエリ
  List<dynamic> _searchResults = []; // 検索結果
  List<String> _subjectList = []; // 教科一覧
  bool _isLoading = false; // ローディング状態

  @override
  void initState() {
    super.initState();
    _fetchSubjects(); // 初期化時に教科一覧を取得
  }

  // 教科一覧を取得
  Future<void> _fetchSubjects() async {
    try {
      final subjectsSnapshot = await FirebaseFirestore.instance
          .collection('subjects')
          .get();
      setState(() {
        _subjectList = subjectsSnapshot.docs.map((doc) => doc.id).toList();
      });
    } catch (e) {
      print('教科一覧の取得エラー: $e');
    }
  }

  // カテゴリ変更時の処理
  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _searchResults = []; // 結果をリセット
      _searchQuery = ''; // 検索クエリをリセット
    });
  }

  // 検索処理
  Future<void> _performSearch() async {
    if (_searchQuery.isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchResults = [];
    });

    try {
      if (_selectedCategory == 'ユーザー') {
        // Usersコレクションから検索
        final querySnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('user_name', isEqualTo: _searchQuery)
            .get();
        final idSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('user_id', isEqualTo: _searchQuery)
            .get();

      // 検索結果をマージして重複を除外
      final allResults = [...querySnapshot.docs, ...idSnapshot.docs];
      final uniqueResults = allResults
          .fold<Map<String, dynamic>>({}, (map, doc) {
            map[doc['user_id']] = doc;
            return map;
          })
          .values
          .toList();

        
      setState(() {
        _searchResults = uniqueResults;
      });
    } else if (_selectedCategory == '教科') {
        // Subjectsコレクションから検索
        final querySnapshot = await FirebaseFirestore.instance
            .collection('subjects')
            .doc(_searchQuery)
            .get();
        if (querySnapshot.exists) {
          setState(() {
            _searchResults = [querySnapshot];
          });
        } else {
          setState(() {
            _searchResults = [];
          });
        }
      }
    } catch (e) {
      print('検索エラー: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 検索結果または教科一覧の表示
  Widget _buildSearchResultsOrSubjects() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_searchQuery.isNotEmpty && _searchResults.isEmpty) {
      return Center(child: Text('結果が見つかりませんでした。'));
    }

    if (_searchQuery.isNotEmpty) {
      // 検索結果の表示
      if (_selectedCategory == 'ユーザー') {
        return ListView.builder(
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
            final user = _searchResults[index];
            return ListTile(
              title: Text(user['user_name'] ?? 'Unknown'),
              subtitle: Text('@${user['user_id'] ?? 'ID Unknown'}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserDetailsPage(
                      userId: user['user_id'],
                      userName: user['user_name'],
                    ),
                  ),
                );
              },
            );
          },
        );
      } else if (_selectedCategory == '教科') {
        return ListView.builder(
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
            final subject = _searchResults[index];
            return ListTile(
              title: Text(subject.id),
              subtitle: Text('教科データが見つかりました'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SubjectDetailsScreen(subjectName: subject.id),
                  ),
                );
              },
            );
          },
        );
      }
    }

    // 教科一覧の表示
    if (_selectedCategory == '教科' && _searchQuery.isEmpty) {
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
    }

    return Center(child: Text('結果が見つかりませんでした。'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
              onSubmitted: (value) => _performSearch(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['投稿', 'ユーザー', '教科', 'タグ'].map((category) {
                return GestureDetector(
                  onTap: () => _onCategorySelected(category),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
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
          ),
          Expanded(child: _buildSearchResultsOrSubjects()),
        ],
      ),
    );
  }
}
