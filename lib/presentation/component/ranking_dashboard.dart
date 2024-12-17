import '/import.dart'; // アプリ全体で使用するインポートファイル
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuthをインポート

class RankingScreen extends StatefulWidget {
  final String selectedTab;
  final String selectedCategory; // 追加：カテゴリを受け取る

  RankingScreen({
    required this.selectedTab,
    required this.selectedCategory, // 追加
  });

  @override
  _RankingScreenState createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  late Future<List<Map<String, dynamic>>> _rankingDataFuture;

  @override
  void initState() {
    super.initState();
    _rankingDataFuture = _fetchRankingData();
  }

  @override
  void didUpdateWidget(covariant RankingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedTab != oldWidget.selectedTab ||
        widget.selectedCategory != oldWidget.selectedCategory) { // カテゴリの変更も監視
      setState(() {
        _rankingDataFuture = _fetchRankingData();
      });
    }
  }

Future<List<Map<String, dynamic>>> _fetchRankingData() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    if (widget.selectedTab == 'フォロー中') {
      // フォロー中のユーザーランキング取得
      final followsSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('follows')
          .get();

      final follows = followsSnapshot.docs
          .map((doc) => doc.data()['user_id'])
          .where((userId) => userId != null)
          .toList();

      if (follows.isEmpty) return [];

      if (widget.selectedCategory != '全体') {
        // 教科名を付加したt_solved_countキーを取得
        final targetKey = 't_solved_count_${widget.selectedCategory}';

        final querySnapshots = await Future.wait(
          follows.map((userId) async {
            final userDoc = await FirebaseFirestore.instance
                .collection('Users')
                .doc(userId)
                .get();

            if (userDoc.exists) {
              final data = userDoc.data()!;
              if (data.containsKey(targetKey)) {
                return {
                  'userName': data['user_name'] ?? 'Unknown',
                  'tSolvedCount': data[targetKey] ?? 0,
                };
              }
            }
            return null;
          }),
        );

        final filteredData = querySnapshots
            .where((data) => data != null)
            .cast<Map<String, dynamic>>()
            .toList();

        // t_solved_countでソートして上位10件を返す
        filteredData.sort((a, b) =>
            (b['tSolvedCount'] as int).compareTo(a['tSolvedCount'] as int));
        return filteredData.take(10).toList();
      } else {
        // 全体のt_solved_countでランキング表示
        Query query = FirebaseFirestore.instance
            .collection('Users')
            .where('user_id', whereIn: follows);

        final querySnapshot = await query
            .orderBy('t_solved_count', descending: true)
            .limit(10)
            .get();

        return _processQuerySnapshot(querySnapshot);
      }
    } else {
      // 通常ランキング取得
      if (widget.selectedCategory != '全体') {
        // 教科名を付加したt_solved_countキーを取得
        final targetKey = 't_solved_count_${widget.selectedCategory}';

        final querySnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where(targetKey, isGreaterThan: 0) // 解いた問題があるユーザーのみ取得
            .orderBy(targetKey, descending: true)
            .limit(10)
            .get();

        return querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'userName': data['user_name'] ?? 'Unknown',
            'tSolvedCount': data[targetKey] ?? 0,
          };
        }).toList();
      } else {
        // 全体のt_solved_countでランキング表示
        final querySnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .orderBy('t_solved_count', descending: true)
            .limit(10)
            .get();

        return _processQuerySnapshot(querySnapshot);
      }
    }
  } catch (e) {
    print('ランキングデータ取得エラー: $e');
    return [];
  }
}



  // クエリ結果の処理を共通化
  List<Map<String, dynamic>> _processQuerySnapshot(QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'userName': data['user_name'] ?? 'Unknown',
        'tSolvedCount': data['t_solved_count'] ?? 0,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _rankingDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('データ取得エラー: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('ランキングデータがありません'));
          }

          final rankingData = snapshot.data!;

          return ListView.builder(
            itemCount: rankingData.length,
            itemBuilder: (context, index) {
              final user = rankingData[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text('${index + 1}'),
                ),
                title: Text(user['userName']),
                trailing: Text(
                  '${user['tSolvedCount']} 解決',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          );
        },
      ),
    );
  }
}