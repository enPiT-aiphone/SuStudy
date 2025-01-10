import '/import.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../authentication/login_history.dart';

class ResultPage_Short_Sentence extends StatefulWidget {
  final List<String?> selectedAnswers;
  final List<bool?> isCorrectAnswers;
  final List<QueryDocumentSnapshot> wordDetails;

  const ResultPage_Short_Sentence({super.key, 
    required this.selectedAnswers,
    required this.isCorrectAnswers,
    required this.wordDetails,
  });

  @override
  _ResultPage_Short_SentenceState createState() => _ResultPage_Short_SentenceState();
}

class _ResultPage_Short_SentenceState extends State<ResultPage_Short_Sentence> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    int correctCount = widget.isCorrectAnswers.where((answer) => answer == true).length;
    _progressAnimation = Tween<double>(begin: 0.0, end: correctCount / 3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

    Future<void> _addLoginHistoryAndNavigateHome() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('ログイン中のユーザーがいません');
      return;
    }

    // ログイン履歴を記録
    await addLoginHistory(userId);

    // ホーム画面に遷移
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    int correctCount = widget.isCorrectAnswers.where((answer) => answer == true).length;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0), // AppBarの高さを設定
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0ABAB5), Color.fromARGB(255, 255, 255, 255)], // グラデーションの色設定
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent, // AppBar自体の背景色を透明に
            elevation: 0,
            title: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => _addLoginHistoryAndNavigateHome(),

                ),
                const SizedBox(width: 10),
                const Text(
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FractionallySizedBox(
              widthFactor: 0.67,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9E9E9),
                  border: Border.all(color: const Color(0xFFE9E9E9), width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Text(
                      '正答率',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                          '/3',
                          style: TextStyle(fontSize: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return SizedBox(
                            height: 20,
                            child: Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
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
                // itemCountをisCorrectAnswersの長さに合わせる
                itemCount: widget.isCorrectAnswers.length, 
                itemBuilder: (context, index) {
                  // インデックスが範囲外でないか確認
                  if (index >= widget.wordDetails.length || index >= widget.selectedAnswers.length) {
                    return Container(); // 範囲外の場合、空のコンテナを返す
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${index + 1}. ${wordData['Answer']}',
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
                            const Icon(Icons.arrow_forward_ios, color: Color(0xFF818181)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            )

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
                    '${wordData['Answer']} ',
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
                            '　${wordData['Explanation_1']}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
}