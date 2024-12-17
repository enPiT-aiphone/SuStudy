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
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);

      Query query;

      if (widget.selectedTab == 'フォロー中') {
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

        follows.add(user.uid);
      } else {
        query = FirebaseFirestore.instance.collection('Users');
      }

      if (widget.selectedCategory != '全体') {
        query = query.where('following_subjects', arrayContains: widget.selectedCategory);
      }

      final querySnapshot = await query.get();

      final List<Map<String, dynamic>> rankingData = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        final loginHistory = data['login_history'] ?? [];
        final todayLogins = loginHistory
            .where((timestamp) =>
                (timestamp as Timestamp).toDate().isAfter(todayStart.subtract(Duration(hours: 24))))
            .toList();

        if (todayLogins.isNotEmpty) {
          rankingData.add({
            'userName': data['user_name'] ?? 'Unknown',
            'tSolvedCount': data['t_solved_count'] ?? 0,
            'userId': data['user_id'],
          });
        }
      }

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

      if (widget.selectedTab == 'フォロー中') {
        rankingData.add({
          'userName': _userData['userName'],
          'tSolvedCount': _userData['tSolvedCount'],
          'userId': _userData['userId'],
        });
      }

      rankingData.sort((a, b) => b['tSolvedCount'].compareTo(a['tSolvedCount']));

      // 同率順位の計算
      int rank = 1;
      for (int i = 0; i < rankingData.length; i++) {
        if (i > 0 &&
            rankingData[i]['tSolvedCount'] == rankingData[i - 1]['tSolvedCount']) {
          rankingData[i]['rank'] = rankingData[i - 1]['rank'];
        } else {
          rankingData[i]['rank'] = rank;
        }
        rank++;
      }

      _userRank = rankingData
              .firstWhere((user) => user['userId'] == _userData['userId'],
                  orElse: () => {'rank': -1})['rank'] ??
          -1;

      return rankingData.take(100).toList();
    } catch (e) {
      print('ランキングデータ取得エラー: $e');
      return [];
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ランキング'),
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

          return Column(
            children: [
              if (_userRank != -1)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'あなたの順位: $_userRank 位',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: rankingData.length,
                  itemBuilder: (context, index) {
                    final user = rankingData[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${user['rank']}'),
                      ),
                      title: Text(user['userName']),
                      trailing: Text(
                        '${user['tSolvedCount']} 問',
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