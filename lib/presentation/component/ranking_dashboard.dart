import '/import.dart'; // アプリ全体で使用するインポートファイル
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuthをインポート
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestoreをインポート
import 'package:flutter/material.dart'; // Flutterウィジェットをインポート

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
      // 今日の開始時刻 (午前0時) と翌日の開始時刻 (午前0時)
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      print('today: ${todayStart}');

      Query query;

      if (widget.selectedTab == 'フォロー中') {
        // フォロー中のユーザーのランキング取得
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return [];

        final followsSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('follows')
            .get();

        final follows = followsSnapshot.docs
            .map((doc) => doc.data()['user_id'])
            .whereType<String>()
            .toList();

        if (follows.isEmpty) return [];

        query = FirebaseFirestore.instance
            .collection('Users')
            .where('user_id', whereIn: follows);
      } else {
        // 通常のランキング取得
        query = FirebaseFirestore.instance
            .collection('Users');
      }

      // カテゴリフィルタリングを追加
      if (widget.selectedCategory != '全体') {
        query = query.where('following_subjects', arrayContains: widget.selectedCategory);
      }

      final querySnapshot = await query.get();

      print('Query snapshot length: ${querySnapshot.docs.length}');

      // 今日ログインしたユーザーのみフィルタリング
      final List<Map<String, dynamic>> rankingData = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // login_historyを取得
        final loginHistory = data['login_history'] ?? [];
        final todayLogins = loginHistory
            .where((timestamp) => (timestamp as Timestamp).toDate().isAfter(todayStart.subtract(Duration(hours: 24))))
            .toList();

        // 今日ログインしたユーザーのみランキングに追加
        if (todayLogins.isNotEmpty) {
          rankingData.add({
            'userName': data['user_name'] ?? 'Unknown',
            'tSolvedCount': data['t_solved_count'] ?? 0,
          });
        }
      }

      // 今日ログインしたユーザーでソート（解決数が多い順）
      rankingData.sort((a, b) => b['tSolvedCount'].compareTo(a['tSolvedCount']));

      // 上位10人だけを取得
      return rankingData.take(10).toList();
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
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(  // ランキングデータを表示
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
