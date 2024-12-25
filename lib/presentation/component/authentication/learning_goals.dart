import '/import.dart';
import 'package:intl/intl.dart';



class LearningGoalsScreen extends StatefulWidget {
  final String userId; // ユーザーIDを受け取る

  const LearningGoalsScreen({super.key, required this.userId});

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
    final today = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(today);
    final recordRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.userId)
        .collection('record')
        .doc(formattedDate);

    final dataToUpdate = {
      'timestamp': FieldValue.serverTimestamp(),
      't_solved_count': 0,
    };

  for (final subject in followingSubjects) {
  final goal = selectedGoals[subject];
  if (goal != null && goal.isNotEmpty) { // null または空文字列をスキップ
    final key = "${subject}_goal";
    
    // 数値を抽出して変換
    final extractedValue = RegExp(r'\d+').stringMatch(goal); // 数字部分を抽出
    final parsedValue = extractedValue != null ? int.parse(extractedValue) : null;

    if (parsedValue != null) {
      dataToUpdate[key] = parsedValue; // 数値を保存
    } else {
      print('学習目標のフォーマットが不正です: $goal');
    }
  } else {
    print('未選択の教科: $subject');
  }
}


    await recordRef.set(dataToUpdate, SetOptions(merge: true));

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
            '学習目標を登録',
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
