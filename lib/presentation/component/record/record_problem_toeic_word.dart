import '/import.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TOEICWordQuiz extends StatefulWidget {
  final String level; // TOEICレベル
  final String questionType; // 出題タイプ（random, unanswered, incorrect, recent_incorrect）

  const TOEICWordQuiz({required this.level, required this.questionType, Key? key}) : super(key: key);

  @override
  _TOEICWordQuizState createState() => _TOEICWordQuizState();
}

class _TOEICWordQuizState extends State<TOEICWordQuiz> with SingleTickerProviderStateMixin {
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
  QuerySnapshot snapshot;

  if (widget.questionType == 'random') {
    snapshot = await FirebaseFirestore.instance
        .collection('English_Skills')
        .doc('TOEIC')
        .collection(widget.level)
        .doc('Words')
        .collection('Word')
        .get();
  } else if (widget.questionType == 'unanswered') {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final answeredWordsSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('QuizRecords_TOEIC')
        .get();

    List<String> answeredWordIds = answeredWordsSnapshot.docs
        .map((doc) => doc['word_id'] as String)
        .toList();

    if (answeredWordIds.isEmpty) {
      // answeredWordIds が空の場合、全ての単語を取得
      snapshot = await FirebaseFirestore.instance
          .collection('English_Skills')
          .doc('TOEIC')
          .collection(widget.level)
          .doc('Words')
          .collection('Word')
          .get();
    } else {
      snapshot = await FirebaseFirestore.instance
          .collection('English_Skills')
          .doc('TOEIC')
          .collection(widget.level)
          .doc('Words')
          .collection('Word')
          .where(FieldPath.documentId, whereNotIn: answeredWordIds)
          .get();
    }
  } else if (widget.questionType == 'incorrect') {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('QuizRecords_TOEIC')
        .get();

    List<QueryDocumentSnapshot> allRecords = snapshot.docs;
    List<String> incorrectWords = [];

    for (var record in allRecords) {
      final wordDocRef = FirebaseFirestore.instance
          .collection('QuizRecords_TOEIC')
          .doc(record.id)
          .collection('Attempts')
          .orderBy('attempt_number', descending: true)
          .limit(1);

      final latestAttemptSnapshot = await wordDocRef.get();

      if (latestAttemptSnapshot.docs.isNotEmpty) {
        final latestAttempt = latestAttemptSnapshot.docs.first;
        if (!latestAttempt['is_correct']) {
          incorrectWords.add(record.id);
        }
      }
    }

    if (incorrectWords.isEmpty) {
      // incorrectWords が空の場合、デフォルトの全単語を取得
      snapshot = await FirebaseFirestore.instance
          .collection('English_Skills')
          .doc('TOEIC')
          .collection(widget.level)
          .doc('Words')
          .collection('Word')
          .get();
    } else {
      snapshot = await FirebaseFirestore.instance
          .collection('English_Skills')
          .doc('TOEIC')
          .collection(widget.level)
          .doc('Words')
          .collection('Word')
          .where(FieldPath.documentId, whereIn: incorrectWords)
          .get();
    }
  } else {
    snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('QuizRecords_TOEIC')
        .where('is_correct', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .limit(3)
        .get();
  }

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

  Future<void> _saveResult(String selectedAnswer, QueryDocumentSnapshot wordData, bool isCorrect) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      print('ログイン中のユーザーがいません');
      return;
    }

    try {
      final userDoc = FirebaseFirestore.instance.collection('Users').doc(userId);
      final quizRecordsCollection = userDoc.collection('QuizRecords_TOEIC');
      final wordName = wordData['Word']; 
      final wordDocRef = quizRecordsCollection.doc(wordName); 

      final attemptsSnapshot = await wordDocRef.collection('Attempts').get();
      final attemptNumber = attemptsSnapshot.docs.length + 1;

      await wordDocRef.collection('Attempts').add({
        'attempt_number': attemptNumber,
        'timestamp': FieldValue.serverTimestamp(),
        'selected_answer': selectedAnswer,
        'correct_answer': wordData['ENG_to_JPN_Answer'],
        'is_correct': isCorrect,
        'word_id': wordData.id,
      });

      print('クイズ結果が保存されました: Word: $wordName, Attempt: $attemptNumber');
    } catch (e) {
      print('クイズ結果の保存に失敗しました: $e');
    }
  }

  void _handleTimeout() {
    setState(() {
      _saveResult('', questions[currentQuestionIndex], false);
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
            _saveResult(option, wordData, isCorrect); 
            isShowingAnswer = true;
          });

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
