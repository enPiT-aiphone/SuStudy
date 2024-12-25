import '/import.dart'; // アプリ全体で使用するインポートファイル
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuthをインポート
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestoreをインポート
import 'package:flutter/material.dart'; // Flutterウィジェットをインポート
import 'search/user_profile_screen.dart';
import 'package:intl/intl.dart';


class RankingScreen extends StatefulWidget {
  final String selectedTab;
  final String selectedCategory;

  const RankingScreen({
    super.key,
    required this.selectedTab,
    required this.selectedCategory,
  });

  @override
  _RankingScreenState createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  late Future<List<Map<String, dynamic>>> _rankingDataFuture;

  late Map<String, dynamic> _userData;
  int? _userRank = -1;

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
            .map((doc) => doc.data()['auth_uid'])
            .whereType<String>()
            .toList();

        if (follows.isEmpty) return [];

        query = FirebaseFirestore.instance
            .collection('Users')
            .where('auth_uid', whereIn: follows);

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
                (timestamp as Timestamp).toDate().isAfter(todayStart.subtract(const Duration(hours: 24))))
            .toList();

        if (todayLogins.isNotEmpty) {
          if (widget.selectedCategory == "全体") {
              // Firestore パスを動的に取得
              final today = DateTime.now();
              final formattedDate = DateFormat('yyyy-MM-dd').format(today);

              // 現在の日付のレコードからデータを取得
              final recordDocSnapshot = await FirebaseFirestore.instance
                  .collection('Users')
                  .doc(doc.id) // ユーザーのIDを使ってそのユーザーのサブコレクションにアクセス
                  .collection('record')
                  .doc(formattedDate) // 今日の日付を使ったドキュメント
                  .get();

              // tierProgress_today を取得
              final formattedDateData = recordDocSnapshot.data();
              final tSolvedCount = formattedDateData?['t_solved_count'] ?? 0;

              rankingData.add({
                'userName': data['user_name'] ?? 'Unknown',
                'tSolvedCount': tSolvedCount, // tierProgress_today を設定
                'auth_uid': data['auth_uid'], // auth_uid を追加
              });
          } else {
            try {
              // Firestore パスを動的に取得
              final today = DateTime.now();
              final formattedDate = DateFormat('yyyy-MM-dd').format(today);

              // 現在の日付のレコードからデータを取得
              final recordDocSnapshot = await FirebaseFirestore.instance
                  .collection('Users')
                  .doc(doc.id) // ユーザーのIDを使ってそのユーザーのサブコレクションにアクセス
                  .collection('record')
                  .doc(formattedDate) // 今日の日付を使ったドキュメント
                  .collection(widget.selectedCategory) // カテゴリ名を使ったサブコレクション
                  .doc('Word') // 'Word' ドキュメント
                  .get();

              // tierProgress_today を取得
              final recordData = recordDocSnapshot.data();
              final tierProgressToday = recordData?['tierProgress_today'] ?? 0;

              rankingData.add({
                'userName': data['user_name'] ?? 'Unknown',
                'tSolvedCount': tierProgressToday, // tierProgress_today を設定
                'auth_uid': data['auth_uid'], // auth_uid を追加
              });
            } catch (e) {
              print('データ取得エラー: ${doc.id}, ${widget.selectedCategory}, $e');
            }
          }
        }
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];

      final userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();
      // ここからはフォロー中の時、自分のデータをランキングに追加する処理
      if (userSnapshot.exists) {
        final userData = userSnapshot.data();
        if (userData != null) {
          final today = DateTime.now();
          final formattedDate = DateFormat('yyyy-MM-dd').format(today);

          try {
            if (widget.selectedCategory == '全体') {
              // 全体の場合、現在の日付のレコードから t_solved_count を取得
              final recordDocSnapshot = await FirebaseFirestore.instance
                  .collection('Users')
                  .doc(user.uid) // 現在のユーザー ID
                  .collection('record') // レコードサブコレクション
                  .doc(formattedDate) // 今日の日付を使ったドキュメント
                  .get();

              // t_solved_count を取得
              final recordData = recordDocSnapshot.data();
              final tSolvedCount = recordData?['t_solved_count'] ?? 0;

              _userData = {
                'userName': userData['user_name'] ?? 'Unknown',
                'tSolvedCount': tSolvedCount, // 今日の t_solved_count を設定
                'auth_uid': userData['auth_uid'],
              };
            } else {
              // カテゴリが選択されている場合、カテゴリごとのデータを取得
              final recordDocSnapshot = await FirebaseFirestore.instance
                  .collection('Users')
                  .doc(user.uid) // 現在のユーザー ID
                  .collection('record') // レコードサブコレクション
                  .doc(formattedDate) // 今日の日付を使ったドキュメント
                  .collection(widget.selectedCategory) // カテゴリ名を使ったサブコレクション
                  .doc('Word') // 'Word' ドキュメント
                  .get();

              // tierProgress_today を取得
              final recordData = recordDocSnapshot.data();
              final tierProgressToday = recordData?['tierProgress_today'] ?? 0;

              _userData = {
                'userName': userData['user_name'] ?? 'Unknown',
                'tSolvedCount': tierProgressToday, // tierProgress_today を設定
                'auth_uid': userData['auth_uid'],
              };
            }
          } catch (e) {
            print('自分のデータ取得エラー: $e');
            _userData = {
              'userName': userData['user_name'] ?? 'Unknown',
              'tSolvedCount': 0, // データが取得できなかった場合 0 を設定
              'auth_uid': userData['auth_uid'],
            };
          }
        }
      }

      //フォロー中の時に自分のデータのランキングへの追加
      if (widget.selectedTab == 'フォロー中') {
        rankingData.add({
          'userName': _userData['userName'],
          'tSolvedCount': _userData['tSolvedCount'],
          'auth_uid': _userData['auth_uid'],
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
              .firstWhere((user) => user['auth_uid'] == _userData['auth_uid'],
                  orElse: () => {'rank': -1})['rank'] ??
          -1;

      return rankingData.take(100).toList();
    } catch (e) {
      print('ランキングデータ取得エラー: $e');
      return [];
    }
  }

    String getSubjectName(String selectedCategory) {
      if (selectedCategory.contains('TOEIC')){
        return 'TOEIC';
    } else if (selectedCategory.contains('TOEFL')){
        return 'TOEFL';
    } else if (selectedCategory.contains('英検')){
        return '英検';
    } else{
      return '英検';
    }
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ランキング'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _rankingDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('データ取得エラー: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ランキングデータがありません'));
          }

          final rankingData = snapshot.data!;

          return Column(
            children: [
              if (_userRank != -1)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'あなたの順位: $_userRank 位',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        // プロフィール画面に遷移
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserProfileScreen(
                              userId: user['auth_uid'], // 選択したユーザーのauth_uidを渡す
                              onBack: () {
                                Navigator.pop(context); // ランキング画面に戻る
                              },
                            ),
                          ),
                        );
                      },
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

