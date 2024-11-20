import 'package:flutter/material.dart';
import '/import.dart';
import 'record_TOEIC.dart'; // record_TOEIC.dart をインポート
import 'record_TOEFL.dart'; // record_TOEFL.dart をインポート


class LanguageCategoryScreen extends StatelessWidget {
  final String selectedCategory; // _selectedCategory を受け取る

  LanguageCategoryScreen({required this.selectedCategory});

  @override
  Widget build(BuildContext context) {
    // カテゴリが "TOEIC" の場合は LanguageTOEICScreen を表示
    if (selectedCategory.contains('TOEIC')) {
      return LanguageTOEICScreen(selectedCategory: selectedCategory);
    }
    else if (selectedCategory.contains('TOEFL')) {
      return LanguageTOEFLScreen(selectedCategory: selectedCategory);
    }

    // その他のカテゴリの場合は、デフォルトの画面を表示
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
