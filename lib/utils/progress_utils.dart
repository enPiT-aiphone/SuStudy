import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

Future<double> fetchTierProgress(String userId, String selectedCategory) async {
  try {
    final category = selectedCategory == '全体' ? 'TOEIC500点' : selectedCategory;

    // ユーザードキュメントを取得
    final userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .get();

    if (!userDoc.exists) {
      print('ユーザードキュメントが見つかりません');
      return 0;
    }

    final followingSubjects =
        List<String>.from(userDoc.data()?['following_subjects'] ?? []);

    // TOEICスコア部分を抽出
    final toeicSubject = followingSubjects.firstWhere(
      (subject) => subject.startsWith('TOEIC'),
      orElse: () => '',
    );

    if (toeicSubject.isEmpty) {
      print('TOEIC情報がありません');
      return 0;
    }

    final scoreMatch = RegExp(r'\d+').firstMatch(toeicSubject);
    if (scoreMatch == null) {
      print('TOEICスコアの形式が不正です');
      return 0;
    }

    final today = DateTime.now();
    final todayDate =
        DateFormat('yyyy-MM-dd').format(today); // フォーマットされた今日の日付
    final todayWordsDocRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('record')
        .doc(todayDate)
        .collection(category) // 選択されたカテゴリを使用
        .doc('Word');

    final todayWordsDocSnapshot = await todayWordsDocRef.get();
    final tierProgressToday =
        todayWordsDocSnapshot.data()?['tierProgress_today'] ?? 0;
    final tierProgressAll =
        todayWordsDocSnapshot.data()?['tierProgress_all'] ?? 0;

    final todayWordsGoalDocRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('record')
        .doc(todayDate);

    final todayWordsGoalDocSnapshot = await todayWordsGoalDocRef.get();
    final tierProgressTodayGoal =
        todayWordsGoalDocSnapshot.data()?['${category}_goal'] ?? 0;

    final normalizedTierProgress =
        tierProgressToday / (tierProgressTodayGoal * 2);

    print('目標への達成度: ${tierProgressAll / 100}'); // デバッグ用ログ
    return normalizedTierProgress;
  } catch (e) {
    print('fetchTierProgress エラー: $e');
    return 0;
  }
}

