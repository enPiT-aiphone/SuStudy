import '/import.dart';

class LearningGoalsScreen extends StatefulWidget {
  final String userId; // ユーザーIDを受け取る

  LearningGoalsScreen({required this.userId});

  @override
  _LearningGoalsScreenState createState() => _LearningGoalsScreenState();
}

class _LearningGoalsScreenState extends State<LearningGoalsScreen> {
  final List<String> goals = ['5分/日', '10分/日', '15分/日', '30分/日'];
  Map<String, String?> selectedGoals = {}; // 教科ごとの学習目標を保存するマップ
  List<String> followingSubjects = []; // Firebaseから取得した教科リスト

  @override
  void initState() {
    super.initState();
    _fetchFollowingSubjects();
  }

  Future<void> _fetchFollowingSubjects() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        final subjects = userDoc.data()?['following_subjects'] as List<dynamic>?;
        if (subjects != null) {
          setState(() {
            followingSubjects = subjects.cast<String>();
          });
        }
      }
    } catch (e) {
      print('教科の取得に失敗しました: $e');
    }
  }

  Future<void> _saveGoals() async {
    try {
      final userDoc = FirebaseFirestore.instance.collection('Users').doc(widget.userId);
      final subCollection = userDoc.collection('following_subjects');

      for (final subject in followingSubjects) {
        final goal = selectedGoals[subject];

          if (subject.contains('TOEIC')) {
            // TOEICまたはTOEFLの場合
            final docRef = subCollection.doc('TOEIC');

            final docSnapshot = await docRef.get();
            if (docSnapshot.exists) {
              await docRef.update({'learning_goal': goal});
            } else {
              await docRef.set({'learning_goal': goal});
            }
          } else if (subject.contains('TOEFL')) {
            // TOEICまたはTOEFLの場合
            final docRef = subCollection.doc('TOEFL');

            final docSnapshot = await docRef.get();
            if (docSnapshot.exists) {
              await docRef.update({'learning_goal': goal});
            } else {
              await docRef.set({'learning_goal': goal});
            }
          } else if (subject.contains('英検')) {
            // TOEICまたはTOEFLの場合
            final docRef = subCollection.doc('英検');

            final docSnapshot = await docRef.get();
            if (docSnapshot.exists) {
              await docRef.update({'learning_goal': goal});
            } else {
              await docRef.set({'learning_goal': goal});
            }
          }else {
            // その他の教科の場合、新しいドキュメントを作成
            final docRef = subCollection.doc(subject);

            final docSnapshot = await docRef.get();
            if (docSnapshot.exists) {
              if (goal != null){
              await docRef.update({'learning_goal': goal});
              }
              await docRef.update({'t_solved_count_$subject': 0});
            } else {
              await docRef.set({'t_solved_count_$subject': 0});
              if (goal != null){
              await docRef.update({'learning_goal': goal});
              }
            }
          }
        }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      print('学習目標の保存中にエラーが発生しました: $e');
    }
  }

  Future<void> _selectGoal(String subject) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: goals.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(goals[index]),
              onTap: () {
                setState(() {
                  selectedGoals[subject] = goals[index];
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
            title: Row(
              children: const [
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
          SizedBox(height: 10),
          Text(
            '学習目標を登録',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 50, 50, 50),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: followingSubjects.length,
                itemBuilder: (BuildContext context, int index) {
                  final subject = followingSubjects[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(subject),
                        trailing: const Icon(Icons.keyboard_arrow_down),
                        onTap: () => _selectGoal(subject),
                      ),
                      if (selectedGoals[subject] != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            '  ${selectedGoals[subject]}',
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildAuthenticationButton(context, '保存', _saveGoals),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
