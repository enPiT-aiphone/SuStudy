import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

Future<void> addDailyRecord(String selectedCategory) async {
  try {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('ユーザーがログインしていません');
      return;
    }

    // Firestore ドキュメントパスの作成
    final today = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(today); // yyyy-MM-dd形式の日付
    final recordCollectionRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('record');

    final recordDocRef = recordCollectionRef.doc(formattedDate); // 今日の日付のドキュメント

    // ゴールフィールドの名前を動的に作成 (例: TOEIC500点_goal)
    final goalField = "${selectedCategory}_goal";

    // 1日前の日付を計算
    final yesterday = today.subtract(Duration(days: 1));
    final formattedYesterday = DateFormat('yyyy-MM-dd').format(yesterday);

    // 1日前のドキュメントを取得
    final yesterdayDocRef = recordCollectionRef.doc(formattedYesterday);
    final yesterdaySnapshot = await yesterdayDocRef.get();

    // 1日前のゴール値を取得（存在しない場合は 0）
    int previousGoal = 0;
    if (yesterdaySnapshot.exists) {
      previousGoal = yesterdaySnapshot.data()?[goalField] ?? 0;
    }

    // 今日のデータを作成
    await recordDocRef.set({
      'timestamp': FieldValue.serverTimestamp(), // サーバータイムスタンプ
      't_solved_count': 0, // 初期値として 0 を設定
      goalField: previousGoal, // 前日のゴール値をコピー
    });

    // t_solved_count をリセット
    await FirebaseFirestore.instance.collection('Users').doc(userId).update({
      't_solved_count': 0, // 解いた問題数をリセット
    });

    print('デイリーレコードが作成されました: $formattedDate, $goalField: $previousGoal');
  } catch (e) {
    print('デイリーレコードの作成中にエラーが発生しました: $e');
  }
}
