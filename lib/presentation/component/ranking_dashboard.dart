import '/import.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // カスタムフォント
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart'; // ローディングアニメーション
import 'search/user_profile_screen.dart';
import '../../utils/fetchGroup.dart';

class RankingScreen extends StatefulWidget {
  final String selectedTab;
  final String selectedCategory;
  final Function(String userId) onUserProfileTap; // コールバック関数を追加

  const RankingScreen({
    super.key,
    required this.selectedTab,
    required this.selectedCategory,
    required this.onUserProfileTap
  });

  @override
  _RankingScreenState createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  late Future<List<Map<String, dynamic>>> _rankingDataFuture;
  final FetchGroup fetchGroup = FetchGroup();

  late Map<String, dynamic> _userData;
  int? _userRank = -1;
  String? _myGroup; // グループ名
  List<String> _groupMemberIds = []; // グループのユーザーIDリスト

  @override
  void initState() {
    super.initState();
    _rankingDataFuture = _fetchRankingData();
    _initializeGroupData();
  }

  @override
  void didUpdateWidget(covariant RankingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedTab != oldWidget.selectedTab ||
        widget.selectedCategory != oldWidget.selectedCategory) {
      // カテゴリの変更も監視
      setState(() {
        _rankingDataFuture = _fetchRankingData();
      });
    }
  }

  //グループ名とメンバーidを取得
  Future<void> _initializeGroupData() async {
    _myGroup = await fetchGroup.fetchMyGroup();
    if (_myGroup != null) {
      _groupMemberIds = await fetchGroup.fetchGroupMemberIds();
      print('Group Name: $_myGroup');
      print('Member IDs: $_groupMemberIds');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchRankingData() async {
    try {
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];

      Query query;

      if (widget.selectedTab == 'フォロー中') {
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
      } else if (widget.selectedTab == 'グループ') {
        if (_myGroup == null || _groupMemberIds.isEmpty) return [];

        query = FirebaseFirestore.instance
            .collection('Users')
            .where('auth_uid', whereIn: _groupMemberIds);
      } else{
        query = FirebaseFirestore.instance.collection('Users');
      }

      if (widget.selectedCategory != '全体') {
        query = query.where('following_subjects',
            arrayContains: widget.selectedCategory);
      }

      final querySnapshot = await query.get();

      final List<Map<String, dynamic>> rankingData = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        final loginHistory = data['login_history'] ?? [];
        final todayLogins = loginHistory
            .where((timestamp) =>
                (timestamp as Timestamp).toDate().isAfter(todayStart))
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
                  .doc(doc.id) // 現在のユーザー ID
                  .collection('record') // レコードサブコレクション
                  .doc(formattedDate) // 今日の日付を使ったドキュメント
                  .collection(widget.selectedCategory) // カテゴリ名を使ったサブコレクション
                  .get();

              // すべてのドキュメントから tierProgress_today と tierProgress_all を合計
              double tierProgressToday = 0.0;
              for (final doc in recordDocSnapshot.docs) {
                final data = doc.data();
                tierProgressToday += data['tierProgress_today'] ?? 0;
              }

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
                  .get();

              // すべてのドキュメントから tierProgress_today と tierProgress_all を合計
              double tierProgressToday = 0.0;
              for (final doc in recordDocSnapshot.docs) {
                final data = doc.data();
                tierProgressToday += data['tierProgress_today'] ?? 0;
              }

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

      rankingData
          .sort((a, b) => b['tSolvedCount'].compareTo(a['tSolvedCount']));

      // 同率順位の計算
      int rank = 1;
      for (int i = 0; i < rankingData.length; i++) {
        if (i > 0 &&
            rankingData[i]['tSolvedCount'] ==
                rankingData[i - 1]['tSolvedCount']) {
          rankingData[i]['rank'] = rankingData[i - 1]['rank'];
        } else {
          rankingData[i]['rank'] = rank;
        }
        rank++;
      }

      _userRank = rankingData.firstWhere(
              (user) => user['auth_uid'] == _userData['auth_uid'],
              orElse: () => {'rank': -1})['rank'] ??
          -1;

      return rankingData.take(100).toList();
    } catch (e) {
      print('ランキングデータ取得エラー: $e');
      return [];
    }
  }

  String getSubjectName(String selectedCategory) {
    if (selectedCategory.contains('TOEIC')) {
      return 'TOEIC';
    } else if (selectedCategory.contains('TOEFL')) {
      return 'TOEFL';
    } else if (selectedCategory.contains('英検')) {
      return '英検';
    } else {
      return '英検';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF0ABAB5);
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _rankingDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Shimmer.fromColors(
                baseColor: Colors.grey[700]!,
                highlightColor: Colors.grey[500]!,
                child: Column(
                  children: List.generate(5, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        height: 80,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('データ取得エラー: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // メッセージを表示する条件分岐
          if (widget.selectedTab == 'フォロー中') {
            return const Center(
              child: Text(
                'フォローしているユーザーがいません\n他のユーザーをフォローして競い合おう！',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          } else if (widget.selectedTab == 'グループ') {
            return const Center(
              child: Text(
                'グループに所属していません\nグループに所属し、仲間と高め合おう！',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          } else {
            return const Center(
              child: Text(
                'ランキングデータがありません',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }
        }

          final rankingData = snapshot.data!;

          return Column(
            children: [
              if (_userRank != -1)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    color: themeColor.withOpacity(0.8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.star, color: Colors.white),
                      title: Text(
                        'あなたの順位: $_userRank 位',
                        style: GoogleFonts.roboto(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              Expanded(
                  child: ListView.builder(
                itemCount: rankingData.length,
                itemBuilder: (context, index) {
                  final user = rankingData[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getRankColor(user['rank']),
                      child: Text(
                        '${user['rank']}',
                        style: TextStyle(
                          color: Colors.white, // 視認性のために色変更
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(user['userName']),
                    trailing: Text(
                      '${user['tSolvedCount']} pt',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    
                    onTap: () {
                      // プロフィール表示のコールバックを実行
                      widget.onUserProfileTap(user['auth_uid']);
                   },
                  );
                },
              )),
            ],
          );
        },
      ),
    );
  }
}

Color _getRankColor(int rank) {
  switch (rank) {
    case 1:
      return Colors.amber; // 金
    case 2:
      return Colors.grey; // 銀
    case 3:
      return Colors.brown; // 銅
    default:
      return Color.fromARGB(255, 157, 248, 243); // その他は透明
  }
}
