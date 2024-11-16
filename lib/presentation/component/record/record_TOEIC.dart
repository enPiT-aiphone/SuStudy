import 'package:flutter/material.dart';
import '/import.dart';

class LanguageTOEICScreen extends StatelessWidget {
  final String selectedCategory; // _selectedCategory を受け取る

  LanguageTOEICScreen({required this.selectedCategory});

  final List<String> primaryCategories = [
    '文法',
    '単語',
    'リスニング',
  ];

  final Map<String, List<String>> subCategories = {
    '文法': ['イディオム', '単語（再確認）'],
    '単語': ['イディオム', '単語（再確認）'],
    'リスニング': ['イディオム', '単語（再確認）'],
  };

  // カテゴリーに基づく問題レベルを取得する関数
  String getProblemLevel() {
    switch (selectedCategory) {
      case 'TOEIC300点':
        return 'up_to_300';
      case 'TOEIC500点':
        return 'up_to_500';
      case 'TOEIC700点':
        return 'up_to_700';
      case 'TOEIC900点':
        return 'up_to_900';
      case 'TOEIC990点':
        return 'up_to_990';
      default:
        return 'unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    String problemLevel = getProblemLevel(); // 問題レベルを取得

    return Scaffold(
      appBar: AppBar(
        title: Text('$selectedCategory の問題'),
      ),
      body: ListView.builder(
        itemCount: primaryCategories.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(primaryCategories[index]),
            onTap: () {
              // 次の階層へ遷移
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubCategoryScreen(
                    category: primaryCategories[index],
                    subCategories: subCategories[primaryCategories[index]] ?? [],
                    selectedCategory: problemLevel, // 問題レベルを渡す
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class SubCategoryScreen extends StatelessWidget {
  final String category;
  final List<String> subCategories;
  final String selectedCategory; // 問題レベルを受け取る

  SubCategoryScreen({
    required this.category,
    required this.subCategories,
    required this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$category のサブカテゴリー'),
      ),
      body: ListView.builder(
        itemCount: subCategories.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(subCategories[index]),
            onTap: () {
              // 「単語（再確認）」を選んだ場合に特別な処理を追加
              if (category == '単語' && subCategories[index] == '単語（再確認）') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TOEICWordQuiz(level: selectedCategory), // 問題レベルを渡す
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}

void main() => runApp(MaterialApp(
      home: LanguageTOEICScreen(selectedCategory: 'TOEIC700点'), // 初期選択カテゴリーを設定
    ));
