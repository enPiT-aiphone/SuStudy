import 'package:flutter/material.dart';
import '/import.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'problem_toeic_word.dart';
import 'problem_toeic_short_sentence.dart';

class LanguageTOEICScreen extends StatefulWidget {
  final String selectedCategory;

  const LanguageTOEICScreen({super.key, required this.selectedCategory});

  @override
  _LanguageTOEICScreenState createState() => _LanguageTOEICScreenState();
}

class _LanguageTOEICScreenState extends State<LanguageTOEICScreen> {
  String selectedQuestionType = ''; // 選択された質問タイプを保持

  final List<String> primaryCategories = [
    '文法',
    '単語',
    'リスニング',
  ];

  final Map<String, List<String>> subCategories = {
    '文法': ['      長文', '      短文'],
    '単語': ['      単語', '      イディオム'],
    'リスニング': ['      Part1', '     Part2', '     Part3', '     Part4'],
  };

  final Map<String, String> categoryImages = {
    '文法': 'images/grammar.png',
    '単語': 'images/word.png',
    'リスニング': 'images/listening.png',
  };

  // カテゴリーに基づく問題レベルを取得する関数
  String getProblemLevel() {
    switch (widget.selectedCategory) {
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
    String problemLevel = getProblemLevel();

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 40),
          _buildTextLabel(context, "${widget.selectedCategory} の問題"),
          const SizedBox(height: 40),
          Expanded(
            child: ListView.builder(
              itemCount: primaryCategories.length,
              itemBuilder: (context, index) {
                String category = primaryCategories[index];
                return Column(
                  children: [
                    ExpansionTile(
                      leading: Image.asset(
                        categoryImages[category]!,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                      title: Text(category),
                      children: subCategories[category]!
                          .map((subCategory) {
                            return ListTile(
                              title: Text(subCategory),
                              onTap: () {
                                if (category == '単語' && subCategory == '      単語') {
                                  _showOverlay(context, problemLevel,category,subCategory);
                                }
                                else if (category == '文法' && subCategory == '      短文'){
                                  _showOverlay(context, problemLevel,category,subCategory);
                                }
                              }
                            );
                          })
                          .toList(),
                    ),
                    const SizedBox(height: 10), // 各カテゴリ間の間隔を広げる
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextLabel(BuildContext context, String label) {
    final double buttonWidth = MediaQuery.of(context).size.width * 0.75;

    return Container(
      width: buttonWidth,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF0ABAB5)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF0ABAB5),
          fontSize: 18,
        ),
      ),
    );
  }

  // オーバーレイを表示する
  void _showOverlay(BuildContext context, String problemLevel,String category, String subCategory) {
    // 初期値として「ランダム」を選択
    String? selectedOption = 'random';

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (context, animation1, animation2) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Expanded(
                      child: Column(
                        children: [
                          _buildSelectableOption(
                            context,
                            'ランダム',
                            selectedOption == 'random',
                            () {
                              setState(() {
                                selectedOption = 'random';
                              });
                            },
                          ),
                          _buildSelectableOption(
                            context,
                            '未学習',
                            selectedOption == 'unanswered',
                            () {
                              setState(() {
                                selectedOption = 'unanswered';
                              });
                            },
                          ),
                          _buildSelectableOption(
                            context,
                            '直近誤答',
                            selectedOption == 'incorrect',
                            () {
                              setState(() {
                                selectedOption = 'incorrect';
                              });
                            },
                          ),
                          _buildSelectableOption(
                            context,
                            'うろ覚え',
                            selectedOption == 'recent_incorrect',
                            () {
                              setState(() {
                                selectedOption = 'recent_incorrect';
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    _buildStartButton(
                      context,
                      'スタート',
                      selectedOption != null
                          ? () {
                              Navigator.pop(context); // オーバーレイを閉じる
                              if (category == '単語' && subCategory == '      単語') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TOEICWordQuiz(
                                      level: problemLevel,
                                      questionType: selectedOption!,
                                    ), 
                                  ),
                                );
                              } else if (category == '文法' && subCategory == '      短文') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TOEICShort_SentenceQuiz(
                                      level: problemLevel,
                                      questionType: selectedOption!,
                                    ),
                                  ),
                                );
                              }
                            }
                          : null, // チェックがない場合は無効
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        );
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(0, 1),
            end: const Offset(0, 0),
          ).animate(animation1),
          child: child,
        );
      },
    );
  }

 Widget _buildSelectableOption(
  BuildContext context,
  String label,
  bool isSelected,
  VoidCallback onTap,
) {
  final double buttonWidth = MediaQuery.of(context).size.width * 0.75; // ボタンの幅を画面の0.75倍に設定

  return Material(
    color: Colors.transparent, // 背景色を透明に設定
    child: InkWell(
      onTap: onTap,
      child: Container(
        width: buttonWidth,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 15),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: isSelected ? const Color(0xFF0ABAB5) : Colors.grey),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF0ABAB5) : Colors.grey.shade600,
            fontSize: 18,
          ),
        ),
      ),
    ),
  );
}

Widget _buildStartButton(BuildContext context, String label, VoidCallback? onPressed) {
  final double buttonWidth = MediaQuery.of(context).size.width * 0.75;

  return Material(
    color: Colors.transparent, // 背景色を透明に設定
    child: InkWell(
      onTap: onPressed,
      child: Container(
        width: buttonWidth,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 15),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0ABAB5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    ),
  );
}

}
