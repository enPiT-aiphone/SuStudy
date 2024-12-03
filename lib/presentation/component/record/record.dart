import 'package:flutter/material.dart';
import '/import.dart';
import 'record_TOEIC.dart'; // record_TOEIC.dart をインポート
import 'record_TOEFL.dart'; // record_TOEFL.dart をインポート

class LanguageCategoryScreen extends StatelessWidget {
  final String selectedCategory; // _selectedCategory を受け取る
  final VoidCallback? onClose; // onClose コールバック

  LanguageCategoryScreen({
    required this.selectedCategory,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedCategory.contains('全体'))
    return Scaffold(
      body: Center(
        child: Text(
          '勉強するカテゴリーを下から選択してください',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
    // カテゴリが "TOEIC" の場合
    if (selectedCategory.contains('TOEIC')) {
      return LanguageTOEICScreen(selectedCategory: selectedCategory);
    }
    // カテゴリが "TOEFL" の場合
    else if (selectedCategory.contains('TOEFL')) {
      return LanguageTOEFLScreen(selectedCategory: selectedCategory);
    }
    // その他のカテゴリ
    return Scaffold(
      body: Center(
        child: Text(
          '$selectedCategory のカテゴリーは未実装です',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
