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
        return Center(
          child: CircularProgressIndicator(
            valueColor:  AlwaysStoppedAnimation<Color>(Color(0xFF0ABAB5)),
          ),
        );
      },
    );

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('ユーザーがログインしていません');
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
        final subCollectionSnapshot = await latestDoc.reference.collection(subCollectionName).get();

        subCollectionData[subCollectionName] = [];

        for (var doc in subCollectionSnapshot.docs) {
          final data = {'docName': doc.id, ...doc.data()};

          // デバッグ: サブコレクションが「TOEICX点」で Word ドキュメントが存在する場合
          if (subCollectionName.startsWith('TOEIC') && doc.id == 'Word') {

            final xMatch = RegExp(r'TOEIC(\d+)点').firstMatch(subCollectionName);
            if (xMatch != null) {
              final xValue = xMatch.group(1);

              final englishSkillsRef = FirebaseFirestore.instance
                  .collection('English_Skills')
                  .doc('TOEIC')
                  .collection('up_to_$xValue')
                  .doc('Words')
                  .collection('Word');

              final englishSkillsDocs = await englishSkillsRef.get();

              for (var englishDoc in englishSkillsDocs.docs) {
                final collectionName = englishDoc.id;

                // 「TOEICX点」サブコレクションの Word ドキュメント内に一致するコレクションが存在する場合
                final toeicSubDocRef = latestDoc.reference.collection(subCollectionName).doc('Word');
                final wordSubDocRef = toeicSubDocRef.collection(collectionName);

                final wordSubCollectionDocs = await wordSubDocRef.get();

                if (wordSubCollectionDocs.docs.isNotEmpty) {

                  // サブコレクションを複製
                  for (var wordSubDoc in wordSubCollectionDocs.docs) {
                    final targetDocRef = recordDocRef
                        .collection('TOEIC${xValue}点')
                        .doc('Word')
                        .collection(collectionName)
                        .doc(wordSubDoc.id);

                    await targetDocRef.set(wordSubDoc.data(), SetOptions(merge: true));
                  }
                }
              }
            }
          }

           // デバッグ: サブコレクションが「TOEICX点」で Word ドキュメントが存在する場合
          if (subCollectionName.startsWith('TOEIC') && doc.id == 'Short_Sentence') {

            final xMatch = RegExp(r'TOEIC(\d+)点').firstMatch(subCollectionName);
            if (xMatch != null) {
              final xValue = xMatch.group(1);

              final englishSkillsRef = FirebaseFirestore.instance
                  .collection('English_Skills')
                  .doc('TOEIC')
                  .collection('up_to_$xValue')
                  .doc('Grammar')
                  .collection('Short_Sentence');

              final englishSkillsDocs = await englishSkillsRef.get();

              for (var englishDoc in englishSkillsDocs.docs) {
                final collectionName = englishDoc.id;

                // 「TOEICX点」サブコレクションの Word ドキュメント内に一致するコレクションが存在する場合
                final toeicSubDocRef = latestDoc.reference.collection(subCollectionName).doc('Short_Sentence');
                final wordSubDocRef = toeicSubDocRef.collection(collectionName);

                final wordSubCollectionDocs = await wordSubDocRef.get();

                if (wordSubCollectionDocs.docs.isNotEmpty) {

                  // サブコレクションを複製
                  for (var wordSubDoc in wordSubCollectionDocs.docs) {
                    final targetDocRef = recordDocRef
                        .collection('TOEIC${xValue}点')
                        .doc('Short_Sentence')
                        .collection(collectionName)
                        .doc(wordSubDoc.id);

                    await targetDocRef.set(wordSubDoc.data(), SetOptions(merge: true));
                  }
                }
              }
            }
          }

          subCollectionData[subCollectionName]?.add(data);
        }
      }
    }

    // 今日のドキュメントが存在するか確認
    final todaySnapshot = await recordDocRef.get();

    if (todaySnapshot.exists) {
      if (goalFieldsToCopy.isNotEmpty) {
        await recordDocRef.update(goalFieldsToCopy);
      }

      for (var entry in subCollectionData.entries) {
        for (var subData in entry.value) {
          final subDocRef = recordDocRef.collection(entry.key).doc(subData['docName']);
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

      await recordDocRef.set(dataToSet);

      for (var entry in subCollectionData.entries) {
        for (var subData in entry.value) {
          final subDocRef = recordDocRef.collection(entry.key).doc(subData['docName']);
          await subDocRef.set(subData, SetOptions(merge: true));
        }
      }

      print('新しいデイリーレコードが作成されました: $formattedDate');
    }
  } catch (e) {
    print('デイリーレコードの作成中にエラーが発生しました: $e');
  }
}
