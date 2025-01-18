import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

Future<Map<String, double>> fetchTierProgress(userId, String category) async {
  try {
    // ユーザードキュメントを取得
    final userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .get();

    if (!userDoc.exists) {
      print('ユーザードキュメントが見つかりません');
      return {'normalizedTierProgress': 0.0, 'normalizedTierProgressAll': 0.0};
    }

    final followingSubjects =
        List<String>.from(userDoc.data()?['following_subjects'] ?? []);

    double wordCount = 0.0;
    if (category == '全体') {
      for (final subject in followingSubjects) {
        wordCount += getTotalMinutes(subject);
      }
    } else {
      wordCount = getTotalMinutes(category);
    }

    final today = DateTime.now();
    final todayDate = DateFormat('yyyy-MM-dd').format(today);

    double tierProgress = 0;
    double tierProgressAll = 0;

    if (category == '全体') {
      for (final subject in followingSubjects) {
        final categoryCollectionSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection('record')
            .doc(todayDate)
            .collection(subject)
            .get();

        for (final doc in categoryCollectionSnapshot.docs) {
          final data = doc.data();
          tierProgress += data['tierProgress_today'] ?? 0;
          tierProgressAll += data['tierProgress_all'] ?? 0;
        }
      }
    } else {
      final categoryCollectionSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('record')
          .doc(todayDate)
          .collection(category)
          .get();

      for (final doc in categoryCollectionSnapshot.docs) {
        final data = doc.data();
        tierProgress += data['tierProgress_today'] ?? 0;
        tierProgressAll += data['tierProgress_all'] ?? 0;
      }
    }

    final todayWordsGoalDocRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('record')
        .doc(todayDate);

    final todayWordsGoalDocSnapshot = await todayWordsGoalDocRef.get();
    final tierProgressTodayGoal = todayWordsGoalDocSnapshot.data()?['${category}_goal'] ?? 0;
    double tierProgressGoal = 0;
    for (final category in followingSubjects) {
      tierProgressGoal += todayWordsGoalDocSnapshot.data()?['${category}_goal'] ?? 0;
    }

    double normalizedTierProgressAll;
    double normalizedTierProgress;

    if (category == '全体') {
      normalizedTierProgressAll = tierProgressAll / wordCount;
      normalizedTierProgress = tierProgress / tierProgressGoal;
    } else {
      normalizedTierProgressAll = tierProgressAll / wordCount;
      normalizedTierProgress = tierProgress / tierProgressTodayGoal;
    }

    return {
      'normalizedTierProgress': normalizedTierProgress,
      'normalizedTierProgressAll': normalizedTierProgressAll,
    };
  } catch (e) {
    print('normalizedTierProgressAll 計算エラー: $e');
    return {'normalizedTierProgress': 0.0, 'normalizedTierProgressAll': 0.0};
  }
}

  double getTotalMinutes(String category) {
    if (category == 'TOEIC300点'){
      return 5+10;
    }
    else if (category == 'TOEIC500点'){
      return 27+33+28;
    }
    else if (category == 'TOEIC700点'){
      return 39.5+8;
    }
    else if (category == 'TOEIC900点'){
      return 48+15+45;
    }
    else if (category == 'TOEIC990点'){
      return 50+8;
    }
    else{
      return 1;
    }
  }