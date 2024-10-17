import 'import.dart'; 

class ViewFormSelection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SuStudy, データベース管理フォーム'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Select a Collection',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            // 中学校
            ExpansionTile(
  title: Text('中学校'),
  children: <Widget>[
    ListTile(
      title: Text('     国語'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('中学校 - 国語 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('     数学'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('中学校 - 数学 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('     理科'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('中学校 - 理科 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('     社会'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('中学校 - 社会 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('     英語'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
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
  title: Text('高校'),
  children: <Widget>[
    ExpansionTile(
  title: Text('     国語'),
  children: <Widget>[
    ListTile(
      title: Text('           評論'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('高校 - 国語 評論 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('           小説'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('高校 - 国語 小説 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('           古文'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('高校 - 国語 古文 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('           漢文'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('高校 - 国語 漢文 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
  ],
),
    ExpansionTile(
  title: Text('     数学'),
  children: <Widget>[
    ExpansionTile(
  title: Text('           IA'),
  children: <Widget>[
    ListTile(
      title: Text('                I'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('高校 - 数学 I のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('                A'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('高校 - 数学 A のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
  ],
    ),
    ExpansionTile(
  title: Text('           IIB'),
  children: <Widget>[
    ListTile(
      title: Text('                II'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('高校 - 数学 II のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('                B'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('高校 - 数学 B のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
  ],
    ),
    ListTile(
      title: Text('           III'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('高校 - 数学 III のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
  ],
),
ExpansionTile(
  title: Text('     理科'),
  children: <Widget>[
    ExpansionTile(
  title: Text('           物理'),
  children: <Widget>[
    ListTile(
      title: Text('                 物理'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('高校 - 理科 物理 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('                 物理基礎'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('高校 - 理科 物理基礎 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
  ],
),
    ExpansionTile(
  title: Text('           化学'),
  children: <Widget>[
    ListTile(
      title: Text('                 化学'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('高校 - 理科 化学 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('                 化学基礎'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('高校 - 理科 化学基礎 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
  ],
),
    ExpansionTile(
  title: Text('           生物'),
  children: <Widget>[
    ListTile(
      title: Text('                 生物'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('高校 - 理科 生物 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('                 生物基礎'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('高校 - 理科 生物基礎 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
  ],
),
ExpansionTile(
  title: Text('           地学'),
  children: <Widget>[
    ListTile(
      title: Text('                 地学'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('高校 - 理科 地学 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('                 地学基礎'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
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
  title: Text('     社会'),
  children: <Widget>[
    ListTile(
      title: Text('           現代社会'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('高校 - 社会 現代社会 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('           地理'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('高校 - 社会 地理 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('           日本史'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('高校 - 社会 日本史 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('           世界史'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('高校 - 社会 世界史 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('           倫理'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('高校 - 社会 倫理 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('           政治・経済'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('高校 - 社会 政治・経済 のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
  ],
),

    ListTile(
      title: Text('     英語'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
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
              title: Text('英語スキル'),
              children: <Widget>[
                ExpansionTile(
  title: Text('     英検'),
  children: <Widget>[
    ListTile(
      title: Text('           1級'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('英検1級のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('           準1級'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('英検準1級のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('           2級'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('英検2級のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('           準2級'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('英検準2級のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('           3級'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('英検3級のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('           4級'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('英検4級のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('           5級'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('英検5級のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
  ],
),
                ExpansionTile(
                  title: Text('     TOEIC'),
                  children: <Widget>[
                    ExpansionTile(
                      title: Text('           up to 300'),
                      children: <Widget>[
                        ExpansionTile(
                          title: Text('                 Grammar'),
                          children: [
                            ListTile(
                              title: Text('                       Long_Sentence'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 300 Grammar Long_Sentence のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                       Short_Sentence'),
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
                          title: Text('                 Listening'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Center(
                                  child: Text('TOEIC up to 300 Listening のデータ確認ページ'),
                                ),
                              ),
                            );
                          },
                        ),
                        ExpansionTile(
                          title: Text('                 Test'),
                          children: [
                            ListTile(
                              title: Text('                      Part1'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 300 Test Part1 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                       Part2'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 300 Test Part2 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                      Part3'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 300 Test Part3 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                       Part4'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 300 Test Part4 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                       Part5'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 300 Test Part5 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                      Part6'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 300 Test Part6 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                       Part7-1'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 300 Test Part7-1 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                      Part7-2'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 300 Test Part7-2 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                      Part7-3'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 300 Test Part7-3 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                      Part7-4'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 300 Test Part7-4 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        ExpansionTile(
                          title: Text('                Words'),
                          children: [
                            ListTile(
                              title: Text('                      Idioms'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 300 Words Idioms のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                       Word'),
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
                      title: Text('           up to 500'),
                      children: <Widget>[
                        ExpansionTile(
                          title: Text('                 Grammar'),
                          children: [
                            ListTile(
                              title: Text('                    Long_Sentence'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 500 Grammar Long_Sentence のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                    Short_Sentence'),
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
                          title: Text('                 Listening'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Center(
                                  child: Text('TOEIC up to 500 Listening のデータ確認ページ'),
                                ),
                              ),
                            );
                          },
                        ),
                        ExpansionTile(
                          title: Text('                 Test'),
                          children: [
                            ListTile(
                              title: Text('                      Part1'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 500 Test Part1 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                      Part2'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 500 Test Part2 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                       Part3'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 500 Test Part3 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                       Part4'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 500 Test Part4 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                       Part5'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 500 Test Part5 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                      Part6'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 500 Test Part6 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                      Part7-1'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 500 Test Part7-1 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                      Part7-2'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 500 Test Part7-2 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                      Part7-3'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 500 Test Part7-3 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                      Part7-4'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 500 Test Part7-4 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        ExpansionTile(
                          title: Text('                 Words'),
                          children: [
                            ListTile(
                              title: Text('                       Idioms'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 500 Words Idioms のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                      Word'),
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
                      title: Text('           up to 700'),
                      children: <Widget>[
                        ExpansionTile(
                          title: Text('                 Grammar'),
                          children: [
                            ListTile(
                              title: Text('                       Long_Sentence'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 700 Grammar Long_Sentence のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                       Short_Sentence'),
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
                          title: Text('                 Listening'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Center(
                                  child: Text('TOEIC up to 700 Listening のデータ確認ページ'),
                                ),
                              ),
                            );
                          },
                        ),
                        ExpansionTile(
                          title: Text('                 Test'),
                          children: [
                            ListTile(
                              title: Text('                    Part1'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 700 Test Part1 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                    Part2'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 700 Test Part2 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                    Part3'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 700 Test Part3 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                    Part4'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 700 Test Part4 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                    Part5'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 700 Test Part5 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                    Part6'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 700 Test Part6 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                    Part7-1'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 700 Test Part7-1 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                    Part7-2'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 700 Test Part7-2 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                    Part7-3'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 700 Test Part7-3 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                    Part7-4'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 700 Test Part7-4 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        ExpansionTile(
                          title: Text('                 Words'),
                          children: [
                            ListTile(
                              title: Text('                    Idioms'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 700 Words Idioms のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                    Word'),
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
                      title: Text('           up to 900'),
                      children: <Widget>[
                        ExpansionTile(
                          title: Text('                Grammar'),
                          children: [
                            ListTile(
                              title: Text('                    Long_Sentence'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 900 Grammar Long_Sentence のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                    Short_Sentence'),
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
                          title: Text('                 Listening'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Center(
                                  child: Text('TOEIC up to 900 Listening のデータ確認ページ'),
                                ),
                              ),
                            );
                          },
                        ),
                        ExpansionTile(
                          title: Text('                 Test'),
                          children: [
                            ListTile(
                              title: Text('                    Part1'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 900 Test Part1 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                    Part2'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 900 Test Part2 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                    Part3'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 900 Test Part3 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                    Part4'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 900 Test Part4 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                    Part5'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 900 Test Part5 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                    Part6'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 900 Test Part6 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                    Part7-1'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 900 Test Part7-1 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                    Part7-2'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 900 Test Part7-2 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                    Part7-3'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 900 Test Part7-3 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                    Part7-4'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 900 Test Part7-4 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        ExpansionTile(
                          title: Text('                 Words'),
                          children: [
                            ListTile(
                              title: Text('                    Idioms'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 900 Words Idioms のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                    Word'),
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
                      title: Text('           up to 990'),
                      children: <Widget>[
                        ExpansionTile(
                          title: Text('                 Grammar'),
                          children: [
                            ListTile(
                              title: Text('                    Long_Sentence'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 990 Grammar Long_Sentence のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                    Short_Sentence'),
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
                          title: Text('                 Listening'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Center(
                                  child: Text('TOEIC up to 990 Listening のデータ確認ページ'),
                                ),
                              ),
                            );
                          },
                        ),
                        ExpansionTile(
                          title: Text('                 Test'),
                          children: [
                            ListTile(
                              title: Text('                    Part1'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 990 Test Part1 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                    Part2'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 990 Test Part2 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                    Part3'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 990 Test Part3 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                    Part4'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 990 Test Part4 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                    Part5'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 990 Test Part5 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                    Part6'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 990 Test Part6 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                    Part7-1'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 990 Test Part7-1 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                    Part7-2'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 990 Test Part7-2 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                    Part7-3'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 990 Test Part7-3 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                    Part7-4'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 990 Test Part7-4 のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        ExpansionTile(
                          title: Text('                 Words'),
                          children: [
                            ListTile(
                              title: Text('                    Idioms'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEIC up to 990 Words Idioms のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              title: Text('                    Word'),
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
                  title: Text('     TOEFL'),
                  children: <Widget>[
                    ExpansionTile(
                      title: Text('           up to 40'),
                      children: <Widget>[
                        ExpansionTile(
                      title: Text('                 Words'),
                      children: <Widget>[
                        ListTile(
                              title: Text('                      Idioms'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEFL up to 40 Words Idioms のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ListTile(
                          title: Text('                      Words'),
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
                      title: Text('           up to 60'),
                      children: <Widget>[
                        ExpansionTile(
                      title: Text('                Words'),
                      children: <Widget>[
                        ListTile(
                              title: Text('                      Idioms'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEFL up to 60 Words Idioms のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ListTile(
                          title: Text('                      Word'),
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
                      title: Text('           up to 80'),
                      children: <Widget>[
                        ExpansionTile(
                      title: Text('                Words'),
                      children: <Widget>[
                        ListTile(
                              title: Text('                      Idioms'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEFL up to 80 Words Idioms のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ListTile(
                          title: Text('                      Word'),
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
                      title: Text('           up to 100'),
                      children: <Widget>[
                        ExpansionTile(
                      title: Text('                Words'),
                      children: <Widget>[
                        ListTile(
                              title: Text('                      Idioms'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEFL up to 100 Words Idioms のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ListTile(
                          title: Text('                      Word'),
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
                      title: Text('           up to 120'),
                      children: <Widget>[
                        ExpansionTile(
                      title: Text('                Words'),
                      children: <Widget>[
                        ListTile(
                              title: Text('                      Idioms'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Center(
                                      child: Text('TOEFL up to 120 Words Idioms のデータ確認ページ'),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ListTile(
                          title: Text('                      Word'),
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
  title: Text('プログラミングスキル'),
  children: <Widget>[
    ListTile(
      title: Text('     C'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('プログラミングスキル - C のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('     C#'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('プログラミングスキル - C# のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('     C++'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('プログラミングスキル - C++ のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('     Dart'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('プログラミングスキル - Dart のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('     Java'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('プログラミングスキル - Java のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('     JavaScript'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('プログラミングスキル - JavaScript のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('     Kotlin'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('プログラミングスキル - Kotlin のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('     PHP'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('プログラミングスキル - PHP のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('     Python'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('プログラミングスキル - Python のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('     Ruby'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('プログラミングスキル - Ruby のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('     SQL'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('プログラミングスキル - SQL のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('     Swift'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('プログラミングスキル - Swift のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ExpansionTile(
  title: Text('     試験'),
  children: <Widget>[
    ListTile(
      title: Text('                 ITパスポート'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('試験 - ITパスポートのデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('                 基本情報技術者試験'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('試験 - 基本情報技術者試験のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
    ListTile(
      title: Text('                 C言語プログラミング能力認定試験'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Center(
              child: Text('試験 - C言語プログラミング能力認定試験のデータ確認ページ'),
            ),
          ),
        );
      },
    ),
  ],
),
  ],
),

            // SPI
            ListTile(
              title: Text('SPI'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Center(
                      child: Text('SPIのデータ確認ページ'),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'メニューから管理するコレクションを選択してください.',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
