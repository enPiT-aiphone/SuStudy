import '/import.dart';
import 'learning_goals.dart';

class SubjectSelectionScreen extends StatefulWidget {
  final String userId; // ユーザーIDを受け取る

  const SubjectSelectionScreen({super.key, required this.userId});

  @override
  _SubjectSelectionScreenState createState() => _SubjectSelectionScreenState();
}

class _SubjectSelectionScreenState extends State<SubjectSelectionScreen> {
  final List<String> mainCategories = [
    '英語学習',
    '高校受験合格',
    '大学受験合格',
    'スキルアップ',
    'SPI',
  ];

  final Map<String, List<String>> subCategories = {
    '英語学習': ['TOEIC', 'TOEFL', '英検'],
    '高校受験合格': ['国語', '数学', '英語', '社会', '理科'],
    '大学受験合格': ['国語', '数学', '英語', '社会', '理科'],
    'スキルアップ': ['プログラミング'],
  };

  final Map<String, List<String>> scoreCategories = {
    'TOEIC': [
      'TOEIC300点以上',
      'TOEIC500点以上',
      'TOEIC700点以上',
      'TOEIC900点以上',
      'TOEIC990点',
    ],
    'TOEFL': [
      'TOEFL40点以上',
      'TOEFL60点以上',
      'TOEFL80点以上',
      'TOEFL100点以上',
      'TOEFL120点',
    ],
    '英検': [
      '英検5級',
      '英検4級',
      '英検3級',
      '英検準2級',
      '英検2級',
      '英検準1級',
      '英検1級',
    ],
  };

  String? selectedMainCategory;
  String? selectedSubCategory;
  String? selectedScore;
  Map<String, String?> _errors = {}; // エラーメッセージを管理

  Future<void> _saveSelectedSubject() async {
    bool hasError = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor:  AlwaysStoppedAnimation<Color>(Color(0xFF0ABAB5)),
          ),
        );
      },
    );

    setState(() {
      _errors.clear(); // エラーをリセット

      if (selectedMainCategory == null) {
        _errors['mainCategory'] = 'メインカテゴリーを選択してください';
        hasError = true;
      }

      if (selectedSubCategory == null &&
          subCategories.containsKey(selectedMainCategory ?? '')) {
        _errors['subCategory'] = 'サブカテゴリーを選択してください';
        hasError = true;
      }

      if (selectedScore == null &&
          scoreCategories.containsKey(selectedSubCategory ?? '')) {
        _errors['scoreCategory'] = 'スコアカテゴリーを選択してください';
        hasError = true;
      }
    });

    if (hasError) {
      return; // エラーがある場合、保存処理を中断
    }


    try {
      final userDoc = FirebaseFirestore.instance.collection('Users').doc(widget.userId);

      final List<String> followingSubjects = [];

      if (selectedScore != null) {
        followingSubjects.add(selectedScore!.replaceAll('以上', ''));
      } else if (selectedSubCategory != null) {
        if (selectedMainCategory == '高校受験合格') {
          followingSubjects.add('中学$selectedSubCategory');
        } else if (selectedMainCategory == '大学受験合格') {
          followingSubjects.add('高校$selectedSubCategory');
        } else {
          followingSubjects.add(selectedSubCategory!);
        }
      } else {
        followingSubjects.add(selectedMainCategory!);
      }

      await userDoc.update({
        'following_subjects': FieldValue.arrayUnion(followingSubjects),
        'registrationStep': 2,
      });

      print('登録された教科: $followingSubjects');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LearningGoalsScreen(userId: widget.userId)),
      );
    } catch (e) {
      print('エラーが発生しました: $e');
    }
  }


  Future<void> _selectScore(String subCategory) async {
    final scores = scoreCategories[subCategory] ?? [];
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: scores.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(scores[index]),
              onTap: () {
                setState(() {
                  selectedScore = scores[index];
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAuthenticationButton(
      BuildContext context, String label, VoidCallback onPressed) {
    final double buttonWidth = MediaQuery.of(context).size.width * 0.75;

    return InkWell(
      onTap: onPressed,
      child: Container(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0ABAB5), Color.fromARGB(255, 255, 255, 255)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Row(
              children: [
                Text(
                  'SuStudy, ',
                  style: TextStyle(fontSize: 25, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            '学習内容を決めよう！',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 50, 50, 50),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  if (_errors['mainCategory'] != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        _errors['mainCategory']!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  ListTile(
                    title: Text(
                      selectedMainCategory ?? 'メインカテゴリーを選択',
                      style: const TextStyle(fontSize: 18),
                    ),
                    trailing: const Icon(Icons.keyboard_arrow_down),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return ListView.builder(
                            itemCount: mainCategories.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                title: Text(mainCategories[index]),
                                onTap: () {
                                  setState(() {
                                    selectedMainCategory = mainCategories[index];
                                    selectedSubCategory = null;
                                    selectedScore = null;
                                    _errors['mainCategory'] = null; // エラーをリセット
                                  });
                                  Navigator.pop(context);
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  if (_errors['subCategory'] != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        _errors['subCategory']!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  if (selectedMainCategory != null &&
                      subCategories.containsKey(selectedMainCategory))
                    ListTile(
                      title: Text(
                        selectedSubCategory ?? 'サブカテゴリーを選択',
                        style: const TextStyle(fontSize: 18),
                      ),
                      trailing: const Icon(Icons.keyboard_arrow_down),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return ListView.builder(
                              itemCount: subCategories[selectedMainCategory]!.length,
                              itemBuilder: (BuildContext context, int index) {
                                final subCategory =
                                    subCategories[selectedMainCategory]![index];
                                return ListTile(
                                  title: Text(subCategory),
                                  onTap: () {
                                    setState(() {
                                      selectedSubCategory = subCategory;
                                      selectedScore = null;
                                      _errors['subCategory'] = null; // エラーをリセット
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  if (_errors['scoreCategory'] != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        _errors['scoreCategory']!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  if (selectedSubCategory != null &&
                      scoreCategories.containsKey(selectedSubCategory!))
                    ListTile(
                      title: Text(
                        selectedScore ?? 'スコアカテゴリーを選択',
                        style: const TextStyle(fontSize: 18),
                      ),
                      trailing: const Icon(Icons.keyboard_arrow_down),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return ListView.builder(
                              itemCount: scoreCategories[selectedSubCategory]!.length,
                              itemBuilder: (BuildContext context, int index) {
                                final score = scoreCategories[selectedSubCategory]![index];
                                return ListTile(
                                  title: Text(score),
                                  onTap: () {
                                    setState(() {
                                      selectedScore = score;
                                      _errors['scoreCategory'] = null; // エラーをリセット
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildAuthenticationButton(context, '保存', _saveSelectedSubject),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
