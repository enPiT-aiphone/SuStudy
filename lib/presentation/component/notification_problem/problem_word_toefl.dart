import '/import.dart';
import 'package:firebase_auth/firebase_auth.dart';


class TOEFLWordQuiz extends StatefulWidget {
  final String level;

  const TOEFLWordQuiz({required this.level, Key? key}) : super(key: key);

  @override
  _TOEFLWordQuizState createState() => _TOEFLWordQuizState();
}

// バツ（×）印を描画するカスタムペインター
class CrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color(0xFFFF5252)
      ..strokeWidth = 6;

    canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(0, 0), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _TOEFLWordQuizState extends State<TOEFLWordQuiz> with SingleTickerProviderStateMixin {
  int currentQuestionIndex = 0;
  List<QueryDocumentSnapshot> questions = [];
  List<List<String>> shuffledOptions = [];
  List<String?> selectedAnswers = List.filled(5, null);
  List<bool?> isCorrectAnswers = List.filled(5, null);
  bool isDataLoaded = false;
  bool isShowingAnswer = false;
  List<String> askedWordIds = [];
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });

    _colorAnimation = ColorTween(
      begin: const Color(0xFF0ABAB5),
      end: const Color.fromARGB(255, 255, 82, 82),
    ).animate(_animationController);

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _handleTimeout();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchQuestions() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('English_Skills')
        .doc('TOEFL')
        .collection(widget.level)
        .doc('Words')
        .collection('Word')
        .get();

    List<QueryDocumentSnapshot> allQuestions = snapshot.docs;
    questions = allQuestions.where((doc) => !askedWordIds.contains(doc.id)).toList();

    if (questions.isNotEmpty) {
      if (questions.length > 5) {
        questions.shuffle();
        questions = questions.take(5).toList();
      }

      for (var question in questions) {
        List<String> options = [
          question['ENG_to_JPN_Answer_A'],
          question['ENG_to_JPN_Answer_B'],
          question['ENG_to_JPN_Answer_C'],
          question['ENG_to_JPN_Answer_D'],
        ];
        options.shuffle();
        shuffledOptions.add(options);
      }

      setState(() {
        isDataLoaded = true;
        _startTimer();
      });
    }
  }

  void _startTimer() {
    _animationController.reset();
    _animationController.forward();
  }

  void _handleTimeout() {
    _saveResult(null, questions[currentQuestionIndex], false);

    setState(() {
      isCorrectAnswers[currentQuestionIndex] = false;
      isShowingAnswer = true;

      showDialog(
        context: context,
        barrierColor: Colors.transparent,
        barrierDismissible: false,
        builder: (BuildContext context) {
          double circleSize = MediaQuery.of(context).size.width / 2;
          return Center(
            child: CustomPaint(
              size: Size(circleSize * 0.8, circleSize * 0.8),
              painter: CrossPainter(),
            ),
          );
        },
      );

      Future.delayed(const Duration(milliseconds: 600), () {
        Navigator.of(context).pop();
        if (currentQuestionIndex < 4) {
          setState(() {
            currentQuestionIndex++;
            isShowingAnswer = false;
            _startTimer();
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultPage(
                selectedAnswers: selectedAnswers,
                isCorrectAnswers: isCorrectAnswers,
                wordDetails: questions,
              ),
            ),
          );
        }
      });
    });
  }

  Future<void> _saveResult(String? selectedAnswer, QueryDocumentSnapshot wordData, bool isCorrect) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      print('ログイン中のユーザーがいません');
      return;
    }

    try {
    // Usersドキュメントからユーザー情報を取得
    final userDoc = FirebaseFirestore.instance.collection('Users').doc(userId);
    final userSnapshot = await userDoc.get();

    if (!userSnapshot.exists) {
      print('ユーザー情報が見つかりません');
      return;
    }

    // following_subjectsからTOEFLのスコア（X点）を取得
    final followingSubjects = List<String>.from(
        userSnapshot.data()?['following_subjects'] ?? []);
    final matchedScore = followingSubjects
        .firstWhere((subject) => subject.startsWith('TOEFL'), orElse: () => '');

    if (matchedScore.isEmpty) {
      print('TOEFLスコアが見つかりません');
      return;
    }

    // 正規表現で数字部分だけを抽出
    final scoreMatch = RegExp(r'\d+').firstMatch(matchedScore);
    if (scoreMatch == null) {
      print('TOEFLスコアの形式が不正です');
      return;
    }
    final score = scoreMatch.group(0); // 抽出されたスコア（X部分）
    final toeflDoc = userDoc
        .collection('following_subjects')
        .doc('TOEFL')
        .collection('up_to_$score');

    // Wordsサブコレクションに保存
    final wordName = wordData['Word'];
    final wordDocRef = toeflDoc.doc('Words').collection('Word').doc(wordName);
    final attemptsSnapshot = await wordDocRef.collection('Attempts').get();
    final attemptNumber = attemptsSnapshot.docs.length + 1;
    final Nextname = '$attemptNumber';
      await wordDocRef.collection('Attempts')..doc(Nextname).set({
        'attempt_number': attemptNumber,
        'timestamp': FieldValue.serverTimestamp(),
        'selected_answer': selectedAnswer,
        'correct_answer': wordData['ENG_to_JPN_Answer'],
        'is_correct': isCorrect,
        'word_id': wordData.id,
      },SetOptions(merge: true));

      print('クイズ結果が保存されました: Word: $wordName, Attempt: $attemptNumber');

        // todays_count を 1 増やす
      await userDoc.update({
          't_solved_count': FieldValue.increment(1),
      });

      print('todays_count を 1 増やしました');
    } catch (e) {
    print('クイズ結果の保存に失敗しました: $e');
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_colorAnimation.value ?? const Color(0xFF0ABAB5), Colors.white],
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
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: isDataLoaded
          ? _buildQuestionUI(questions[currentQuestionIndex])
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildQuestionUI(QueryDocumentSnapshot wordData) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          LinearProgressIndicator(
            borderRadius: BorderRadius.circular(20),
            value: _animation.value,
            backgroundColor: const Color(0xFFD9D9D9),
            valueColor: AlwaysStoppedAnimation<Color?>(_colorAnimation.value),
            minHeight: 20,
          ),
          const SizedBox(height: 20),
          Expanded(
            flex: 5,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    wordData['Word'],
                    style: const TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "【${wordData['Phonetic_Symbols']}】",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              '${currentQuestionIndex + 1}/5',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _colorAnimation.value,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            flex: 5,
            child: ListView(
              children: [
                for (var option in shuffledOptions[currentQuestionIndex])
                  _buildAnswerButton(option, wordData, screenHeight),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerButton(String option, QueryDocumentSnapshot wordData, double screenHeight) {
    Color? backgroundColor;
    Color finalBorderColor = _colorAnimation.value ?? const Color(0xFF0ABAB5);

    if (isShowingAnswer) {
      if (option == wordData['ENG_to_JPN_Answer']) {
        backgroundColor = const Color(0xFFE0F7FA);
        finalBorderColor = const Color(0xFF0ABAB5);
      } else if (selectedAnswers[currentQuestionIndex] == option) {
        backgroundColor = const Color(0xFFFFEBEE);
        finalBorderColor = const Color(0xFFFF5252);
      }
    } else {
      backgroundColor = Colors.white;
      finalBorderColor = _colorAnimation.value ?? const Color(0xFF0ABAB5);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          bool isCorrect = option == wordData['ENG_to_JPN_Answer'];
          _animationController.stop();
          setState(() {
            selectedAnswers[currentQuestionIndex] = option;
            isCorrectAnswers[currentQuestionIndex] = isCorrect;
            isShowingAnswer = true;
          });

          _saveResult(option, wordData, isCorrect);

          showDialog(
            context: context,
            barrierColor: Colors.transparent,
            barrierDismissible: false,
            builder: (BuildContext context) {
              double circleSize = MediaQuery.of(context).size.width / 2;
              return Center(
                child: isCorrect
                    ? Container(
                        width: circleSize,
                        height: circleSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF0ABAB5), width: 8),
                        ),
                      )
                    : CustomPaint(
                        size: Size(circleSize * 0.8, circleSize * 0.8),
                        painter: CrossPainter(),
                      ),
              );
            },
          );

          Future.delayed(const Duration(milliseconds: 600), () {
            Navigator.of(context).pop();
            if (currentQuestionIndex < 4) {
              setState(() {
                currentQuestionIndex++;
                isShowingAnswer = false;
                _startTimer();
              });
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultPage(
                    selectedAnswers: selectedAnswers,
                    isCorrectAnswers: isCorrectAnswers,
                    wordDetails: questions,
                  ),
                ),
              );
            }
          });
        },
        child: Container(
          height: screenHeight * 0.06,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: finalBorderColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            option,
            style: TextStyle(fontSize: 18, color: finalBorderColor),
          ),
        ),
      ),
    );
  }
}
