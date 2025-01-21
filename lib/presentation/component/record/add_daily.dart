import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

Future<void> addDailyRecord(String selectedCategory, BuildContext context) async {
  try {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0ABAB5)),
          ),
        );
      },
    );

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('ユーザーがログインしていません');
      Navigator.pop(context); // ダイアログを閉じる
      return;
    }

    final today = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(today);
    final userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
    final recordCollectionRef = userDocRef.collection('record');
    final recordDocRef = recordCollectionRef.doc(formattedDate);

    // 今日より前の直近のドキュメントを取得
    QuerySnapshot snapshot = await recordCollectionRef
        .orderBy(FieldPath.documentId, descending: true)
        .where(FieldPath.documentId, isLessThan: formattedDate)
        .limit(1)
        .get();

    Map<String, dynamic> goalFieldsToCopy = {};
    Map<String, List<Map<String, dynamic>>> subCollectionData = {};

    // `following_subjects` フィールドを取得
    final userSnapshot = await userDocRef.get();
    final followingSubjects = userSnapshot.data()?['following_subjects'] as List<dynamic>? ?? [];

    if (snapshot.docs.isNotEmpty) {
      final latestDoc = snapshot.docs.first;
      final latestData = latestDoc.data() as Map<String, dynamic>?;

      if (latestData != null) {
        // '_goal' で終わるキーを全て抽出
        latestData.forEach((key, value) {
          if (key.endsWith('_goal')) {
            goalFieldsToCopy[key] = value;
          }
        });
      }

      // following_subjects のサブコレクションのみを取得
      for (var subCollectionName in followingSubjects) {
        final subCollectionSnapshot = await latestDoc.reference
            .collection(subCollectionName)
            .get();

        subCollectionData[subCollectionName] = [];

        // サブコレクションの各ドキュメントをコピー
        for (var doc in subCollectionSnapshot.docs) {
          // もとのデータをコピーしつつ、tierProgress_today を 0 にリセット
          final data = {
            'docName': doc.id,
            ...doc.data(),
            'tierProgress_today': 0, // ここでリセット
          };

          subCollectionData[subCollectionName]?.add(data);

          // TOEIC用のサブサブコレクション（Word, Short_Sentenceなど）対応
          // ここでは doc.id が "Word", "Short_Sentence" などの場合にコピー
          if (subCollectionName.startsWith('TOEIC') && (doc.id == 'Word' || doc.id == 'Short_Sentence')) {
            final xMatch = RegExp(r'TOEIC(\d+)点').firstMatch(subCollectionName);
            if (xMatch != null) {
              final xValue = xMatch.group(1);

              // "Word"の場合
              if (doc.id == 'Word') {
                final englishSkillsRef = FirebaseFirestore.instance
                    .collection('English_Skills')
                    .doc('TOEIC')
                    .collection('up_to_$xValue')
                    .doc('Words')
                    .collection('Word');

                final englishSkillsDocs = await englishSkillsRef.get();

                for (var englishDoc in englishSkillsDocs.docs) {
                  final collectionName = englishDoc.id;

                  // 最新記録の subCollectionName（例：TOEIC600点）/ Word / collectionName
                  final toeicSubDocRef = latestDoc.reference
                      .collection(subCollectionName)
                      .doc('Word')
                      .collection(collectionName);

                  final wordSubCollectionDocs = await toeicSubDocRef.get();

                  // サブサブコレクションのデータをコピー
                  for (var wordSubDoc in wordSubCollectionDocs.docs) {
                    final targetDocRef = recordDocRef
                        .collection('TOEIC${xValue}点')
                        .doc('Word')
                        .collection(collectionName)
                        .doc(wordSubDoc.id);

                    // tierProgress_today = 0 を付与してコピー
                    final newData = {
                      ...wordSubDoc.data(),
                      'tierProgress_today': 0,
                    };
                    await targetDocRef.set(newData, SetOptions(merge: true));
                  }
                }
              }

              // "Idioms"の場合
              if (doc.id == 'Idioms') {
                final englishSkillsRef = FirebaseFirestore.instance
                    .collection('English_Skills')
                    .doc('TOEIC')
                    .collection('up_to_$xValue')
                    .doc('Words')
                    .collection('Idioms');

                final englishSkillsDocs = await englishSkillsRef.get();

                for (var englishDoc in englishSkillsDocs.docs) {
                  final collectionName = englishDoc.id;

                  // 最新記録の subCollectionName（例：TOEIC600点）/ Word / collectionName
                  final toeicSubDocRef = latestDoc.reference
                      .collection(subCollectionName)
                      .doc('Idioms')
                      .collection(collectionName);

                  final wordSubCollectionDocs = await toeicSubDocRef.get();

                  // サブサブコレクションのデータをコピー
                  for (var wordSubDoc in wordSubCollectionDocs.docs) {
                    final targetDocRef = recordDocRef
                        .collection('TOEIC${xValue}点')
                        .doc('Idioms')
                        .collection(collectionName)
                        .doc(wordSubDoc.id);

                    // tierProgress_today = 0 を付与してコピー
                    final newData = {
                      ...wordSubDoc.data(),
                      'tierProgress_today': 0,
                    };
                    await targetDocRef.set(newData, SetOptions(merge: true));
                  }
                }
              }

              // "Short_Sentence"の場合
              if (doc.id == 'Short_Sentence') {
                final englishSkillsRef = FirebaseFirestore.instance
                    .collection('English_Skills')
                    .doc('TOEIC')
                    .collection('up_to_$xValue')
                    .doc('Grammar')
                    .collection('Short_Sentence');

                final englishSkillsDocs = await englishSkillsRef.get();

                for (var englishDoc in englishSkillsDocs.docs) {
                  final collectionName = englishDoc.id;

                  final toeicSubDocRef = latestDoc.reference
                      .collection(subCollectionName)
                      .doc('Short_Sentence')
                      .collection(collectionName);

                  final wordSubCollectionDocs = await toeicSubDocRef.get();
                  for (var wordSubDoc in wordSubCollectionDocs.docs) {
                    final targetDocRef = recordDocRef
                        .collection('TOEIC${xValue}点')
                        .doc('Short_Sentence')
                        .collection(collectionName)
                        .doc(wordSubDoc.id);

                    // tierProgress_today = 0 を付与してコピー
                    final newData = {
                      ...wordSubDoc.data(),
                      'tierProgress_today': 0,
                    };
                    await targetDocRef.set(newData, SetOptions(merge: true));
                  }
                }
              }
            }
          }
        }
      }
    }

    // 今日のドキュメントが存在するか確認
    final todaySnapshot = await recordDocRef.get();

    if (todaySnapshot.exists) {
      // 目標フィールドを更新
      if (goalFieldsToCopy.isNotEmpty) {
        await recordDocRef.update(goalFieldsToCopy);
      }

      // サブコレクションをコピー
      for (var entry in subCollectionData.entries) {
        for (var subData in entry.value) {
          // subDataにも tierProgress_today=0 が含まれている
          final subDocRef = recordDocRef
              .collection(entry.key)
              .doc(subData['docName']);
          await subDocRef.set(subData, SetOptions(merge: true));
        }
      }

      print('今日のデイリーレコードが更新されました: $formattedDate');
    } else {
      final dataToSet = {
        'createdAt': FieldValue.serverTimestamp(),
        't_solved_count': 0,
        ...goalFieldsToCopy,
      };

      // 新しいドキュメント作成
      await recordDocRef.set(dataToSet);

      // サブコレクションをコピー
      for (var entry in subCollectionData.entries) {
        for (var subData in entry.value) {
          final subDocRef = recordDocRef
              .collection(entry.key)
              .doc(subData['docName']);
          await subDocRef.set(subData, SetOptions(merge: true));
        }
      }

      print('新しいデイリーレコードが作成されました: $formattedDate');
    }
  } catch (e) {
    print('デイリーレコードの作成中にエラーが発生しました: $e');
  } finally {
    // プログレスダイアログを閉じる
    Navigator.of(context).pop();
  }
}
