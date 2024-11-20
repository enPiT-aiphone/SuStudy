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
    '文法': ['長文', '短文'],
    '単語': ['イディオム', '単語'],
    'リスニング': ['Part1', 'Part2', 'Part3', 'Part4',],
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
              // オーバーレイを表示
              showGeneralDialog(
                context: context,
                barrierDismissible: true,
                barrierLabel: '',
                pageBuilder: (context, animation1, animation2) {
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: MediaQuery.of(context).size.width, // 横幅を画面いっぱいに設定
                      height: MediaQuery.of(context).size.height * 0.88, // 高さを9割に設定
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20), // 上部の角を丸くする
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent, // 背景を透明に設定
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20), // 上部の角を丸くする
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: ListView(
                            children: subCategories[primaryCategories[index]]!
                                .map((subCategory) {
                              return ListTile(
                                title: Text(subCategory),
                                onTap: () {
                                  // 「単語（再確認）」を選んだ場合に特別な処理を追加
                                  if (primaryCategories[index] == '単語' &&
                                      subCategory == '単語') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TOEICWordQuiz(
                                            level: problemLevel), // 問題レベルを渡す
                                      ),
                                    );
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                transitionBuilder: (context, animation1, animation2, child) {
                  return SlideTransition(
                    position: Tween(
                      begin: Offset(0, 1),
                      end: Offset(0, 0),
                    ).animate(animation1),
                    child: child,
                  );
                },
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
  final ScrollController scrollController; // スクロールコントローラ

  SubCategoryScreen({
    required this.category,
    required this.subCategories,
    required this.selectedCategory,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController, // スクロールコントローラを設定
      itemCount: subCategories.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(subCategories[index]),
          onTap: () {
            // 「単語（再確認）」を選んだ場合に特別な処理を追加
            if (category == '単語' && subCategories[index] == '単語') {
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
    );
  }
}
