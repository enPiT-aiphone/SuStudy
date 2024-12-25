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

    // 今日より前の直近のドキュメントを取得
    QuerySnapshot snapshot = await recordCollectionRef
        .orderBy(FieldPath.documentId, descending: true) // 日付順で降順
        .where(FieldPath.documentId, isLessThan: formattedDate) // 今日より前
        .limit(1) // 直近の1件
        .get();

    Map<String, dynamic> goalFieldsToCopy = {};
    List<Map<String, dynamic>> subCollectionData = [];

    if (snapshot.docs.isNotEmpty) {
      final latestDoc = snapshot.docs.first;
      final latestData = latestDoc.data() as Map<String, dynamic>?; // 型を明示的にキャスト
      if (latestData != null) {
        // '_goal' で終わるキーを全て抽出
        latestData.forEach((key, value) {
          if (key.endsWith('_goal')) {
            goalFieldsToCopy[key] = value;
          }
        });
      }

      // サブコレクションのデータを取得
      final subCollectionSnapshot = await latestDoc.reference.collection(selectedCategory).get();
      for (var subDoc in subCollectionSnapshot.docs) {
        final subDocData = subDoc.data();
        if (subDocData.containsKey('tierProgress_all')) {
          subCollectionData.add({
            'subCollectionName': selectedCategory,
            'docName': subDoc.id,
            'tierProgress_all': subDocData['tierProgress_all'],
          });
        }
      }
    }

    // 今日のドキュメントが存在するか確認
    final todaySnapshot = await recordDocRef.get();

    if (todaySnapshot.exists) {
      // 既存データがある場合、前日のゴールフィールドが存在する場合のみ更新
      if (goalFieldsToCopy.isNotEmpty) {
        await recordDocRef.update(goalFieldsToCopy);
      }

      // サブコレクションにデータを追加
      for (var subData in subCollectionData) {
        final subDocRef = recordDocRef
            .collection(subData['subCollectionName'])
            .doc(subData['docName']);

        await subDocRef.set({
          'tierProgress_all': subData['tierProgress_all'],
        }, SetOptions(merge: true));
      }

      print('今日のデイリーレコードが更新されました: $formattedDate');
    } else {
      // データが存在しない場合、新規作成し、前日のゴールフィールドをコピー
      final dataToSet = {
        'createdAt': FieldValue.serverTimestamp(), // サーバータイムスタンプ
        't_solved_count': 0, // 初期値として 0 を設定
        ...goalFieldsToCopy, // ゴールフィールドを追加
      };

      await recordDocRef.set(dataToSet);

      // サブコレクションにデータを追加
      for (var subData in subCollectionData) {
        final subDocRef = recordDocRef
            .collection(subData['subCollectionName'])
            .doc(subData['docName']);

        await subDocRef.set({
          'tierProgress_all': subData['tierProgress_all'],
        }, SetOptions(merge: true));
      }

      print('新しいデイリーレコードが作成されました: $formattedDate');
    }
  } catch (e) {
    print('デイリーレコードの作成中にエラーが発生しました: $e');
  }
}
