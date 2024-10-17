import 'import.dart';  // 共通インポートファイルを使用

class ViewFormSelection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SuStudy, 確認フォーム'),
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
                'Select a Category',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            // 中学校
            ListTile(
              title: Text('中学校'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Center(
                      child: Text('中学校のデータ確認ページ'),
                    ),
                  ),
                );
              },
            ),
            // 高校
            ListTile(
              title: Text('高校'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Center(
                      child: Text('高校のデータ確認ページ'),
                    ),
                  ),
                );
              },
            ),
            // 英語スキル
            ExpansionTile(
              title: Text('英語スキル'),
              children: <Widget>[
                ListTile(
                  title: Text('英検'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Center(
                          child: Text('英検のデータ確認ページ'),
                        ),
                      ),
                    );
                  },
                ),
                ExpansionTile(
                  title: Text('TOEIC'),
                  children: <Widget>[
                    ExpansionTile(
                      title: Text('TOEIC up to 300'),
                      children: <Widget>[
                        ExpansionTile(
                          title: Text('Grammar'),
                          children: [
                            ListTile(
                              title: Text('Long_Sentence'),
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
                              title: Text('Short_Sentence'),
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
                          title: Text('Listening'),
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
                          title: Text('Test'),
                          children: [
                            ListTile(
                              title: Text('Part1'),
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
                              title: Text('Part2'),
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
                              title: Text('Part3'),
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
                              title: Text('Part4'),
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
                              title: Text('Part5'),
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
                              title: Text('Part6'),
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
                              title: Text('Part7-1'),
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
                              title: Text('Part7-2'),
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
                              title: Text('Part7-3'),
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
                              title: Text('Part7-4'),
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
                          title: Text('Words'),
                          children: [
                            ListTile(
                              title: Text('Idioms'),
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
                              title: Text('Word'),
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
                      title: Text('TOEIC up to 500'),
                      children: <Widget>[
                        ExpansionTile(
                          title: Text('Grammar'),
                          children: [
                            ListTile(
                              title: Text('Long_Sentence'),
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
                              title: Text('Short_Sentence'),
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
                          title: Text('Listening'),
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
                          title: Text('Test'),
                          children: [
                            ListTile(
                              title: Text('Part1'),
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
                              title: Text('Part2'),
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
                              title: Text('Part3'),
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
                              title: Text('Part4'),
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
                              title: Text('Part5'),
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
                              title: Text('Part6'),
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
                              title: Text('Part7-1'),
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
                              title: Text('Part7-2'),
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
                              title: Text('Part7-3'),
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
                              title: Text('Part7-4'),
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
                          title: Text('Words'),
                          children: [
                            ListTile(
                              title: Text('Idioms'),
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
                              title: Text('Word'),
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
                      title: Text('TOEIC up to 700'),
                      children: <Widget>[
                        ExpansionTile(
                          title: Text('Grammar'),
                          children: [
                            ListTile(
                              title: Text('Long_Sentence'),
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
                              title: Text('Short_Sentence'),
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
                          title: Text('Listening'),
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
                          title: Text('Test'),
                          children: [
                            ListTile(
                              title: Text('Part1'),
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
                              title: Text('Part2'),
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
                              title: Text('Part3'),
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
                              title: Text('Part4'),
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
                              title: Text('Part5'),
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
                              title: Text('Part6'),
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
                              title: Text('Part7-1'),
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
                              title: Text('Part7-2'),
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
                              title: Text('Part7-3'),
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
                              title: Text('Part7-4'),
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
                          title: Text('Words'),
                          children: [
                            ListTile(
                              title: Text('Idioms'),
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
                              title: Text('Word'),
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
                      title: Text('TOEIC up to 900'),
                      children: <Widget>[
                        ExpansionTile(
                          title: Text('Grammar'),
                          children: [
                            ListTile(
                              title: Text('Long_Sentence'),
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
                              title: Text('Short_Sentence'),
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
                          title: Text('Listening'),
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
                          title: Text('Test'),
                          children: [
                            ListTile(
                              title: Text('Part1'),
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
                              title: Text('Part2'),
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
                              title: Text('Part3'),
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
                              title: Text('Part4'),
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
                              title: Text('Part5'),
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
                              title: Text('Part6'),
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
                              title: Text('Part7-1'),
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
                              title: Text('Part7-2'),
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
                              title: Text('Part7-3'),
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
                              title: Text('Part7-4'),
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
                          title: Text('Words'),
                          children: [
                            ListTile(
                              title: Text('Idioms'),
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
                              title: Text('Word'),
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
                      title: Text('TOEIC up to 990'),
                      children: <Widget>[
                        ExpansionTile(
                          title: Text('Grammar'),
                          children: [
                            ListTile(
                              title: Text('Long_Sentence'),
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
                              title: Text('Short_Sentence'),
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
                          title: Text('Listening'),
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
                          title: Text('Test'),
                          children: [
                            ListTile(
                              title: Text('Part1'),
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
                              title: Text('Part2'),
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
                              title: Text('Part3'),
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
                              title: Text('Part4'),
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
                              title: Text('Part5'),
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
                              title: Text('Part6'),
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
                              title: Text('Part7-1'),
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
                              title: Text('Part7-2'),
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
                              title: Text('Part7-3'),
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
                              title: Text('Part7-4'),
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
                          title: Text('Words'),
                          children: [
                            ListTile(
                              title: Text('Idioms'),
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
                              title: Text('Word'),
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
                  title: Text('TOEFL'),
                  children: <Widget>[
                    ExpansionTile(
                      title: Text('TOEFL up to 40'),
                      children: <Widget>[
                        ListTile(
                          title: Text('Words'),
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
                    ExpansionTile(
                      title: Text('TOEFL up to 60'),
                      children: <Widget>[
                        ListTile(
                          title: Text('Words'),
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
                    ExpansionTile(
                      title: Text('TOEFL up to 80'),
                      children: <Widget>[
                        ListTile(
                          title: Text('Words'),
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
                    ExpansionTile(
                      title: Text('TOEFL up to 100'),
                      children: <Widget>[
                        ListTile(
                          title: Text('Words'),
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
                    ExpansionTile(
                      title: Text('TOEFL up to 120'),
                      children: <Widget>[
                        ListTile(
                          title: Text('Words'),
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
            // プログラミングスキル
            ListTile(
              title: Text('プログラミングスキル'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Center(
                      child: Text('プログラミングスキルのデータ確認ページ'),
                    ),
                  ),
                );
              },
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
              'メニューから追加するコレクションを選択してください.',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);  // 管理フォームに戻る
              },
              child: Text('管理フォームに戻る'),
            ),
          ],
        ),
      ),
    );
  }
}
