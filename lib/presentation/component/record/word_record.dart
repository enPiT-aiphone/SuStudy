import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizRecordTOEIC {
  // クイズ結果を保存するメソッド
  Future<void> saveQuizResult({
    required String quizId,
    required String selectedAnswer,
    required String correctAnswer,
    required bool isCorrect,
    required String wordId,
    required Map<String, dynamic> additionalData,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      print('ログイン中のユーザーがいません');
      return;
    }

    try {
      // Firestoreの参照を取得
      final userDoc = FirebaseFirestore.instance.collection('Users').doc(userId);

      // サブコレクション「QuizRecords_TOEIC」にデータを追加
      await userDoc.collection('QuizRecords_TOEIC').add({
        'quiz_id': quizId,
        'timestamp': FieldValue.serverTimestamp(),
        'selected_answer': selectedAnswer,
        'correct_answer': correctAnswer,
        'is_correct': isCorrect,
        'word_id': wordId,
        ...additionalData, // その他のデータを展開して保存
      });

      print('TOEICクイズ結果が保存されました: $quizId');
    } catch (e) {
      print('TOEICクイズ結果の保存に失敗しました: $e');
    }
  }
}



class QuizRecordTOEFL {
  // クイズ結果を保存するメソッド
  Future<void> saveQuizResult({
    required String quizId,
    required String selectedAnswer,
    required String correctAnswer,
    required bool isCorrect,
    required String wordId,
    required Map<String, dynamic> additionalData,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      print('ログイン中のユーザーがいません');
      return;
    }

    try {
      // Firestoreの参照を取得
      final userDoc = FirebaseFirestore.instance.collection('Users').doc(userId);

      // サブコレクション「QuizRecords_TOEFL」にデータを追加
      await userDoc.collection('QuizRecords_TOEFL').add({
        'quiz_id': quizId,
        'timestamp': FieldValue.serverTimestamp(),
        'selected_answer': selectedAnswer,
        'correct_answer': correctAnswer,
        'is_correct': isCorrect,
        'word_id': wordId,
      });

      print('TOEFLクイズ結果が保存されました: $quizId');
    } catch (e) {
      print('TOEFLクイズ結果の保存に失敗しました: $e');
    }
  }
}