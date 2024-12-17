import 'package:flutter/material.dart';
import '/import.dart';
import 'record_TOEIC.dart'; // record_TOEIC.dart をインポート
import 'record_TOEFL.dart'; // record_TOEFL.dart をインポート

class LanguageCategoryScreen extends StatelessWidget {
  final String selectedCategory; // _selectedCategory を受け取る
  final VoidCallback? onClose; // onClose コールバック
  final Widget categoryBar;

  LanguageCategoryScreen({
    required this.selectedCategory,
    this.onClose,
    required this.categoryBar,
  });

  @override
  Widget build(BuildContext context) {
    // メインの画面
    return Scaffold(
      body: Stack(
        children: [
          // メインのコンテンツ
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (selectedCategory.contains('全体')) {
                        return Center(
                          child: Text(
                            '勉強するカテゴリーを下から選択してください',
                            style: TextStyle(fontSize: 18),
                          ),
                        );
                      }
                      // カテゴリが "TOEIC" の場合
                      if (selectedCategory.contains('TOEIC')) {
                        return LanguageTOEICScreen(selectedCategory: selectedCategory);
                      }
                      // カテゴリが "TOEFL" の場合
                      else if (selectedCategory.contains('TOEFL')) {
                        return LanguageTOEFLScreen(selectedCategory: selectedCategory);
                      }
                      // その他のカテゴリ
                      return Center(
                        child: Text(
                          '$selectedCategory のカテゴリーは未実装です',
                          style: TextStyle(fontSize: 18),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // カテゴリバーを画面下部に配置
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.only(bottom: 10.0),
              child: categoryBar,
            ),
          ),
        ],
      ),
    );
  }
}
