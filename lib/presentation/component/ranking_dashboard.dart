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
      if (widget.selectedTab == 'フォロー中') {
        // フォロー中のユーザーのランキング取得ロジックは変更なし
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return [];

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

        Query query = FirebaseFirestore.instance
            .collection('Users')
            .where('user_id', whereIn: follows);

        // カテゴリフィルタリングを追加
        if (widget.selectedCategory != '全体') {
          query = query.where('following_subjects', arrayContains: widget.selectedCategory);
        }

        final querySnapshot = await query
            .orderBy('t_solved_count', descending: true)
            .limit(10)
            .get();

        return _processQuerySnapshot(querySnapshot);
      } else {
        // 通常のランキング取得
        Query query = FirebaseFirestore.instance.collection('Users');
        
        // カテゴリフィルタリングを追加
        if (widget.selectedCategory != '全体') {
          query = query.where('following_subjects', arrayContains: widget.selectedCategory);
        }

        final querySnapshot = await query
            .orderBy('t_solved_count', descending: true)
            .limit(10)
            .get();

        return _processQuerySnapshot(querySnapshot);
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