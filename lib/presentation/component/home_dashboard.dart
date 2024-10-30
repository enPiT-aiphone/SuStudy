import '/import.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  final String selectedTab;
  final String selectedCategory;

  DashboardScreen({required this.selectedTab, required this.selectedCategory});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();

  String userName = ""; // 初期は空の文字列
  int loginStreak = 3;
  int longestStreak = 5;
  int tierProgress = 34;
  int tierProgress_all = 62;

  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _progressAllAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0, end: tierProgress / 100)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic));
    _progressAllAnimation = Tween<double>(begin: 0, end: tierProgress_all / 100)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic));

    _controller.forward();
  }

  Future<void> _fetchUserData() async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('user_id', isEqualTo: 'ASAHIdayo')
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final userData = userSnapshot.docs.first.data();
        userName = userData['user_name'] ?? 'Unknown';
      }
    } catch (e) {
      print('データ取得エラー: $e');
      userName = 'Unknown';
    }
  }

  String _getDisplayDate() {
    final displayDate = _selectedDay ?? DateTime.now();
    return "${DateFormat('yyyy年M月d日').format(displayDate)}の${widget.selectedCategory}の記録データ閲覧画面";
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      "$userNameさん、ナイスログイン！",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "今日も学習を重ねていこう",
                      style: TextStyle(
                        fontSize: 15,
                        color: const Color.fromARGB(255, 130, 130, 130),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: _buildStatSection(),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: _buildProgressSection(),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: _buildActivitySection(),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Divider(color: const Color.fromARGB(255, 200, 200, 200)),
                    SizedBox(height: 10),
                    Text(
                      _getDisplayDate(),
                      style: TextStyle(
                        fontSize: 16,
                      ),
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

  Widget _buildProgressSection() {
    return Column(
      children: [
        SizedBox(height: 50),
        Stack(
          alignment: Alignment.center,
          children: [
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                );
              },
            ),
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
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
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
