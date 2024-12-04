import '/import.dart';

Future<void> addLoginHistory(String userId) async {
    final now = DateTime.now(); // 現在の日付
    final today = DateTime(now.year, now.month, now.day); // 時間を切り捨てた日付

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final loginHistory = userDoc.data()?['login_history'] as List<dynamic>?;

        if (loginHistory != null) {
          // 日付が既に存在するかチェック
          final hasToday = loginHistory.any((timestamp) {
            final date = (timestamp as Timestamp).toDate();
            final dateOnly = DateTime(date.year, date.month, date.day);
            return dateOnly == today;
          });

          if (hasToday) {
            print('本日のログイン履歴は既に存在します');
            return;
          }
        }
      }

      // ログイン履歴を追加
      await FirebaseFirestore.instance.collection('Users').doc(userId).update({
        'login_history': FieldValue.arrayUnion([Timestamp.fromDate(now)]),
         't_solved_count': 0, //解いた問題数 を 0 にリセット
      });
      print('本日のログイン履歴が追加されました');
    } catch (e) {
      print('エラー: $e');
    }
  }