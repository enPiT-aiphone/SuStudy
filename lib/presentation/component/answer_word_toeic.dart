import '/import.dart';

class ResultPage extends StatefulWidget {
  final List<String?> selectedAnswers;
  final List<bool?> isCorrectAnswers;
  final List<QueryDocumentSnapshot> wordDetails;

  ResultPage({
    required this.selectedAnswers,
    required this.isCorrectAnswers,
    required this.wordDetails,
  });

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    // アニメーションコントローラーの初期化
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),  // アニメーションの長さ
    );

    // 正答率に応じてアニメーションの進捗を設定
    int correctCount = widget.isCorrectAnswers.where((answer) => answer == true).length;
    _progressAnimation = Tween<double>(begin: 0.0, end: correctCount / 5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // アニメーションの開始
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 正解数をカウント
    int correctCount = widget.isCorrectAnswers.where((answer) => answer == true).length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0ABAB5),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => TOEICLevelSelection()),
                  (route) => false,
                );
              },
            ),
            const SizedBox(width: 8),
            const Text(
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 正答率と X/5 を囲む枠の追加（横幅2/3）
            FractionallySizedBox(
              widthFactor: 0.67,  // 横幅を画面の2/3に設定
              child: Container(
                padding: const EdgeInsets.all(16.0),  // 内側の余白
                decoration: BoxDecoration(
                  color: const Color(0xFFE9E9E9),
                  border: Border.all(color: const Color(0xFFE9E9E9), width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      '正答率',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$correctCount',
                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          '/5',
                          style: TextStyle(fontSize: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 正答率に応じたアニメーションバー
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),  // 両端を丸める
                      child: AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return Container(
                            height: 20,
                            child: Stack(
                              children: [
                                // 背景のバー
                                Container(
                                  width: double.infinity,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                // 正答率バー
                                FractionallySizedBox(
                                  widthFactor: _progressAnimation.value,
                                  child: Container(
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0ABAB5),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: widget.wordDetails.length,
                itemBuilder: (context, index) {
                  if (index >= widget.selectedAnswers.length || index >= widget.isCorrectAnswers.length) {
                    return Container();
                  }

                  var wordData = widget.wordDetails[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: GestureDetector(
                      onTap: () {
                        _showWordDetailsDialog(context, wordData);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: widget.isCorrectAnswers[index] == true
                              ? const Color(0xFFE0F7FA)
                              : const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: widget.isCorrectAnswers[index] == true
                                ? const Color(0xFF0ABAB5)
                                : const Color(0xFFFF5252),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${index + 1}. ${wordData['Word']}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: widget.isCorrectAnswers[index] == true
                                    ? const Color(0xFF0ABAB5)
                                    : const Color(0xFFFF5252),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.isCorrectAnswers[index] == true ? '正解' : '不正解',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: widget.isCorrectAnswers[index] == true
                                    ? const Color(0xFF0ABAB5)
                                    : const Color(0xFFFF5252),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWordDetailsDialog(BuildContext context, QueryDocumentSnapshot wordData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${wordData['Word']} ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                  if (wordData['Phonetic_Symbols'] != null && wordData['Phonetic_Symbols'].isNotEmpty)
                    Text(
                      '[${wordData['Phonetic_Symbols']}]',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '解説: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FractionallySizedBox(
                          widthFactor: 0.85,
                          child: Text(
                            '　${wordData['Explanation']}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: _buildMeaningRow(
                    '意味',
                    {
                      '名': wordData['Meaning_Noun'],
                      '動': wordData['Meaning_Verb'],
                      '形': wordData['Meaning_Adjective'],
                      '副': wordData['Meaning_Adverb'],
                      '前': wordData['Meaning_Preposition'],
                    },
                  ),
                ),
                _buildDetailRow('名詞形', wordData['Word_Noun']),
                _buildDetailRow('動詞形', wordData['Word_Verb']),
                _buildDetailRow('形容詞形', wordData['Word_Adjective']),
                _buildDetailRow('副詞形', wordData['Word_Adverb']),
                _buildDetailRow('前置詞形', wordData['Word_Preposition']),
                _buildDetailRow('類義語', wordData['Word_Synonyms']),
                _buildDetailRow('対義語', wordData['Word_Antonym']),
                _buildDetailRow('関連語', wordData['Word_Related']),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    if (value == null || value.isEmpty) return Container();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildMeaningRow(String label, Map<String, String?> meanings) {
    List<String> meaningParts = [];

    meanings.forEach((partOfSpeech, meaning) {
      if (meaning != null && meaning.isNotEmpty) {
        meaningParts.add('$partOfSpeech: $meaning');
      }
    });

    if (meaningParts.isEmpty) return Container();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: meaningParts
                  .map((part) => Text(part))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
