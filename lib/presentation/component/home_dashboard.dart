// 必要なパッケージのインポート
import '/import.dart'; // アプリ全体で使用するインポートファイル
import 'package:table_calendar/table_calendar.dart'; // カレンダーUI用のパッケージ
import 'package:intl/intl.dart'; // 日付フォーマット用のパッケージ
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuthをインポート

// DashboardScreenクラスの宣言
class DashboardScreen extends StatefulWidget {
  final String selectedTab; // 選択されたタブの名前を保持する変数
  final String selectedCategory; // 選択されたカテゴリの名前を保持する変数
  final Function(int) onLoginStreakCalculated; // コールバック関数を追加

  // コンストラクタで初期化
  const DashboardScreen({super.key, 
    required this.selectedTab, 
    required this.selectedCategory, 
    required this.onLoginStreakCalculated,
    });

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

// DashboardScreenのステート管理用クラス
class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  DateTime? _selectedDay; // 選択された日付を保持する変数
  DateTime _focusedDay = DateTime.now(); // カレンダーのフォーカスされた日付
  Set<DateTime> _loggedInDays = {};

  // ユーザー情報や進捗データを格納する変数
  String userName = ""; // ユーザー名、初期値は空文字
  int loginStreak = 0; // 連続ログイン日数
  int longestStreak = 0; // 最長連続ログイン日数
  int totalLogins = 0;       // 総ログイン回数
  int tierProgress = 0; // 今日の達成度
  int wordCount = 66; // 単語数
  double tierProgress_all = 0.0; // 目標全体に対する達成度

  late AnimationController _controller; // アニメーションコントローラ
  late Animation<double> _progressAnimation; // 今日の達成度のアニメーション
  late Animation<double> _progressAllAnimation; // 目標達成度のアニメーション
  late Future<void> _userDataFuture; // Futureを保持する変数

  @override
  void initState() {
    super.initState();

     // 非同期処理を初期化時に実行し、結果を保持
    _userDataFuture = _fetchUserData();
    fetchTierProgress();

    // アニメーションコントローラの初期化
    _controller = AnimationController(
      duration: const Duration(seconds: 1), // 1秒間のア���メーション
      vsync: this, // アニメーションの更新を同期
    );

    // 今日の達成度のアニメーションの定義
    _progressAnimation = Tween<double>(begin: 0, end: tierProgress / 100)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic));
    
    // 目標達成度のアニメーションの定義
    _progressAllAnimation = Tween<double>(begin: 0, end: tierProgress_all / 100)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic));

    _controller.forward(); // アニメーションの再生開始
  }

  @override
  void didUpdateWidget(DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // カテゴリが変更された場合、データを再取得してアニメーションを更新
    if (oldWidget.selectedCategory != widget.selectedCategory) {
      _userDataFuture = _fetchUserData();
      fetchTierProgress();
    }
  }

  // Firestoreからユーザーデータを取得する非同期関数
  Future<void> _fetchUserData() async {
    try {
      // 現在のユーザーのUIDを取得
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userId = currentUser.uid;

        // Firestoreから特定のユーザーのデータを取得
        final userSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('auth_uid', isEqualTo: userId)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          final userData = userSnapshot.docs.first.data();
          userName = userData['user_name'] ?? 'Unknown'; // ユーザー名がない場合、"Unknown"を代入
          // login_historyを取得して計算


        final loginHistory = userData['login_history'] ?? [];
        _calculateLoginStats(loginHistory); // ここでログイン情報の計算
          // ログイン記録をセットに保存
          _loggedInDays = loginHistory
              .map((timestamp) => (timestamp as Timestamp).toDate())
              .map((date) => DateTime(date.year, date.month, date.day))
              .toSet()
              .cast<DateTime>(); // 型変換を追加
        }
      } else {
        print('ユーザーがログインしていません');
        userName = 'Unknown';
      }
    } catch (e) {
      print('データ取得エラー: $e'); // データ取得エラーの際にコンソールに表示
      userName = 'Unknown'; // エラー発生時は"Unknown"をセット
    }
  }

Future<void> fetchTierProgress() async {
  try {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print('ユーザーがログインしていません');
      return;
    }

    final userId = currentUser.uid;
    final category = widget.selectedCategory == '全体' ? 'TOEIC500点' : widget.selectedCategory;

    // ユーザードキュメントを取得
    final userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .get();

    if (!userDoc.exists) {
      print('ユーザードキュメントが見つかりません');
      return;
    }

    final followingSubjects =
        List<String>.from(userDoc.data()?['following_subjects'] ?? []);

    // TOEICスコア部分を抽出
    final toeicSubject = followingSubjects.firstWhere(
      (subject) => subject.startsWith('TOEIC'),
      orElse: () => '',
    );

    if (toeicSubject.isEmpty) {
      print('TOEIC情報がありません');
      return;
    }

    final scoreMatch = RegExp(r'\d+').firstMatch(toeicSubject);
    if (scoreMatch == null) {
      print('TOEICスコアの形式が不正です');
      return;
    }

    final score = scoreMatch.group(0); // 抽出されたスコア（X部分）

    final today = DateTime.now();
    final todayDate = DateFormat('yyyy-MM-dd').format(today); // フォーマットされた今日の日付
    final todayWordsDocRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('record')
        .doc(todayDate)
        .collection(category) // 選択されたカテゴリを使用
        .doc('Word');
        
    final todayWordsDocSnapshot = await todayWordsDocRef.get();
    final tierProgressToday = todayWordsDocSnapshot.data()?['tierProgress_today'] ?? 0;
    final tierProgressAll = todayWordsDocSnapshot.data()?['tierProgress_all'] ?? 0;

    final todayWordsGoalDocRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('record')
        .doc(todayDate);

    final todayWordsGoalDocSnapshot = await todayWordsGoalDocRef.get();
    final tierProgressTodayGoal = todayWordsGoalDocSnapshot.data()?['${category}_goal'] ?? 0;


    // tierProgress_all を単語数で割って計算
    final normalizedTierProgressAll = tierProgressAll / wordCount;
    final normalizedTierProgress = tierProgressToday / (tierProgressTodayGoal * 2);
    
    
    setState(() {
      // 目標達成度のアニメーション更新
      _progressAllAnimation = Tween<double>(
        begin: 0,
        end: normalizedTierProgressAll.toDouble(),
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
      );

      // 今日の達成度のアニメーション更新を追加
      _progressAnimation = Tween<double>(
        begin: 0,
        end: normalizedTierProgress.toDouble(),
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
      );

    });
    _controller.forward(from: 0);



    print('目標への達成度: $normalizedTierProgressAll'); // デバッグ用ログ
  } catch (e) {
    print('normalizedTierProgressAll 計算エラー: $e');
  }
}

void _calculateLoginStats(List<dynamic> loginHistory) {
  if (loginHistory.isEmpty) {
    setState(() {
      loginStreak = 0; // 今日までの連続ログイン日数
      longestStreak = 0; // 最長連続ログイン日数
      totalLogins = 0; // 総ログイン数
    });
    return;
  }


  final loginDates = loginHistory
      .map((timestamp) => (timestamp as Timestamp).toDate())
      .map((date) => DateTime(date.year, date.month, date.day))
      .toSet()
      .toList()
    ..sort((a, b) => a.compareTo(b)); // 日付を昇順にソート

  int currentStreak = 1; // 今日までの連続ログイン日数
  int maxStreak = 1; // 最長連続ログイン日数
  int total = loginDates.length; // 総ログイン日数
  int todayStreak = 0; // 今日の連続ログイン日数

  // 今日がログインしている場合
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  
  if (loginDates.first.isAtSameMomentAs(todayDate)) {
    todayStreak = 1; // 今日もログインしているので連続日数は1
  }

  // ログイン履歴をチェックして連続性を計算
  for (int i = 1; i < loginDates.length; i++) {
    if (loginDates[i - 1].difference(loginDates[i]).inDays == -1) {
      currentStreak++; // 連続している場合
    } else {
      maxStreak = currentStreak > maxStreak ? currentStreak : maxStreak; // 最長連続日数を更新
      currentStreak = 1; // 途切れたらリセット
    }
  }

  // 最後の連続日数を最長連続日数に反映
  maxStreak = currentStreak > maxStreak ? currentStreak : maxStreak;

  todayStreak=currentStreak;

  // 最長連続ログイン日数と今日までの連続ログイン日数をセット
  setState(() {
    loginStreak = todayStreak; // 今日までの連続ログイン日数
    longestStreak = maxStreak; // 最長連続ログイン日数
    totalLogins = total; // 総ログイン数
  });
  // 計算結果をコールバック関数で渡す
    widget.onLoginStreakCalculated(loginStreak);
}

  // 日付を表示するための関数
  String _getDisplayDate() {
    final displayDate = _selectedDay ?? DateTime.now(); // 選択されていない場合は今日の日付
    return "${DateFormat('yyyy年M月d日').format(displayDate)}の${widget.selectedCategory}の記録データ閲覧画面";
  }

  @override
  void dispose() {
    _controller.dispose(); // アニメーションコントローラの破棄
    super.dispose();
  }

 
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _userDataFuture, // 初期化時に設定したFutureを使用
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(valueColor:  AlwaysStoppedAnimation<Color>(Color(0xFF0ABAB5)),)); // データ取得中のインジケーター
        } else if (snapshot.hasError) {
          return Center(child: Text('データ取得エラー: ${snapshot.error}')); // エラーが発生した場合の表示
        } else {
          // データ取得後のUI表示
          return Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [                    // ユーザーの名前を表示
                    Text(
                      "$userNameさん、ナイスログイン！",
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "今日も学習を重ねていこう",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color.fromARGB(255, 130, 130, 130),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 統計、進捗、活動セクション
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Align(alignment: Alignment.center, child: _buildStatSection())),
                        Expanded(child: Align(alignment: Alignment.center, child: _buildProgressSection())),
                        Expanded(child: Align(alignment: Alignment.center, child: _buildActivitySection())),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Color.fromARGB(255, 200, 200, 200)),
                    const SizedBox(height: 10),
                    // 日付情報の表示
                    Text(
                      _getDisplayDate(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildStatSection() {
  return Column(
    children: [
      const SizedBox(height: 8),
      SizedBox(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "連続ログイン日数",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 100, 100, 100),
                fontSize: 13,
              ),
            ),
            Text(
              "$loginStreak日",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              "最高連続ログイン日数",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 130, 130, 130),
              ),
            ),
            Text(
              "$longestStreak日",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 130, 130, 130),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "総ログイン回数",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 130, 130, 130),
              ),
            ),
            Text(
              "$totalLogins回",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 130, 130, 130),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

  // 今日の進捗と目標達成度のUIセクション
  Widget _buildProgressSection() {
    return Column(
      children: [
        const SizedBox(height: 50),
        Stack(
          alignment: Alignment.center,
          children: [
            // 目標達成度の円形インジケーター
            AnimatedBuilder(
              animation: _progressAllAnimation,
              builder: (context, child) {
                return SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: _progressAllAnimation.value,
                    strokeWidth: 5,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0ABAB5)),
                  ),
                );
              },
            ),
            const Positioned(
              top: 9,
              child: Text(
                "目標への達成度",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 9,
                  color: Color.fromARGB(255, 100, 100, 100),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _progressAllAnimation,
              builder: (context, child) {
                final value = _progressAllAnimation.value;
                final displayValue = (value * 100).toInt() % 100;
                final cycles = (value * 100).toInt() ~/ 100;
                final colors = [
                  const Color(0xFF0ABAB5), // 1周目: 緑
                  const Color(0xFFFF8C00), // 2周目: オレンジ
                  const Color(0xFFFF0000), // 3周目: 赤
                  const Color(0xFFFF69B4), // 4周目: ピンク
                  const Color(0xFFFFD700), // 5周目: 黄色
                ];
                final color = cycles < 5 ? colors[cycles] : colors.last;
                
                return Positioned(
                  bottom: 0,
                  child: Text(
                    "$displayValue%",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: color
                    ),
                  ),
                );
              },
            ),
            // 今日の進捗の円形インジケーター
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                final value = _progressAnimation.value;
                final cycles = (value * 100).toInt() ~/ 100;
                final colors = [
                  const Color(0xFF0ABAB5), // 1周目: 緑
                  const Color(0xFFFF8C00), // 2周目: オレンジ
                  const Color(0xFFFF0000), // 3周目: 赤
                  const Color(0xFFFF69B4), // 4周目: ピンク
                  const Color(0xFFFFD700), // 5周目: 黄色
                ];
                
                return Stack(
                  children: [
                    for (int i = 0; i <= cycles; i++)
                      if (i < 5)
                        SizedBox(
                          width: 90,
                          height: 90,
                          child: CircularProgressIndicator(
                            value: i < cycles ? 1.0 : value % 1.0,
                            strokeWidth: 5,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(colors[i]),
                          ),
                        ),
                  ],
                );
              },
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _selectedDay == null || isSameDay(_selectedDay, DateTime.now())
                      ? "今日の学習達成度"
                      : "${DateFormat('yyyy年M月d日').format(_selectedDay!)}\n学習達成度",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 9,
                    color: Color.fromARGB(255, 100, 100, 100),
                  ),
                ),
                const SizedBox(height: 5),
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Text(
                      "${(_progressAnimation.value * 100).toInt()}%",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // カレンダーを表示するアクティビティセクション
  Widget _buildActivitySection() {
    return Column(
      children: [
        const SizedBox(height: 8),
        SizedBox(
          width: 200,
          height: 200,
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            calendarFormat: CalendarFormat.month,
            rowHeight: 20,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextFormatter: (date, locale) {
                return '${DateFormat('yyyy年', locale).format(date)}\n${DateFormat('M月', locale).format(date)}';
              },
              titleTextStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              decoration: const BoxDecoration(color: Colors.transparent),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              dowTextFormatter: (date, locale) => DateFormat.E(locale).format(date)[0],
              weekdayStyle: const TextStyle(fontSize: 12),
              weekendStyle: const TextStyle(fontSize: 12, color: Colors.red),
            ),
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Color(0xFF0ABAB5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              cellMargin: EdgeInsets.symmetric(vertical: 0.1, horizontal: 0.1),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;

                // 選択された日付の進捗を計算
                _calculateProgressForSelectedDay(); // 進捗を計算するメソッドを呼び出す
              });
            },
            calendarBuilders: CalendarBuilders(
              headerTitleBuilder: (context, date) {
                return Column(
                  children: [
                    Text(
                      DateFormat('yyyy年').format(date),
                      style: const TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    Text(
                      DateFormat('M月').format(date),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ],
                );
              },
              defaultBuilder: (context, day, focusedDay) {
                // ログイン記録の日付を`images/redfire.png`で表示
                final isLoggedInDay = _loggedInDays.contains(
                  DateTime(day.year, day.month, day.day),
                );
                if (isLoggedInDay) {
                  return Center(
                    child: Image.asset(
                      'images/redfire.png',
                      width: 12,
                      height: 12,
                    ),
                  );
                }
                return const Center(
                  child: Text(
                    '・',
                    style: TextStyle(fontSize: 12),
                  ),
                );
              },
              todayBuilder: (context, day, focusedDay) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF0ABAB5),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    DateFormat.d().format(day),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                );
              },
              selectedBuilder: (context, day, focusedDay) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    DateFormat.d().format(day),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                );
              },
              outsideBuilder: (context, day, focusedDay) {
                return const Center(
                  child: Text(
                    '•',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }



  // 選択された日付に基づいて達成度を計算するメソッドを実装
  void _calculateProgressForSelectedDay() async {
    if (_selectedDay == null) return;

    final todayDate = DateFormat('yyyy-MM-dd').format(_selectedDay!);
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print('ユーザーがログインしていません');
      return;
    }

    final userId = currentUser.uid;
    final category = widget.selectedCategory == '全体' ? 'TOEIC500点' : widget.selectedCategory;

    try {
      final todayWordsDocRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('record')
          .doc(todayDate)
          .collection(category) // 選択されたカテゴリを使用
          .doc('Word');

      final todayWordsDocSnapshot = await todayWordsDocRef.get();

      final todayWordsGoalDocRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('record')
        .doc(todayDate);

      double normalizedTierProgressAll;
      double normalizedTierProgress;

      if (todayWordsDocSnapshot.exists) {
        final tierProgressToday = todayWordsDocSnapshot.data()?['tierProgress_today'] ?? 0;
        final tierProgressAll = todayWordsDocSnapshot.data()?['tierProgress_all'] ?? 0;
        final todayWordsGoalDocSnapshot = await todayWordsGoalDocRef.get();
        final tierProgressTodayGoal = todayWordsGoalDocSnapshot.data()?['${category}_goal'] ?? 0;
        // tierProgress_all を単語数で割って計算
        normalizedTierProgressAll = tierProgressAll / wordCount;
        normalizedTierProgress = tierProgressToday / (tierProgressTodayGoal* 2); // 目標を考慮
      } else {
        // 今日のデータが存在しない場合、直近のデータを取得
        print("選択されていない場合");
         final previousDocSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('record')
          .where(FieldPath.documentId, isLessThan: todayDate) // 今日より前の日付を取得
          .orderBy(FieldPath.documentId, descending: true) // 降順でソート
          .limit(1) // 直近の1件を取得
          .get();

          
      if (previousDocSnapshot.docs.isNotEmpty) {
        final previousDocId = previousDocSnapshot.docs.first.id; // 直近のドキュメントIDを取得

        // 直近の日付のコレクションを取得
        final previousWordsDocRef = FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection('record')
            .doc(previousDocId) // 直近の日付のドキュメントを指定
            .collection(category) // 選択されたカテゴリを使用
            .doc('Word');
          
        final previousWordsDocSnapshot = await previousWordsDocRef.get();

        normalizedTierProgressAll = previousWordsDocSnapshot.data()?['tierProgress_all'] / wordCount;

      } else {
        normalizedTierProgressAll = 0; // 直近のデータもない場合は0
      }
      normalizedTierProgress = 0; // 今日の進捗は0
      }

      setState(() {
        // 目標達成度のアニメーション更新
        _progressAllAnimation = Tween<double>(
          begin: 0,
          end: normalizedTierProgressAll.toDouble(),
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
        );

        // 今日の達成度のアニメーション更新
        _progressAnimation = Tween<double>(
          begin: 0,
          end: normalizedTierProgress.toDouble(),
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
        );
      });
      _controller.forward(from: 0); // アニメーションを再生

      print('選択された日の目標への達成度: $normalizedTierProgressAll'); // デバッグ用ログ
    } catch (e) {
      print('選択された日のデータ取得エラー: $e');
    }
  }
}
