import '/import.dart';
/*
class ToeicWordQuiz extends StatefulWidget {
  final String level;  // レベルを動的に渡す

  ToeicWordQuiz({required this.level});

  @override
  _ToeicWordQuizState createState() => _ToeicWordQuizState();
}

class _ToeicWordQuizState extends State<ToeicWordQuiz> {
  late QueryDocumentSnapshot currentWordData;
  bool isLoaded = false;
  bool isAnswered = false;
  bool isCorrect = false;

  @override
  void initState() {
    super.initState();
    _loadNewWord();
  }

  Future<void> _loadNewWord() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('English_Skills')
        .doc('TOEIC')
        .collection(widget.level)
        .doc('Words')
        .collection('Word')
        .orderBy('Word_id')
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        currentWordData = snapshot.docs[0];
        isLoaded = true;
        isAnswered = false;
        isCorrect = false;
      });
    }
  }

  void _checkAnswer(String selectedAnswer) {
    setState(() {
      isAnswered = true;
      isCorrect = (selectedAnswer == currentWordData['ENG_to_JPN_Answer']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TOEIC Word Quiz (${widget.level})'),
      ),
      body: isLoaded
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Word: ${currentWordData['Word'] ?? 'No Word'}',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(height: 20),
                  Text('Choose the correct translation:'),
                  SizedBox(height: 10),
                  if (!isAnswered) ...[
                    _buildOptionButton(currentWordData['ENG_to_JPN_Answer_A']),
                    _buildOptionButton(currentWordData['ENG_to_JPN_Answer_B']),
                    _buildOptionButton(currentWordData['ENG_to_JPN_Answer_C']),
                    _buildOptionButton(currentWordData['ENG_to_JPN_Answer_D']),
                  ] else ...[
                    Text(
                      isCorrect ? 'Correct!' : 'Wrong!',
                      style: TextStyle(
                        color: isCorrect ? Colors.green : Colors.red,
                        fontSize: 24,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loadNewWord,
                      child: Text('Next Question'),
                    )
                  ],
                ],
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildOptionButton(String optionText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () => _checkAnswer(optionText),
        child: Text(optionText),
      ),
    );
  }
}
*/

//デザインコード
void main() {
  runApp(const FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: Scaffold(
        body: ListView(
          children: [
            TOEICWordQuiz(level: 'up_to_700'), // 'level'を渡す
          ],
        ),
      ),
    );
  }
}

class TOEICWordQuiz extends StatefulWidget {
  final String level; // レベルを受け取る

  TOEICWordQuiz({required this.level});

  @override
  _TOEICWordQuizState createState() => _TOEICWordQuizState();
}

class _TOEICWordQuizState extends State<TOEICWordQuiz> {
  int currentQuestionIndex = 0;
  List<QueryDocumentSnapshot> questions = [];
  List<String?> selectedAnswers = List.filled(5, null);
  List<bool?> isCorrectAnswers = List.filled(5, null);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 360,
          height: 640,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 360,
                  height: 42,
                  decoration: BoxDecoration(color: Color(0xFF0ABAB5)),
                ),
              ),
              Positioned(
                left: 103,
                top: 71,
                child: Container(
                  width: 154,
                  height: 140,
                  decoration: ShapeDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://via.placeholder.com/154x140"),
                      fit: BoxFit.fill,
                    ),
                    shape: OvalBorder(),
                  ),
                ),
              ),
              Positioned(
                left: 28,
                top: 7,
                child: Text(
                  'SuStudy',
                  style: TextStyle(
                    color: Color(0xFFFBFAFA),
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    height: 0,
                  ),
                ),
              ),
              Positioned(
                left: 28,
                top: 220,
                child: Container(
                  width: 305,
                  height: 304,
                  decoration: ShapeDecoration(
                    color: Color(0xFF81D8D0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('English_Skills')
                        .doc('TOEIC')
                        .collection(widget.level) // 渡されたlevelを使用
                        .doc('Words')
                        .collection('Word')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      questions = snapshot.data!.docs;
                      if (questions.isEmpty) {
                        return Center(child: Text('No words available'));
                      }

                      // 現在の問題を表示
                      return _buildQuestionUI(questions[currentQuestionIndex]);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionUI(QueryDocumentSnapshot wordData) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          wordData['Word'],
          style: TextStyle(
            color: Color(0xFF252525),
            fontSize: 20,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 20),
        Text(
          '正しい日本語訳を選択してください。',
          style: TextStyle(
            color: Color(0xFF252525),
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 20),
        for (var option in [
          wordData['ENG_to_JPN_Answer_A'],
          wordData['ENG_to_JPN_Answer_B'],
          wordData['ENG_to_JPN_Answer_C'],
          wordData['ENG_to_JPN_Answer_D'],
        ])
          ListTile(
            title: Text(option),
            leading: Radio<String>(
              value: option,
              groupValue: selectedAnswers[currentQuestionIndex],
              onChanged: (value) {
                setState(() {
                  selectedAnswers[currentQuestionIndex] = value;
                  isCorrectAnswers[currentQuestionIndex] =
                      selectedAnswers[currentQuestionIndex] == wordData['ENG_to_JPN_Answer'];
                });
              },
            ),
          ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            if (currentQuestionIndex < 4) {
              setState(() {
                currentQuestionIndex++;
              });
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultPage(
                    selectedAnswers: selectedAnswers,
                    isCorrectAnswers: isCorrectAnswers,
                    wordDetails: questions, // 単語データを渡す
                  ),
                ),
              );
            }
          },
          child: Text(currentQuestionIndex < 4 ? '次の問題' : '答え合わせ'),
        ),
      ],
    );
  }
}

class ResultPage extends StatelessWidget {
  final List<String?> selectedAnswers;
  final List<bool?> isCorrectAnswers;
  final List<QueryDocumentSnapshot> wordDetails;

  ResultPage({
    required this.selectedAnswers,
    required this.isCorrectAnswers,
    required this.wordDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('結果'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: 5, // 5問の結果を表示
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('問題 ${index + 1}'),
              subtitle: Text(isCorrectAnswers[index]! ? '正解' : '不正解'),
              onTap: () {
                // 詳細ページへ遷移
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WordDetailPage(
                      wordData: wordDetails[index],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class WordDetailPage extends StatelessWidget {
  final QueryDocumentSnapshot wordData;

  WordDetailPage({required this.wordData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(wordData['Word'] ?? 'Word Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Word', wordData['Word']),
            _buildDetailRow('Phonetic Symbols', wordData['Phonetic_Symbols']),
            _buildDetailRow('Meaning (Noun)', wordData['Meaning_Noun']),
            _buildDetailRow('Meaning (Verb)', wordData['Meaning_Verb']),
            _buildDetailRow('Meaning (Preposition)', wordData['Meaning_Preposition']),
            _buildDetailRow('Meaning (Adverb)', wordData['Meaning_Adverb']),
            _buildDetailRow('Meaning (Adjective)', wordData['Meaning_Adjective']),
            _buildDetailRow('Explanation', wordData['Explanation']),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value ?? 'N/A'),
          ),
        ],
      ),
    );
  }
}
