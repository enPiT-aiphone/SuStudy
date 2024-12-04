import '/import.dart'; // アプリ全体で使用するインポートファイル
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuthをインポート

class RankingScreen extends StatefulWidget {
  @override
  _RankingScreenState createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  late Future<List<Map<String, dynamic>>> _rankingDataFuture;

  @override
  void initState() {
    super.initState();
    // ランキングデータの取得
    _rankingDataFuture = _fetchRankingData();
  }

  // Firestoreからランキングデータを取得
  Future<List<Map<String, dynamic>>> _fetchRankingData() async {
    try {
      // Usersコレクションからt_solved_count順にデータを取得
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .orderBy('t_solved_count', descending: true)
          .limit(10) // 上位10人のみ取得
          .get();

      // データをリストに変換
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'userName': data['user_name'] ?? 'Unknown', // ユーザー名
          'tSolvedCount': data['t_solved_count'] ?? 0, // 解決数
        };
      }).toList();
    } catch (e) {
      print('ランキングデータ取得エラー: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ランキング'),
        centerTitle: true,
      ),
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
                  child: Text('${index + 1}'), // ランキング順位を表示
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