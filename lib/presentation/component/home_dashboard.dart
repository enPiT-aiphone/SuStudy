// 必要なパッケージのインポート
import '/import.dart'; // アプリ全体で使用するインポートファイル
import 'package:table_calendar/table_calendar.dart'; // カレンダーUI用のパッケージ
import 'package:intl/intl.dart'; // 日付フォーマット用のパッケージ
import 'package:flutter/material.dart'; // Flutter UIのための基本パッケージ

// DashboardScreenクラスの宣言
class DashboardScreen extends StatefulWidget {
  final String selectedTab; // 選択されたタブの名前を保持する変数
  final String selectedCategory; // 選択されたカテゴリの名前を保持する変数

  // コンストラクタで初期化
  DashboardScreen({required this.selectedTab, required this.selectedCategory});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

// DashboardScreenのステート管理用クラス
class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  DateTime? _selectedDay; // 選択された日付を保持する変数
  DateTime _focusedDay = DateTime.now(); // カレンダーのフォーカスされた日付

  // ユーザー情報や進捗データを格納する変数
  String userName = ""; // ユーザー名、初期値は空文字
  int loginStreak = 3; // 連続ログイン日数
  int longestStreak = 5; // 最長連続ログイン日数
  int tierProgress = 34; // 今日の達成度
  int tierProgress_all = 62; // 目標全体に対する達成度

  late AnimationController _controller; // アニメーションコントローラ
  late Animation<double> _progressAnimation; // 今日の達成度のアニメーション
  late Animation<double> _progressAllAnimation; // 目標達成度のアニメーション

  @override
  void initState() {
    super.initState();

    // アニメーションコントローラの初期化
    _controller = AnimationController(
      duration: Duration(seconds: 1), // 1秒間のアニメーション
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

  // Firestoreからユーザーデータを取得する非同期関数
  Future<void> _fetchUserData() async {
    try {
      // Firestoreから特定のユーザーのデータを取得
      final userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('user_id', isEqualTo: 'ASAHIdayo')
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final userData = userSnapshot.docs.first.data();
        userName = userData['user_name'] ?? 'Unknown'; // ユーザー名がない場合、"Unknown"を代入
      }
    } catch (e) {
      print('データ取得エラー: $e'); // データ取得エラーの際にコンソールに表示
      userName = 'Unknown'; // エラー発生時は"Unknown"をセット
    }
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
      future: _fetchUserData(), // _fetchUserDataの完了を待つ
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // データ取得中のインジケーター
        } else {
          // データ取得後のUI表示
          return Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    // ユーザーの名前を表示
                    Text(
                      "$userNameさん、ナイスログイン！",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    // メッセージ
                    Text(
                      "今日も学習を重ねていこう",
                      style: TextStyle(
                        fontSize: 15,
                        color: const Color.fromARGB(255, 130, 130, 130),
                      ),
                    ),
                    SizedBox(height: 20),
                    // 統計、進捗、活動セクション
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Align(alignment: Alignment.center, child: _buildStatSection())),
                        Expanded(child: Align(alignment: Alignment.center, child: _buildProgressSection())),
                        Expanded(child: Align(alignment: Alignment.center, child: _buildActivitySection())),
                      ],
                    ),
                    SizedBox(height: 20),
                    Divider(color: const Color.fromARGB(255, 200, 200, 200)),
                    SizedBox(height: 10),
                    // 日付情報の表示
                    Text(
                      _getDisplayDate(),
                      style: TextStyle(fontSize: 16),
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

  // 統計情報のUIセクション
  Widget _buildStatSection() {
    return Column(
      children: [
        SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "連続ログイン日数",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 100, 100, 100),
                  fontSize: 13,
                ),
              ),
              Text(""),
              Text(
                "$loginStreak日",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                "最高連続ログイン日数",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 130, 130, 130),
                ),
              ),
              Text(
                "$longestStreak日",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 130, 130, 130),
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
        SizedBox(height: 50),
        Stack(
          alignment: Alignment.center,
          children: [
            // 目標達成度の円形インジケーター
            AnimatedBuilder(
              animation: _progressAllAnimation,
              builder: (context, child) {
                return Container(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: _progressAllAnimation.value,
                    strokeWidth: 5,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0ABAB5)),
                  ),
                );
              },
            ),
            Positioned(
              top: 9,
              child: Text(
                "目標への達成度",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 9,
                  color: const Color.fromARGB(255, 100, 100, 100),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _progressAllAnimation,
              builder: (context, child) {
                return Positioned(
                  bottom: 0,
                  child: Text(
                    "${(_progressAllAnimation.value * 100).toInt()}%",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                );
              },
            ),
            // 今日の進捗の円形インジケーター
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return Container(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    value: _progressAnimation.value,
                    strokeWidth: 5,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0ABAB5)),
                  ),
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 9,
                    color: const Color.fromARGB(255, 100, 100, 100),
                  ),
                ),
                SizedBox(height: 5),
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Text(
                      "${(_progressAnimation.value * 100).toInt()}%",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
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
        SizedBox(height: 8),
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
              titleTextStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              decoration: BoxDecoration(color: Colors.transparent),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              dowTextFormatter: (date, locale) => DateFormat.E(locale).format(date)[0],
              weekdayStyle: TextStyle(fontSize: 12),
              weekendStyle: TextStyle(fontSize: 12, color: Colors.red),
            ),
            calendarStyle: CalendarStyle(
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
              });
            },
            calendarBuilders: CalendarBuilders(
              headerTitleBuilder: (context, date) {
                return Column(
                  children: [
                    Text(
                      DateFormat('yyyy年').format(date),
                      style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    Text(
                      DateFormat('M月').format(date),
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ],
                );
              },
              defaultBuilder: (context, day, focusedDay) {
                return Center(
                  child: Text(
                    '•',
                    style: TextStyle(fontSize: 12),
                  ),
                );
              },
              todayBuilder: (context, day, focusedDay) {
                return Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF0ABAB5),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    DateFormat.d().format(day),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                );
              },
              selectedBuilder: (context, day, focusedDay) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    DateFormat.d().format(day),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                );
              },
              outsideBuilder: (context, day, focusedDay) {
                return Center(
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
}