import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizReviewScreen extends StatefulWidget {
  const QuizReviewScreen({super.key});

  @override
  _QuizReviewScreenState createState() => _QuizReviewScreenState();
}

class _QuizReviewScreenState extends State<QuizReviewScreen> {
  // ユーザーが間違えた問題を保持するリスト
  List<Map<String, dynamic>> incorrectQuestions = [];

  @override
  void initState() {
    super.initState();
    _fetchIncorrectQuestions();
  }

  // Firebaseから間違えた問題を取得するメソッド
  Future<void> _fetchIncorrectQuestions() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      print('ユーザーがログインしていません');
      return;
    }

    try {
      // Firestoreからユーザー情報を取得
      final userDoc =
          FirebaseFirestore.instance.collection('Users').doc(userId);
      final userSnapshot = await userDoc.get();

      if (!userSnapshot.exists) {
        print('ユーザー情報が見つかりません');
        return;
      }

      // Usersドキュメントのfollowing_subjectsフィールドからTOEICのスコアを取得
      final followingSubjects = List<String>.from(
          userSnapshot.data()?['following_subjects'] ?? []);

      // TOEICX点のXを抽出
      final matchedScore = followingSubjects
          .firstWhere((subject) => subject.startsWith('TOEIC'), orElse: () => '');
      if (matchedScore.isEmpty) {
        print('TOEICスコアが見つかりません');
        return;
      }
      final score = matchedScore.replaceAll('TOEIC', ''); // スコア部分だけ抽出

      // TOEICのup_to_Xコレクション参照
      final toeicDoc = userDoc
          .collection('following_subjects')
          .doc('TOEIC')
          .collection('up_to_$score');

      // Wordsのサブコレクションから間違えた問題を取得
      final wordsCollectionRef = toeicDoc.doc('Words').collection('Word');
      final incorrectWordsSnapshot = await wordsCollectionRef
          .where('is_correct', isEqualTo: false) // 間違えた問題をフィルタリング
          .orderBy('timestamp', descending: true) // 最新のものから取得
          .limit(5) // 必要に応じて取得する数を調整
          .get();

      // 取得したデータをリストに変換
      setState(() {
        incorrectQuestions = incorrectWordsSnapshot.docs.map((doc) {
          return {
            'quiz_id': doc['quiz_id'],
            'selected_answer': doc['selected_answer'],
            'correct_answer': doc['correct_answer'],
            'timestamp': doc['timestamp'],
            'word_id': doc['word_id'],
          };
        }).toList();
      });
    } catch (e) {
      print('エラーが発生しました: $e');
    }
  }

  // Firebaseに間違えた問題を保存するメソッド
  Future<void> saveIncorrectQuestion(
      String quizId, String selectedAnswer, String correctAnswer, String wordId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      print('ユーザーがログインしていません');
      return;
    }

    try {
      // Firestoreからユーザー情報を取得
      final userDoc =
          FirebaseFirestore.instance.collection('Users').doc(userId);
      final userSnapshot = await userDoc.get();

      if (!userSnapshot.exists) {
        print('ユーザー情報が見つかりません');
        return;
      }

      // Usersドキュメントのfollowing_subjectsフィールドからTOEICのスコアを取得
      final followingSubjects = List<String>.from(
          userSnapshot.data()?['following_subjects'] ?? []);

      // TOEICX点のXを抽出
      final matchedScore = followingSubjects
          .firstWhere((subject) => subject.startsWith('TOEIC'), orElse: () => '');
      if (matchedScore.isEmpty) {
        print('TOEICスコアが見つかりません');
        return;
      }
      final score = matchedScore.replaceAll('TOEIC', ''); // スコア部分だけ抽出

      // TOEICのup_to_Xコレクション参照
      final toeicDoc = userDoc
          .collection('following_subjects')
          .doc('TOEIC')
          .collection('up_to_$score');

      // Wordsのサブコレクションに問題を保存
      final wordsCollectionRef = toeicDoc.doc('Words').collection('Word');
      await wordsCollectionRef.doc(wordId).set({
        'quiz_id': quizId,
        'selected_answer': selectedAnswer,
        'correct_answer': correctAnswer,
        'timestamp': FieldValue.serverTimestamp(),
        'is_correct': false, // 間違えた問題
        'word_id': wordId,
      }, SetOptions(merge: true)); // 上書き保存
    } catch (e) {
      print('エラーが発生しました: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('間違えた問題の復習'),
      ),
      body: incorrectQuestions.isEmpty
          ? const Center(child: CircularProgressIndicator(valueColor:  AlwaysStoppedAnimation<Color>(Color(0xFF0ABAB5)),))
          : ListView.builder(
              itemCount: incorrectQuestions.length,
              itemBuilder: (context, index) {
                final question = incorrectQuestions[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('問題 ID: ${question['quiz_id']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('選んだ答え: ${question['selected_answer']}'),
                        Text('正しい答え: ${question['correct_answer']}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () {
                        // 詳細ページに遷移する場合
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
