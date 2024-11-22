import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizReviewScreen extends StatefulWidget {
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
      // Firestoreから間違えた問題を取得
      final userDoc = FirebaseFirestore.instance.collection('Users').doc(userId);
      final quizRecordsRef = userDoc.collection('QuizRecords_TOEIC'); // 例としてTOEIC
      final incorrectQuizSnapshot = await quizRecordsRef
          .where('is_correct', isEqualTo: false) // 間違えた問題をフィルタリング
          .orderBy('timestamp', descending: true) // 最新のものから取得
          .limit(5) // 必要に応じて取得する数を調整
          .get();

      // 取得したデータをリストに変換
      setState(() {
        incorrectQuestions = incorrectQuizSnapshot.docs.map((doc) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('間違えた問題の復習'),
      ),
      body: incorrectQuestions.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: incorrectQuestions.length,
              itemBuilder: (context, index) {
                final question = incorrectQuestions[index];
                return Card(
                  margin: EdgeInsets.all(8),
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
                      icon: Icon(Icons.arrow_forward),
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
