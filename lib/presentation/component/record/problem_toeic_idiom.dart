import '/import.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'result_idiom_toeic_toefl.dart';


class TOEICIdiomQuiz extends StatefulWidget {
  final String level; // TOEICレベル
  final String questionType; // 出題タイプ（random, unanswered, incorrect, recent_incorrect）

  const TOEICIdiomQuiz({required this.level, required this.questionType, super.key});

  @override
  _TOEICIdiomQuizState createState() => _TOEICIdiomQuizState();
}

// バツ（×）印を描画するカスタムペインター
class CrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color(0xFFFF5252)
      ..strokeWidth = 6;

    canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), paint);
    canvas.drawLine(Offset(size.width, size.height), const Offset(0, 0), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _TOEICIdiomQuizState extends State<TOEICIdiomQuiz> with SingleTickerProviderStateMixin {
  int currentQuestionIndex = 0;
  List<QueryDocumentSnapshot> questions = [];
  List<List<String>> shuffledOptions = [];
  List<String?> selectedAnswers = List.filled(5, null);
  List<bool?> isCorrectAnswers = List.filled(5, null);
  bool isDataLoaded = false;
  bool isShowingAnswer = false;
  //bool isShuffle=false;
  List<String> askedIdiomIds = [];
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Animation<Color?> _colorAnimation;
  //List<String> answers = List.filled(4, '', growable: false);

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
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
  final userId = FirebaseAuth.instance.currentUser?.uid;

  if (userId == null) {
    print('ユーザーがログインしていません');
    return;
  }

  try {
    final today = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(today);
    final scoreMatch = RegExp(r'up_to_(\d+)').firstMatch(widget.level);
    final extractedLevel = scoreMatch != null ? scoreMatch.group(1) : '0'; // スコアを抽出

    if (extractedLevel == '0') {
      print('レベル情報が不正です: ${widget.level}');
      return;
    }

    // Recordサブコレクションの参照
    final recordRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('record')
        .doc(formattedDate)
        .collection('TOEIC${extractedLevel}点')
        .doc('Idioms');  

    QuerySnapshot snapshot;

     // Idioms ドキュメントの存在確認
    final idiomDocSnapshot = await recordRef.get();
    if (!idiomDocSnapshot.exists) {
      // "Idioms" ドキュメントが存在しない場合、新規に作成
      await recordRef.set({
        'answeredIdiomId': []  // ここでデフォルトのフィールドをセット
      });
      print('Idioms ドキュメントが存在しなかったため、新たに作成しました');
    }

    if (widget.questionType == 'random') {
      // ランダムなイディオムの問題を取得
      snapshot = await FirebaseFirestore.instance
          .collection('English_Skills')
          .doc('TOEIC')
          .collection(widget.level)
          .doc('Words') 
          .collection('Idioms')
          .get();
    } else if (widget.questionType == 'unanswered') {
      // 未回答のイディオムの問題を取得
      List<String> answeredIdiomIds = [];

      try {
        // `Idiom` ドキュメントの `answeredIdiomId` フィールドを取得
        final idiomDocSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection('record')
            .doc(formattedDate)
            .collection('TOEIC${extractedLevel}点')
            .doc('Idioms')  // "Word" から "Idiom" に変更
            .get();

        // 'Idioms' ドキュメントが存在しない場合、作成して必要なデータを設定
        if (!idiomDocSnapshot.exists) {
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(userId)
              .collection('record')
              .doc(formattedDate)
              .collection('TOEIC${extractedLevel}点')
              .doc('Idioms')
              .set({
            'answeredIdiomId': []  // 初期化など
          });
          print('Idioms ドキュメントが存在しなかったため、新たに作成しました');
        }

        if (idiomDocSnapshot.exists) {
          // `answeredIdiomId` リストを取得
          final idiomData = idiomDocSnapshot.data();
          if (idiomData != null && idiomData['answeredIdiomId'] is List) {
            answeredIdiomIds = List<String>.from(idiomData['answeredIdiomId']);
          }
        }

        if (answeredIdiomIds.isEmpty) {
          // 未回答の問題を全取得
          snapshot = await FirebaseFirestore.instance
              .collection('English_Skills')
              .doc('TOEIC')
              .collection(widget.level)
              .doc('Words')  // "Words" から "Idioms" に変更
              .collection('Idioms')
              .get();
        } else {
          // 未回答の問題をフィルタリング
          snapshot = await FirebaseFirestore.instance
              .collection('English_Skills')
              .doc('TOEIC')
              .collection(widget.level)
              .doc('Words')  // "Words" から "Idioms" に変更
              .collection('Idioms')
              .where(FieldPath.documentId, whereNotIn: answeredIdiomIds)
              .get();
        }
      } catch (e) {
        print('未回答の問題取得中にエラーが発生しました: $e');
        return;
      }
    } else if (widget.questionType == 'incorrect') {
      // 間違えたイディオムの問題を取得
      List<String> incorrectIdiomIds = [];

      // Idiom サブコレクションのデータを確認して間違えたイディオムを収集
      final idiomDocs = await recordRef.get();
      for (var idiomDoc in idiomDocs.data()!.keys) {
        final attemptsSnapshot = await recordRef
            .collection(idiomDoc)
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        for (var attempt in attemptsSnapshot.docs) {
          if (!(attempt.data()['is_correct'] as bool)) {
            incorrectIdiomIds.add(idiomDoc);
            break;
          }
        }
      }

      if (incorrectIdiomIds.isEmpty) {
        snapshot = await FirebaseFirestore.instance
            .collection('English_Skills')
            .doc('TOEIC')
            .collection(widget.level)
            .doc('Words')  // "Words" から "Idioms" に変更
            .collection('Idioms')
            .get();
      } else {
        snapshot = await FirebaseFirestore.instance
            .collection('English_Skills')
            .doc('TOEIC')
            .collection(widget.level)
            .doc('Words')  // "Words" から "Idioms" に変更
            .collection('Idioms')
            .where(FieldPath.documentId, whereIn: incorrectIdiomIds)
            .get();
      }
    } else {
      // 直近3問の間違えたイディオムの問題を取得
      List<String> recentIdiomIds = [];

      // Idiom サブコレクションを確認して間違えた問題を収集
      final idiomDocs = await recordRef.get();
      for (var idiomDoc in idiomDocs.data()!.keys) {
        final attemptsSnapshot = await recordRef
            .collection(idiomDoc)
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        if (attemptsSnapshot.docs.isNotEmpty) {
          final attemptData = attemptsSnapshot.docs.first.data();
          if (!(attemptData['is_correct'] as bool)) {
            recentIdiomIds.add(idiomDoc);
          }
        }

        if (recentIdiomIds.length >= 3) break;
      }

      if (recentIdiomIds.isEmpty) {
        snapshot = await FirebaseFirestore.instance
            .collection('English_Skills')
            .doc('TOEIC')
            .collection(widget.level)
            .doc('Words')  // "Words" から "Idioms" に変更
            .collection('Idioms')
            .get();
      } else {
        snapshot = await FirebaseFirestore.instance
            .collection('English_Skills')
            .doc('TOEIC')
            .collection(widget.level)
            .doc('Words')  
            .collection('Idioms')
            .where(FieldPath.documentId, whereIn: recentIdiomIds)
            .get();
      }
    }

    List<QueryDocumentSnapshot> allQuestions = snapshot.docs;
    questions = allQuestions.where((doc) => !askedIdiomIds.contains(doc.id)).toList();

    if (questions.isNotEmpty) {
      if (questions.length > 5) {
        questions.shuffle();
        questions = questions.take(5).toList();
      }

      for (var question in questions) {
        List<String> options = [
          question['Answer_A'],  // イディオムに対応する選択肢に変更
          question['Answer_B'],
          question['Answer_C'],
          question['Answer_D'],
        ];
        options.shuffle();
        shuffledOptions.add(options);
      }

      setState(() {
        isDataLoaded = true;
        _startTimer();
      });
    }
  } catch (e) {
    print('エラーが発生しました: $e');
  }
}




  void _startTimer() {
    _animationController.reset();
    _animationController.forward();
  }


Future<void> _updateTierProgress(
    QueryDocumentSnapshot wordData, String wordName, bool isCorrect) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  if (userId == null) {
    print('ユーザーがログインしていません');
    return;
  }

  try {
    // 現在の日付をフォーマット
    final recordDate = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(recordDate);

    // `level` からスコアを抽出 (例: up_to_500 -> 500)
    final scoreMatch = RegExp(r'up_to_(\d+)').firstMatch(widget.level);
    final extractedLevel = scoreMatch != null ? scoreMatch.group(1) : '0'; // スコアを抽出

    if (extractedLevel == '0') {
      print('レベル情報が不正です: ${widget.level}');
      return;
    }

    // Firestore パス
    final recordRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('record')
        .doc(formattedDate)
        .collection('TOEIC${extractedLevel}点')
        .doc('Idioms');

     final dateRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('record')
        .doc(formattedDate);

    double tierProgress = 0.0;
    double tierProgressAll = 0.0;
    double tSolvedCount = 0.0;

    // 現在の `tierProgress_all` を取得
    final recordSnapshot = await recordRef.get();
    final dateSnapshot = await dateRef.get();
    if (recordSnapshot.exists) {
      tierProgress = recordSnapshot.data()?['tierProgress_today'] ?? 0;
      tierProgressAll = recordSnapshot.data()?['tierProgress_all'] ?? 0;
      tSolvedCount = dateSnapshot.data()?['t_solved_count'] ?? 0;
    }

    // Attempts サブコレクションから最新の試行データを取得
    final attemptsSnapshot = await recordRef.collection(wordData.id)
        .orderBy('attempt_number', descending: true)
        .limit(1)
        .get();

    // 最新試行データがない場合（初めての試行）
    if (attemptsSnapshot.docs.isEmpty) {
      if (isCorrect) {
        tierProgress += 1;
        tSolvedCount += 1;
        await recordRef.update({'tierProgress_today': tierProgress});
        await dateRef.update({'t_solved_count': tSolvedCount});
        tierProgressAll += 1;
        await recordRef.update({'tierProgress_all': tierProgressAll});
        print('初めての試行: 正解 +1');
      } else {
        await recordRef.update({'tierProgress_today': tierProgress});
        await dateRef.update({'t_solved_count': tSolvedCount});
        await recordRef.update({'tierProgress_all': tierProgressAll});
        print('初めての試行: 不正解のためそのまま');
      }
      return;
    }

    // 最新試行データを取得
    final latestAttempt = attemptsSnapshot.docs.first;
    final bool? latestIsCorrect = latestAttempt.data()['is_correct'];

    // `is_correct` フィールドがない場合の初期化
    if (latestIsCorrect == null) {
      print('最新試行データに is_correct フィールドが存在しません');
      return;
    }

    // tierProgress_all の更新ロジック
    if (!latestIsCorrect && isCorrect) {
      // 直近間違えていて、今回正解した場合
      tierProgress += 1;
      tierProgressAll += 1;
      tSolvedCount += 1;
      print('直近間違えていて、今回正解: +1');
    } else if (latestIsCorrect && !isCorrect) {
      // 直近正解していて、今回間違えた場合
      tierProgress -= 1;
      tierProgressAll -= 1;
      tSolvedCount -= 1;
      if (tierProgress < 0) tierProgress = 0;
      if (tSolvedCount < 0) tSolvedCount = 0;
      print('直近正解していて、今回間違え: -1');
    } else if (latestIsCorrect && isCorrect) {
      print('直近正解していて、今回も正解: そのまま');
    } else if (!latestIsCorrect && !isCorrect) {
      print('直近間違えていて、今回も間違え: そのまま');
    }

    // tierProgress_all を Firestore に保存
    await dateRef.update({'t_solved_count': tSolvedCount});
    await recordRef.update({'tierProgress_today': tierProgress});
    await recordRef.update({'tierProgress_all': tierProgressAll});
    print('date ドキュメントの t_solved_count が更新されました: $tSolvedCount');
    print('Words ドキュメントの tierProgress_today が更新されました: $tierProgress');
    print('Words ドキュメントの tierProgress_all が更新されました: $tierProgressAll');
  } catch (e) {
    print('t_solved_count 更新に失敗しました: $e');
    print('tierProgress_today 更新に失敗しました: $e');
    print('tierProgress_all 更新に失敗しました: $e');
  }
}



// 保存メソッド
Future<void> _saveRecord(
    String selectedAnswer, QueryDocumentSnapshot idiomData, bool isCorrect) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  if (userId == null) {
    print('ユーザーがログインしていません');
    return;
  }

  try {
    final recordDate = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(recordDate);
    // `up_to_X` から `X` を抽出
    final levelMatch = RegExp(r'up_to_(\d+)').firstMatch(widget.level);
    final extractedLevel = levelMatch != null ? levelMatch.group(1) : '0'; // `X` を取得、なければ '0'

    if (extractedLevel == '0') {
      print('レベル情報が不正です: ${widget.level}');
      return;
    }

    await _updateTierProgress(idiomData, idiomData['Idioms'], isCorrect);

    // Firestore パス
    final recordRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('record')
        .doc(formattedDate);

    final idiomDoc = recordRef.collection('TOEIC${extractedLevel}点').doc('Idioms');
    final idiomRef = recordRef.collection('TOEIC${extractedLevel}点').doc('Idioms').collection(idiomData.id);

    // Attempts サブコレクションの次のドキュメント名を決定
    final attemptsSnapshot = await recordRef.collection('TOEIC${extractedLevel}点').doc('Idioms').collection(idiomData.id).get();
    final attemptNumber = attemptsSnapshot.docs.length + 1;

    // データを保存
    await idiomRef.doc('$attemptNumber').set({
      'attempt_number': attemptNumber,
      'timestamp': FieldValue.serverTimestamp(),
      'selected_answer': selectedAnswer,
      'correct_answer': idiomData['Answer'],
      'is_correct': isCorrect,
      'idiom_id': idiomData.id,
    }, SetOptions(merge: true));

    final currentIdiomList = (await idiomDoc.get()).data()?['answeredIdiomId'] ?? [];
    if (!currentIdiomList.contains(idiomData.id)) {
      currentIdiomList.add(idiomData.id);
      await idiomDoc.set({
        'answeredIdiomId': currentIdiomList,
      }, SetOptions(merge: true));
    }

    // solved_count を 1 増やす
    await idiomDoc.set({
      't_solved_count': FieldValue.increment(1),
    }, SetOptions(merge: true));

    await recordRef.update({
      't_solved_count_TOEIC${extractedLevel}点': FieldValue.increment(1),
    });

    print('クイズ結果が保存されました: ${idiomData.id}, Attempt: $attemptNumber');
  } catch (e) {
    print('レコードの保存中にエラーが発生しました: $e');
  }
}


  void _handleTimeout() {
  setState(() {
    _saveRecord('', questions[currentQuestionIndex], false);
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
            builder: (context) => ResultPage_Idiom(
              selectedAnswers: selectedAnswers,
              isCorrectAnswers: isCorrectAnswers,
              idiomDetails: questions,
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
            title: const Row(
              children: [
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
          : const Center(child: CircularProgressIndicator(valueColor:  AlwaysStoppedAnimation<Color>(Color(0xFF0ABAB5)),)),
    );
  }


Widget _buildQuestionUI(QueryDocumentSnapshot idiomData) {
  final screenHeight = MediaQuery.of(context).size.height;
  final options = shuffledOptions[currentQuestionIndex]; // 事前にシャッフルされた選択肢を取得

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      children: [
        // プログレスバー
        LinearProgressIndicator(
          borderRadius: BorderRadius.circular(20),
          value: _animation.value,
          backgroundColor: const Color(0xFFD9D9D9),
          valueColor: AlwaysStoppedAnimation<Color?>(_colorAnimation.value),
          minHeight: 20,
        ),
        const SizedBox(height: 20),
        
        // Spacerを追加して間隔を調整
        const Spacer(flex: 2),
        
        // 質問文
        Expanded(
          flex: 4,
          child: SingleChildScrollView( // 長いテキストに対応
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  idiomData['Question'], // 問題文を表示
                  style: const TextStyle(
                    fontSize: 30,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible, // テキストを切り捨てずに表示
                ),
                const SizedBox(height: 8),
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
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // 選択肢
        Expanded(
          flex: 5,
          child: ListView(
            children: [
              // 事前にシャッフルされた選択肢を表示
              _buildAnswerButton(options[0], idiomData, screenHeight),
              _buildAnswerButton(options[1], idiomData, screenHeight),
              _buildAnswerButton(options[2], idiomData, screenHeight),
              _buildAnswerButton(options[3], idiomData, screenHeight),
            ],
          ),
        ),
      ],
    ),
  );
}






  Widget _buildAnswerButton(String option, QueryDocumentSnapshot idiomData, double screenHeight) {
    Color? backgroundColor;
    Color finalBorderColor = _colorAnimation.value ?? const Color(0xFF0ABAB5);

    if (isShowingAnswer) {
      if (option == idiomData['Answer']) {
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
          bool isCorrect = option == idiomData['Answer'];
          _animationController.stop();
          setState(() {
            selectedAnswers[currentQuestionIndex] = option;
            isCorrectAnswers[currentQuestionIndex] = isCorrect;
            _saveRecord(option, idiomData, isCorrect);
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
                  builder: (context) => ResultPage_Idiom(
                    selectedAnswers: selectedAnswers,
                    isCorrectAnswers: isCorrectAnswers,
                    idiomDetails: questions,
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
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

}
