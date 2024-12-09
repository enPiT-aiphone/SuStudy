import '/import.dart'; // アプリ全体で使用するインポートファイル
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuthをインポート

class RankingScreen extends StatefulWidget {
  final String selectedTab;

  RankingScreen({required this.selectedTab}); // selectedTabをコンストラクタで受け取る

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


  @override
  void didUpdateWidget(covariant RankingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedTab != oldWidget.selectedTab) {
      // selectedTab が変更された場合、データを再取得
      setState(() {
        _rankingDataFuture = _fetchRankingData();
      });
    }
  }

  // Firestoreからランキングデータを取得
  Future<List<Map<String, dynamic>>> _fetchRankingData() async {
    try {
      // selectedTabが「フォロー中」ならフォローしているユーザーのみを対象
      if (widget.selectedTab == 'フォロー中') {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          return []; // ログインしていない場合は空リストを返す
        }

        // ユーザーの「follows」サブコレクションからフォローしているユーザーのIDを取得
        final followsSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('follows')
            .get();

        //final follows = followsSnapshot.docs.map((doc) => doc.id).toList(); // フォローしているユーザーのIDリスト
        //final follows = followsSnapshot.docs.map((doc) => doc.data()['user_id']).toList(); // フォローしているユーザーのIDリスト

        final follows = followsSnapshot.docs
    .map((doc) => doc.data()['user_id'])
    .where((userId) => userId != null) // null を除外
    .toList();

    print('Follows list: $follows'); // 最終的な follows リストをプリント
        
        if (follows.isEmpty) {
          return []; // フォロワーがいない場合は空リストを返す
        }

        // フォロワーに関連するランキングデータを取得
        print('Followsリスト: $follows'); // リスト内容を確認
final querySnapshot = await FirebaseFirestore.instance
    .collection('Users')
    .where('user_id', whereIn: follows) // 確認
    .orderBy('t_solved_count', descending: true)
    .limit(10)
    .get();
print('クエリ結果: ${querySnapshot.docs.map((doc) => doc.data())}');

        return querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'userName': data['user_name'] ?? 'Unknown', // ユーザー名
            'tSolvedCount': data['t_solved_count'] ?? 0, // 解決数
          };
        }).toList();
      } else {
        // selectedTabが「最新」なら全体ランキングを表示
        final querySnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .orderBy('t_solved_count', descending: true)
            .limit(10) // 上位10人のみ取得
            .get();

        return querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'userName': data['user_name'] ?? 'Unknown', // ユーザー名
            'tSolvedCount': data['t_solved_count'] ?? 0, // 解決数
          };
        }).toList();
      }
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