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

  late Map<String, dynamic> _userData; // 自分のデータを保持
  int? _userRank = -1; // 自分の順位

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

      // 自分のIDも追加
      follows.add(user.uid);  // 自分のIDも追加
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
          'userId': data['user_id'],
        });
      }
    }

    // 今日ログインしたユーザーでソート（解決数が多い順）
    rankingData.sort((a, b) => b['tSolvedCount'].compareTo(a['tSolvedCount']));

    // 自分のデータを保持
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final userSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('auth_uid', isEqualTo: user.uid)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      final userData = userSnapshot.docs.first.data();
      _userData = {
        'userName': userData['user_name'] ?? 'Unknown',
        'tSolvedCount': userData['t_solved_count'] ?? 0,
        'userId': userData['user_id'],
      };
    }

    // 自分のデータをランキングデータに追加
    rankingData.add({
      'userName': _userData['userName'],
      'tSolvedCount': _userData['tSolvedCount'],
      'userId': _userData['userId'],
    });

    // ランキングを再ソート
    rankingData.sort((a, b) => b['tSolvedCount'].compareTo(a['tSolvedCount']));

    // 自分の順位を計算
    _userRank = rankingData.indexWhere((user) => user['userId'] == _userData['userId']) + 1;

    // 上位100人だけを取得
    return rankingData.take(100).toList();
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

          return Column(
            children: [
              // 自分の順位を表示
              if (_userRank != -1)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'あなたの順位: $_userRank 位',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              // ランキングリストを表示
              Expanded(
                child: ListView.builder(
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
