import '/import.dart';


class TOEICWordQuiz extends StatefulWidget {
  final String level;

  const TOEICWordQuiz({required this.level, Key? key}) : super(key: key);

  @override
  _TOEICWordQuizState createState() => _TOEICWordQuizState();
}

// カスタムペインターで、バツ（×）印を描画するクラス
class CrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color(0xFFFF5252)  // バツ印の色（赤）
      ..strokeWidth = 6;  // 線の太さを設定

    // 右上がりの斜線を描画
    canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), paint);
    // 左上がりの斜線を描画
    canvas.drawLine(Offset(size.width, size.height), Offset(0, 0), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;  // 再描画が必要ない場合はfalseを返す
  }
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
  late AnimationController _animationController;  // アニメーションコントローラー
  late Animation<double> _animation;  // アニメーションの進捗

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),  // 5秒でアニメーションが完了する
    );

    // 0から1までのアニメーションを設定
    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });

    // アニメーションが終了したら自動的に時間切れの処理を呼ぶ
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
        .doc('TOEIC')
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
        _startTimer();  // タイマーを開始
      });
    }
  }

  void _startTimer() {
    _animationController.reset();  // タイマーをリセット
    _animationController.forward();  // アニメーション開始
  }

  // 5秒以内に回答されなかった場合の処理
  void _handleTimeout() {
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
            _startTimer();  // 次の問題に進む時にタイマーを再スタート
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF0ABAB5),
        automaticallyImplyLeading: false,
        title: Row(
          children: const [
            Text(
              'SuStudy, ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
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
          // プログレスバー（アニメーションバー）
          LinearProgressIndicator(
            borderRadius: BorderRadius.circular(20),
            value: _animation.value,  // アニメーションの値でバーを更新
            backgroundColor: const Color(0xFFD9D9D9),  // バックグラウンド色
            color: const Color(0xFF0ABAB5),  // バーの色
            minHeight: 20,  // バーの高さ
          ),
          const SizedBox(height: 20),
          Expanded(
            flex: 5,
            child: Center(
              child: Text(
                wordData['Word'],
                style: const TextStyle(
                  fontSize: 30,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              '${currentQuestionIndex + 1}/5',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0ABAB5),
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
    Color? borderColor;

    if (isShowingAnswer) {
      if (option == wordData['ENG_to_JPN_Answer']) {
        backgroundColor = const Color(0xFFE0F7FA);
        borderColor = const Color(0xFF0ABAB5);
      } else if (selectedAnswers[currentQuestionIndex] == option) {
        backgroundColor = const Color(0xFFFFEBEE);
        borderColor = const Color(0xFFFF5252);
      }
    } else {
      backgroundColor = Colors.white;
      borderColor = const Color(0xFF0ABAB5);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          bool isCorrect = option == wordData['ENG_to_JPN_Answer'];
          _animationController.stop();  // 回答されたらタイマーを停止
          setState(() {
            selectedAnswers[currentQuestionIndex] = option;
            isCorrectAnswers[currentQuestionIndex] = isCorrect;
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
                _startTimer();  // 次の問題に進む際にタイマーをリスタート
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
            border: Border.all(color: borderColor ?? const Color(0xFF0ABAB5)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            option,
            style: const TextStyle(fontSize: 18, color: Color(0xFF0ABAB5)),
          ),
        ),
      ),
    );
  }
}
