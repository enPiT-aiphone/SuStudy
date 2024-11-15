import 'package:flutter/material.dart';
import 'toeic_level_selection.dart';
import '/import.dart';

class LanguageCategoryScreen extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('カテゴリー選択'),
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

  SubCategoryScreen({required this.category, required this.subCategories});

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
                    builder: (context) => TOEICWordQuiz(level: 'up_to_700'),  // 700点レベルに遷移//TOEICLevelSelection(),
                  ),
                );
              // } else {
              //   // その他の通常のサブカテゴリー選択時の処理
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) => CategoryDetailScreen(
              //         category: subCategories[index],
              //       ),
              //     ),
              //   );
               }
            },
          );
        },
      ),
    );
  }
}
void main() => runApp(MaterialApp(
      home: LanguageCategoryScreen(),
    ));