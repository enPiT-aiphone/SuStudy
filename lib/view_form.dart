import 'import.dart'; 

class ViewFormSelection extends StatelessWidget {
  const ViewFormSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0ABAB5),  // AppBarの色を設定
        title: Row(
          children: const [
            Text(
              'SuStudy,',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: const Color(0xFF0ABAB5),
              ),
              child: Text(
                '管理するデータを選んでください',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            // 中学校
            ExpansionTile(
  title: const Text('中学校'),
  children: <Widget>[
    ListTile(
      title: const Text('     国語'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('中学校 - 国語 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('     数学'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('中学校 - 数学 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('     理科'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('中学校 - 理科 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('     社会'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('中学校 - 社会 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('     英語'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('中学校 - 英語 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
  ],
),
            // 高校
            ExpansionTile(
  title: const Text('高校'),
  children: <Widget>[
    ExpansionTile(
  title: const Text('     国語'),
  children: <Widget>[
    ListTile(
      title: const Text('           評論'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('高校 - 国語 評論 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('           小説'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('高校 - 国語 小説 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('           古文'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('高校 - 国語 古文 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('           漢文'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('高校 - 国語 漢文 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
  ],
),
    ExpansionTile(
  title: const Text('     数学'),
  children: <Widget>[
    ExpansionTile(
  title: const Text('           IA'),
  children: <Widget>[
    ListTile(
      title: const Text('                I'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('高校 - 数学 I のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('                A'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('高校 - 数学 A のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
  ],
    ),
    ExpansionTile(
  title: const Text('           IIB'),
  children: <Widget>[
    ListTile(
      title: const Text('                II'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('高校 - 数学 II のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('                B'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('高校 - 数学 B のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
  ],
    ),
    ListTile(
      title: const Text('           III'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('高校 - 数学 III のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
  ],
),
ExpansionTile(
  title: const Text('     理科'),
  children: <Widget>[
    ExpansionTile(
  title: const Text('           物理'),
  children: <Widget>[
    ListTile(
      title: const Text('                 物理'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('高校 - 理科 物理 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('                 物理基礎'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('高校 - 理科 物理基礎 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
  ],
),
    ExpansionTile(
  title: const Text('           化学'),
  children: <Widget>[
    ListTile(
      title: const Text('                 化学'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('高校 - 理科 化学 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('                 化学基礎'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('高校 - 理科 化学基礎 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
  ],
),
    ExpansionTile(
  title: const Text('           生物'),
  children: <Widget>[
    ListTile(
      title: const Text('                 生物'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('高校 - 理科 生物 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('                 生物基礎'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('高校 - 理科 生物基礎 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
  ],
),
ExpansionTile(
  title: const Text('           地学'),
  children: <Widget>[
    ListTile(
      title: const Text('                 地学'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('高校 - 理科 地学 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('                 地学基礎'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('高校 - 理科 地学基礎 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
  ],
),
  ],
),
    ExpansionTile(
  title: const Text('     社会'),
  children: <Widget>[
    ListTile(
      title: const Text('           現代社会'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('高校 - 社会 現代社会 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('           地理'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('高校 - 社会 地理 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('           日本史'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('高校 - 社会 日本史 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('           世界史'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('高校 - 社会 世界史 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('           倫理'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('高校 - 社会 倫理 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('           政治・経済'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('高校 - 社会 政治・経済 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
  ],
),

    ListTile(
      title: const Text('     英語'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('高校 - 英語 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
  ],
),
            // 英語スキル
            ExpansionTile(
              title: const Text('英語スキル'),
              children: <Widget>[
                ExpansionTile(
  title: const Text('     英検'),
  children: <Widget>[
    ListTile(
      title: const Text('           1級'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('英検1級のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('           準1級'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('英検準1級のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('           2級'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('英検2級のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('           準2級'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('英検準2級のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('           3級'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('英検3級のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('           4級'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('英検4級のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('           5級'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('英検5級のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
  ],
),
                ExpansionTile(
                  title: const Text('     TOEIC'),
                  children: <Widget>[
                    ExpansionTile(
                      title: const Text('           up to 300'),
                      children: <Widget>[
                        ExpansionTile(
                          title: const Text('                 Grammar'),
                          children: [
                            ListTile(
                              title: const Text('                       Long_Sentence'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 300 Grammar Long_Sentence のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                       Short_Sentence'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewShortSentences(level: 'up_to_300'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        ListTile(
                          title: const Text('                 Listening'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Center(
                                  child: Text('TOEIC up to 300 Listening のデータ確認ページ'),
                                ),
                              ),
                            );
                          },
                        ),
                        ExpansionTile(
                          title: const Text('                 Test'),
                          children: [
                            ListTile(
                              title: const Text('                      Part1'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 300 Test Part1 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                       Part2'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 300 Test Part2 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                      Part3'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 300 Test Part3 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                       Part4'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 300 Test Part4 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                       Part5'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 300 Test Part5 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                      Part6'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 300 Test Part6 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                       Part7-1'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 300 Test Part7-1 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                      Part7-2'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 300 Test Part7-2 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                      Part7-3'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 300 Test Part7-3 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                      Part7-4'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 300 Test Part7-4 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        ExpansionTile(
                          title: const Text('                Words'),
                          children: [
                            ListTile(
                              title: const Text('                      Idioms'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 300 Words Idioms のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                       Word'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewToeicWord(level: 'up_to_300'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    ExpansionTile(
                      title: const Text('           up to 500'),
                      children: <Widget>[
                        ExpansionTile(
                          title: const Text('                 Grammar'),
                          children: [
                            ListTile(
                              title: const Text('                    Long_Sentence'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 500 Grammar Long_Sentence のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                    Short_Sentence'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewShortSentences(level: 'up_to_500'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        ListTile(
                          title: const Text('                 Listening'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Center(
                                  child: Text('TOEIC up to 500 Listening のデータ確認ページ'),
                                ),
                              ),
                            );
                          },
                        ),
                        ExpansionTile(
                          title: const Text('                 Test'),
                          children: [
                            ListTile(
                              title: const Text('                      Part1'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 500 Test Part1 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                      Part2'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 500 Test Part2 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                       Part3'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 500 Test Part3 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                       Part4'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 500 Test Part4 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                       Part5'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 500 Test Part5 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                      Part6'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 500 Test Part6 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                      Part7-1'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 500 Test Part7-1 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                      Part7-2'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 500 Test Part7-2 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                      Part7-3'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 500 Test Part7-3 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                      Part7-4'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 500 Test Part7-4 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        ExpansionTile(
                          title: const Text('                 Words'),
                          children: [
                            ListTile(
                              title: const Text('                       Idioms'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 500 Words Idioms のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                      Word'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewToeicWord(level: 'up_to_500'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    ExpansionTile(
                      title: const Text('           up to 700'),
                      children: <Widget>[
                        ExpansionTile(
                          title: const Text('                 Grammar'),
                          children: [
                            ListTile(
                              title: const Text('                       Long_Sentence'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 700 Grammar Long_Sentence のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                       Short_Sentence'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewShortSentences(level: 'up_to_700'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        ListTile(
                          title: const Text('                 Listening'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Center(
                                  child: Text('TOEIC up to 700 Listening のデータ確認ページ'),
                                ),
                              ),
                            );
                          },
                        ),
                        ExpansionTile(
                          title: const Text('                 Test'),
                          children: [
                            ListTile(
                              title: const Text('                    Part1'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 700 Test Part1 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                    Part2'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 700 Test Part2 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                    Part3'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 700 Test Part3 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                    Part4'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 700 Test Part4 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                    Part5'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 700 Test Part5 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                    Part6'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 700 Test Part6 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                    Part7-1'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 700 Test Part7-1 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                    Part7-2'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 700 Test Part7-2 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                    Part7-3'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 700 Test Part7-3 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                    Part7-4'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 700 Test Part7-4 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        ExpansionTile(
                          title: const Text('                 Words'),
                          children: [
                            ListTile(
                              title: const Text('                    Idioms'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 700 Words Idioms のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                    Word'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewToeicWord(level: 'up_to_700'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ]
                    ),
                    ExpansionTile(
                      title: const Text('           up to 900'),
                      children: <Widget>[
                        ExpansionTile(
                          title: const Text('                Grammar'),
                          children: [
                            ListTile(
                              title: const Text('                    Long_Sentence'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 900 Grammar Long_Sentence のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                    Short_Sentence'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewShortSentences(level: 'up_to_900'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        ListTile(
                          title: const Text('                 Listening'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Center(
                                  child: Text('TOEIC up to 900 Listening のデータ確認ページ'),
                                ),
                              ),
                            );
                          },
                        ),
                        ExpansionTile(
                          title: const Text('                 Test'),
                          children: [
                            ListTile(
                              title: const Text('                    Part1'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 900 Test Part1 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                    Part2'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 900 Test Part2 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                    Part3'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 900 Test Part3 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                    Part4'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 900 Test Part4 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                    Part5'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 900 Test Part5 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                    Part6'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 900 Test Part6 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                    Part7-1'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 900 Test Part7-1 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                    Part7-2'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 900 Test Part7-2 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                    Part7-3'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 900 Test Part7-3 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                    Part7-4'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 900 Test Part7-4 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        ExpansionTile(
                          title: const Text('                 Words'),
                          children: [
                            ListTile(
                              title: const Text('                    Idioms'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 900 Words Idioms のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                    Word'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewToeicWord(level: 'up_to_900'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    ExpansionTile(
                      title: const Text('           up to 990'),
                      children: <Widget>[
                        ExpansionTile(
                          title: const Text('                 Grammar'),
                          children: [
                            ListTile(
                              title: const Text('                    Long_Sentence'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 990 Grammar Long_Sentence のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                    Short_Sentence'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewShortSentences(level: 'up_to_990'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        ListTile(
                          title: const Text('                 Listening'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Center(
                                  child: Text('TOEIC up to 990 Listening のデータ確認ページ'),
                                ),
                              ),
                            );
                          },
                        ),
                        ExpansionTile(
                          title: const Text('                 Test'),
                          children: [
                            ListTile(
                              title: const Text('                    Part1'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 990 Test Part1 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                    Part2'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 990 Test Part2 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                    Part3'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 990 Test Part3 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                    Part4'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 990 Test Part4 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                    Part5'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 990 Test Part5 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                    Part6'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 990 Test Part6 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                    Part7-1'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 990 Test Part7-1 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                    Part7-2'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 990 Test Part7-2 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                    Part7-3'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 990 Test Part7-3 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                    Part7-4'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 990 Test Part7-4 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        ExpansionTile(
                          title: const Text('                 Words'),
                          children: [
                            ListTile(
                              title: const Text('                    Idioms'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEIC up to 990 Words Idioms のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: const Text('                    Word'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewToeicWord(level: 'up_to_990'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                // TOEFL セクション
                ExpansionTile(
                  title: const Text('     TOEFL'),
                  children: <Widget>[
                    ExpansionTile(
                      title: const Text('           up to 40'),
                      children: <Widget>[
                        ExpansionTile(
                      title: const Text('                 Words'),
                      children: <Widget>[
                        ListTile(
                              title: const Text('                      Idioms'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEFL up to 40 Words Idioms のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ListTile(
                          title: const Text('                      Words'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewToeflWord(level: 'up_to_40'),
                              ),
                            );
                          },
                        ),
                      ],
                        ),
                      ],
                    ),
                    ExpansionTile(
                      title: const Text('           up to 60'),
                      children: <Widget>[
                        ExpansionTile(
                      title: const Text('                Words'),
                      children: <Widget>[
                        ListTile(
                              title: const Text('                      Idioms'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEFL up to 60 Words Idioms のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ListTile(
                          title: const Text('                      Word'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewToeflWord(level: 'up_to_60'),
                              ),
                            );
                          },
                        ),
                      ],
                        ),
                      ],
                    ),
                    ExpansionTile(
                      title: const Text('           up to 80'),
                      children: <Widget>[
                        ExpansionTile(
                      title: const Text('                Words'),
                      children: <Widget>[
                        ListTile(
                              title: const Text('                      Idioms'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEFL up to 80 Words Idioms のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ListTile(
                          title: const Text('                      Word'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewToeflWord(level: 'up_to_80'),
                              ),
                            );
                          },
                        ),
                      ],
                        ),
                      ],
                    ),
                    ExpansionTile(
                      title: const Text('           up to 100'),
                      children: <Widget>[
                        ExpansionTile(
                      title: const Text('                Words'),
                      children: <Widget>[
                        ListTile(
                              title: const Text('                      Idioms'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEFL up to 100 Words Idioms のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ListTile(
                          title: const Text('                      Word'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewToeflWord(level: 'up_to_100'),
                              ),
                            );
                          },
                        ),
                      ],
                        ),
                      ],
                    ),
                    ExpansionTile(
                      title: const Text('           up to 120'),
                      children: <Widget>[
                        ExpansionTile(
                      title: const Text('                Words'),
                      children: <Widget>[
                        ListTile(
                              title: const Text('                      Idioms'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Center(
                                      child: Text('TOEFL up to 120 Words Idioms のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ListTile(
                          title: const Text('                      Word'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewToeflWord(level: 'up_to_120'),
                              ),
                            );
                          },
                        ),
                      ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            // プログラミングスキル
            ExpansionTile(
  title: const Text('プログラミングスキル'),
  children: <Widget>[
    ExpansionTile(
  title: const Text('     試験'),
  children: <Widget>[
    ListTile(
      title: const Text('                 ITパスポート'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('試験 - ITパスポートのデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('                 基本情報技術者試験'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('試験 - 基本情報技術者試験のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('                 C言語プログラミング能力認定試験'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('試験 - C言語プログラミング能力認定試験のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
  ],
),
    ListTile(
      title: const Text('     C'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('プログラミングスキル - C のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('     C#'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('プログラミングスキル - C# のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('     C++'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('プログラミングスキル - C++ のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('     Dart'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('プログラミングスキル - Dart のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('     Java'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('プログラミングスキル - Java のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('     JavaScript'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('プログラミングスキル - JavaScript のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('     Kotlin'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('プログラミングスキル - Kotlin のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('     PHP'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('プログラミングスキル - PHP のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('     Python'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('プログラミングスキル - Python のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('     Ruby'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('プログラミングスキル - Ruby のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('     SQL'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('プログラミングスキル - SQL のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: const Text('     Swift'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Center(
              child: Text('プログラミングスキル - Swift のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
  ],
),

            // SPI
            ListTile(
              title: const Text('SPI'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Center(
                      child: Text('SPIのデータ確認ページ'),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'データベース管理フォーム',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
