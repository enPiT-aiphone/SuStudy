import '/import.dart'; // プロジェクト固有のimport
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'home_dashboard_graph.dart';

class HomeDashboardScreen extends StatefulWidget {
  final String selectedTab;
  final String selectedCategory;
  final Function(int) onLoginStreakCalculated;
  final VoidCallback onDashCoachMarkFinished;

  const HomeDashboardScreen({
    super.key,
    required this.selectedTab,
    required this.selectedCategory,
    required this.onLoginStreakCalculated,
    required this.onDashCoachMarkFinished,
  });

  @override
  _HomeDashboardScreenState createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen>
    with SingleTickerProviderStateMixin {
  // ---------------------------
  // カレンダー関連
  // ---------------------------
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();
  Set<DateTime> _loggedInDays = {};

  // ---------------------------
  // ユーザー情報・進捗
  // ---------------------------
  String userName = "";
  int loginStreak = 0;
  int longestStreak = 0;
  int totalLogins = 0;

  double tierProgress = 0.0;     // 今日の学習達成度
  double tierProgressAll = 0.0;  // 目標への達成度
  double wordCount = 0;          // 学習量 (教科ごとの想定値)
  List<String> _followingSubjects = [];

  // ---------------------------
  // コーチマーク用キー
  // ---------------------------
  final GlobalKey progressSectionKey = GlobalKey(); // 進捗セクション
  final GlobalKey activitySectionKey = GlobalKey(); // カレンダー

  // チュートリアル表示済みフラグ
  bool hasShownDashProgressCoach = false;
  bool hasShownDashActivityCoach = false;

  // コーチマークインスタンス
  TutorialCoachMark? dashboardCoachMark;

  // アニメーション (円形進捗表示)
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _progressAllAnimation;

  late Future<void> _userDataFuture;

  @override
  void initState() {
    super.initState();

    // 1) Firestoreからユーザーデータ取得
    _userDataFuture = _fetchUserData();
    fetchTierProgress();

    // 2) コーチマーク状態を読み込む
    _fetchCoachMarksState().then((_) {
      // 3) コーチマーク表示
      _showDashboardCoachMarksIfNeeded();
    });

    // 4) アニメーション
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0, end: tierProgress / 100).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    _progressAllAnimation =
        Tween<double>(begin: 0, end: tierProgressAll / 100).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    // チュートリアルが中途半端に残らないように
    dashboardCoachMark?.finish();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant HomeDashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // selectedCategoryが変更された場合にfetchTierProgressを再実行
    if (oldWidget.selectedCategory != widget.selectedCategory) {
      fetchTierProgress();
    }
  }



  // -------------------------------------------------------------------------
  // Firestore で dashProgress, dashActivity を管理
  // -------------------------------------------------------------------------
  Future<void> _fetchCoachMarksState() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final docSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      if (!docSnapshot.exists) return;

      final data = docSnapshot.data() ?? {};
      final coachMarks = data['coachMarks'] as Map<String, dynamic>?;

      if (coachMarks != null) {
        setState(() {
          hasShownDashProgressCoach = coachMarks['dashProgress'] ?? false;
          hasShownDashActivityCoach = coachMarks['dashActivity'] ?? false;
        });
      }
    } catch (e) {
      print('Dashboardコーチマーク状態の取得エラー: $e');
    }
  }

  Future<void> _saveDashboardCoachMarkState({
    bool? dashProgress,
    bool? dashActivity,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final updates = <String, dynamic>{};
      if (dashProgress != null) updates['coachMarks.dashProgress'] = dashProgress;
      if (dashActivity != null) updates['coachMarks.dashActivity'] = dashActivity;

      if (updates.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .update(updates);
      }
    } catch (e) {
      print('Dashboardコーチマーク状態の保存エラー: $e');
    }
  }

  // -------------------------------------------------------------------------
  // ダッシュボードでのコーチマーク
  // -------------------------------------------------------------------------
  void _showDashboardCoachMarksIfNeeded() {
    // 既に両方ともtrueなら何もしない
    if (hasShownDashProgressCoach && hasShownDashActivityCoach) {
      return;
    }

    // 進捗だけ未表示かどうか
    final needProgress = !hasShownDashProgressCoach;
    // カレンダーだけ未表示かどうか
    final needActivity = !hasShownDashActivityCoach;

    // 表示対象のTargetFocusを動的に組み立てる
    final targets = <TargetFocus>[];

    if (needProgress) {
      targets.add(
        TargetFocus(
          identify: "DashProgress",
          keyTarget: progressSectionKey,
          shape: ShapeLightFocus.Circle,
          focusAnimationDuration: Duration.zero,
          unFocusAnimationDuration: Duration.zero,
          //pulseAnimationDuration: Duration.zero,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (ctx, controller) => const Text(
                '「目標への達成度」はあなたがフォローした教科\nをマスターするまでの達成度を表しています。\n'
                '「今日の学習達成度」は、あなたが立てた目標\nへの達成度を表しています。',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (needActivity) {
      targets.add(
        TargetFocus(
          identify: "DashActivity",
          keyTarget: activitySectionKey,
          shape: ShapeLightFocus.RRect,
          radius:10,
          focusAnimationDuration: Duration.zero,
          unFocusAnimationDuration: Duration.zero,
          //pulseAnimationDuration: Duration.zero,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (ctx, controller) => const Text(
                'カレンダーの日付をタップするとその日の記録を閲覧できます',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (targets.isEmpty) {
      return; // 何も表示しない
    }

    // TutorialCoachMarkを生成
    dashboardCoachMark = TutorialCoachMark(
      targets: targets,
      // どこでもタップしたら次へ
      onClickOverlay: (target) {
        dashboardCoachMark?.next();
        return true;
      },
      // skipボタンを表示しない
      //showSkipInFront: false,
      // 全ターゲットを見終わったら
      pulseEnable: false,
      onFinish: () {
        setState(() {
          if (needProgress) {
            hasShownDashProgressCoach = true;
          }
          if (needActivity) {
            hasShownDashActivityCoach = true;
          }
        });
        _saveDashboardCoachMarkState(
          dashProgress: needProgress ? true : null,
          dashActivity: needActivity ? true : null,
        );
        widget.onDashCoachMarkFinished();
      },
      // 途中スキップ
      hideSkip: true,
      onSkip: () {
        setState(() {
          if (needProgress) {
            hasShownDashProgressCoach = true;
          }
          if (needActivity) {
            hasShownDashActivityCoach = true;
          }
        });
        _saveDashboardCoachMarkState(
          dashProgress: needProgress ? true : null,
          dashActivity: needActivity ? true : null,
        );
        widget.onDashCoachMarkFinished();
        return true;
      },
    );

    // 表示
    dashboardCoachMark?.show(context: context);
  }

  // -------------------------------------------------------------------------
  // Firestoreからユーザーデータを取得
  // -------------------------------------------------------------------------
  Future<void> _fetchUserData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('ユーザーがログインしていません');
        userName = 'Unknown';
        return;
      }
      final userId = currentUser.uid;

      final userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('auth_uid', isEqualTo: userId)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final userData = userSnapshot.docs.first.data();
        setState(() {
          _followingSubjects =
              List<String>.from(userData['following_subjects'] ?? []);
        });

        userName = userData['user_name'] ?? 'Unknown';
        final loginHistory = userData['login_history'] ?? [];

        // ログイン履歴から連続ログインなど計算
        _calculateLoginStats(loginHistory);

        // ログイン済み日リスト
        _loggedInDays = loginHistory
            .map((timestamp) => (timestamp as Timestamp).toDate())
            .map((date) => DateTime(date.year, date.month, date.day))
            .toSet()
            .cast<DateTime>();
      } else {
        print('ユーザーが見つかりません');
        userName = 'Unknown';
      }
    } catch (e) {
      print('データ取得エラー: $e');
      userName = 'Unknown';
    }
  }

  // -------------------------------------------------------------------------
  // 「今日の達成度」「目標への達成度」を計算
  // -------------------------------------------------------------------------
  Future<void> fetchTierProgress() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('ユーザーがログインしていません');
        return;
      }
      final userId = currentUser.uid;
      final category = widget.selectedCategory;

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

      if (category == '全体') {
        wordCount = 0;
        for (final subject in followingSubjects) {
          wordCount += getTotalMinutes(subject);
        }
      } else {
        wordCount = getTotalMinutes(category);
      }

      final today = DateTime.now();
      final todayDate = DateFormat('yyyy-MM-dd').format(today);

      // リセット
      tierProgress = 0;
      tierProgressAll = 0;

      if (category == '全体') {
        for (final subject in followingSubjects) {
          final colSnap = await FirebaseFirestore.instance
              .collection('Users')
              .doc(userId)
              .collection('record')
              .doc(todayDate)
              .collection(subject)
              .get();

          for (final doc in colSnap.docs) {
            final data = doc.data();
            tierProgress += data['tierProgress_today'] ?? 0;
            tierProgressAll += data['tierProgress_all'] ?? 0;
          }
        }
      } else {
        final colSnap = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection('record')
            .doc(todayDate)
            .collection(category)
            .get();

        for (final doc in colSnap.docs) {
          final data = doc.data();
          tierProgress += data['tierProgress_today'] ?? 0;
          tierProgressAll += data['tierProgress_all'] ?? 0;
        }
      }

      final todayDocSnap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('record')
          .doc(todayDate)
          .get();

      final tierProgressTodayGoal =
          todayDocSnap.data()?['${category}_goal'] ?? 0;

      double tierProgressGoal = 0;
      for (final c in followingSubjects) {
        tierProgressGoal += todayDocSnap.data()?['${c}_goal'] ?? 0;
      }

      double normalizedTierProgressAll = 0;
      double normalizedTierProgress = 0;

      if (category == '全体') {
        normalizedTierProgressAll =
            (wordCount == 0) ? 0 : (tierProgressAll / wordCount);
        normalizedTierProgress =
            (tierProgressGoal == 0) ? 0 : (tierProgress / tierProgressGoal);
      } else {
        normalizedTierProgressAll =
            (wordCount == 0) ? 0 : (tierProgressAll / wordCount);
        normalizedTierProgress = (tierProgressTodayGoal == 0)
            ? 0
            : (tierProgress / tierProgressTodayGoal);
      }

      // アニメーション更新
      setState(() {
        _progressAllAnimation = Tween<double>(
          begin: 0,
          end: normalizedTierProgressAll.toDouble(),
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
        );

        _progressAnimation = Tween<double>(
          begin: 0,
          end: normalizedTierProgress.toDouble(),
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
        );
      });
      _controller.forward(from: 0);
    } catch (e) {
      print('fetchTierProgressエラー: $e');
    }
  }

  // -------------------------------------------------------------------------
  // ログイン記録を解析
  // -------------------------------------------------------------------------
  void _calculateLoginStats(List<dynamic> loginHistory) {
    if (loginHistory.isEmpty) {
      setState(() {
        loginStreak = 0;
        longestStreak = 0;
        totalLogins = 0;
      });
      return;
    }

    final loginDates = loginHistory
        .map((timestamp) => (timestamp as Timestamp).toDate())
        .map((date) => DateTime(date.year, date.month, date.day))
        .toSet()
        .toList()
      ..sort();

    int currentStreak = 1;
    int maxStreak = 1;
    final total = loginDates.length;
    int todayStreak = 0;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    if (loginDates.isNotEmpty && loginDates.first == todayDate) {
      todayStreak = 1;
    }

    for (int i = 1; i < loginDates.length; i++) {
      final diff = loginDates[i].difference(loginDates[i - 1]).inDays;
      if (diff == 1) {
        currentStreak++;
      } else {
        if (currentStreak > maxStreak) {
          maxStreak = currentStreak;
        }
        currentStreak = 1;
      }
    }
    if (currentStreak > maxStreak) {
      maxStreak = currentStreak;
    }
    todayStreak = currentStreak;

    setState(() {
      loginStreak = todayStreak;
      longestStreak = maxStreak;
      totalLogins = total;
    });
    widget.onLoginStreakCalculated(loginStreak);
  }

  // -------------------------------------------------------------------------
  // UI生成
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _userDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0ABAB5)),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('データ取得エラー: ${snapshot.error}'));
        } else {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$userNameさん、ナイスログイン！",
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "今日も学習を重ねていこう",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 130, 130, 130),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildStatSection()),
                        Expanded(
                          child: Container(
                            key: progressSectionKey,
                            child: _buildProgressSection(),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            key: activitySectionKey,
                            child: _buildActivitySection(),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Color.fromARGB(255, 200, 200, 200)),
                    const SizedBox(height: 10),
                    Text(
                      _getDisplayDate(),
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    HomeDashboardGraph(
                    selectedCategory: widget.selectedCategory,
                    selectedDay: _selectedDay, 
                    ),
                    const SizedBox(height: 200),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  // -------------------------------------------------------------------------
  // 統計
  // -------------------------------------------------------------------------
  Widget _buildStatSection() {
    return Column(
      children: [
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "連続ログイン日数",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 100, 100, 100),
                  fontSize: 12,
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

  // -------------------------------------------------------------------------
  // 進捗 (今日の学習達成度・目標への達成度)
  // -------------------------------------------------------------------------
Widget _buildProgressSection() {
  // 1) 画面幅を取得
  final screenWidth = MediaQuery.of(context).size.width;

  // 2) それぞれの円の直径を計算し、最大値でクランプ
  final diameterAll = (screenWidth * 0.3).clamp(0, 140);  // 外側(目標への達成度)
  final diameterProgress = (screenWidth * 0.2).clamp(0, 90); // 内側(今日の学習達成度)

  return Column(
    children: [
      const SizedBox(height: 50),
      Stack(
        alignment: Alignment.center,
        children: [
          // --- 外側の円 (目標への達成度) ---
          AnimatedBuilder(
            animation: _progressAllAnimation,
            builder: (context, child) {
              return SizedBox(
                width: diameterAll.toDouble(),
                height: diameterAll.toDouble(),
                child: CircularProgressIndicator(
                  value: _progressAllAnimation.value,
                  strokeWidth: 5,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0ABAB5)),
                ),
              );
            },
          ),
          // 目標への達成度のラベル (例: "目標への達成度")
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

          // --- 外側の円の数値表示 ---
          AnimatedBuilder(
            animation: _progressAllAnimation,
            builder: (context, child) {
              final val = _progressAllAnimation.value;
              final displayValue = (val * 100).toInt() % 100;
              final cycles = (val * 100).toInt() ~/ 100;
              final colors = [
                const Color(0xFF0ABAB5),
                const Color(0xFFFF8C00),
                const Color(0xFFFF0000),
                const Color(0xFFFF69B4),
                const Color(0xFFFFD700),
              ];
              final color = (cycles < 5) ? colors[cycles] : colors.last;
              return Positioned(
                bottom: 0,
                child: Text(
                  "$displayValue%",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: color,
                  ),
                ),
              );
            },
          ),

          // --- 内側の円 (今日の学習達成度) ---
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              final val = _progressAnimation.value;
              final cycles = (val * 100).toInt() ~/ 100;
              final colors = [
                const Color(0xFF0ABAB5),
                const Color(0xFFFF8C00),
                const Color(0xFFFF0000),
                const Color(0xFFFF69B4),
                const Color(0xFFFFD700),
              ];
              return Stack(
                alignment: Alignment.center,
                children: [
                  for (int i = 0; i <= cycles; i++)
                    if (i < 5)
                      SizedBox(
                        width: diameterProgress.toDouble(),  // 内側の円サイズ
                        height: diameterProgress.toDouble(),
                        child: CircularProgressIndicator(
                          value: (i < cycles) ? 1.0 : (val % 1.0),
                          strokeWidth: 5,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(colors[i]),
                        ),
                      ),
                ],
              );
            },
          ),

          // --- 内側の円のテキスト (例: "今日の学習達成度") ---
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                (_selectedDay == null || isSameDay(_selectedDay, DateTime.now()))
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
                  final v = (_progressAnimation.value * 100).toInt();
                  return Text(
                    "$v%",
                    style: const TextStyle(
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


  // -------------------------------------------------------------------------
  // カレンダー (Activity セクション)
  // -------------------------------------------------------------------------
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
              // （デフォルトのtitleTextFormatterまたはheaderTitleBuilderを使わない場合は削除）
              
              // ▼ 前月アイコンと次月アイコンにマージンを入れる
              leftChevronMargin: const EdgeInsets.only(left: 0.0),
              rightChevronMargin: const EdgeInsets.only(right: 0.0),
              // ▼ アイコン自体のサイズを変更
              leftChevronIcon: const Icon(
                Icons.chevron_left,
                size: 18,  // 矢印を大きめに
                color: Colors.black,
              ),
              rightChevronIcon: const Icon(
                Icons.chevron_right,
                size: 18,  // 矢印を大きめに
                color: Colors.black,
              ),

              titleTextStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              decoration: const BoxDecoration(color: Colors.transparent),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              dowTextFormatter: (date, locale) =>
                  DateFormat.E(locale).format(date)[0],
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
                // 選択された日付の進捗を再計算
                _calculateProgressForSelectedDay();
              });
            },
            calendarBuilders: CalendarBuilders(
              headerTitleBuilder: (context, date) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('yyyy年').format(date),
                      style: const TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      DateFormat('M月').format(date),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                );
              },
              defaultBuilder: (context, day, focusedDay) {
                // ログイン記録がある日を `images/redfire.png` で表示
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
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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

  // -------------------------------------------------------------------------
  // 選択された日付の表示
  // -------------------------------------------------------------------------
  String _getDisplayDate() {
    final displayDate = _selectedDay ?? DateTime.now();
    return "${DateFormat('yyyy年M月d日').format(displayDate)}の${widget.selectedCategory}の記録データ";
  }

  // -------------------------------------------------------------------------
  // 選択された日付の進捗計算
  // -------------------------------------------------------------------------
  void _calculateProgressForSelectedDay() async {
    if (_selectedDay == null) return;

    final selectedDate = DateFormat('yyyy-MM-dd').format(_selectedDay!);
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print('ユーザーがログインしていません');
      return;
    }

    final userId = currentUser.uid;
    final category = widget.selectedCategory;

    try {
      final selectedDaySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('record')
          .doc(selectedDate)
          .collection(category)
          .get();

      if (selectedDaySnapshot.docs.isNotEmpty) {
        double sumToday = 0.0;
        double sumAll = 0.0;

        for (final doc in selectedDaySnapshot.docs) {
          final data = doc.data();
          sumToday += data['tierProgress_today'] ?? 0;
          sumAll += data['tierProgress_all'] ?? 0;
        }

        final selectedDayGoalDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection('record')
            .doc(selectedDate)
            .get();

        final tierProgressTodayGoal =
            selectedDayGoalDoc.data()?['${category}_goal'] ?? 0;

        final normalizedTierProgressAll = (wordCount == 0)
            ? 0
            : (sumAll / wordCount);
        final normalizedTierProgress = (tierProgressTodayGoal == 0)
            ? 0
            : (sumToday / (tierProgressTodayGoal));

        setState(() {
          _progressAllAnimation = Tween<double>(
            begin: 0,
            end: normalizedTierProgressAll.toDouble(),
          ).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
          );

          _progressAnimation = Tween<double>(
            begin: 0,
            end: normalizedTierProgress.toDouble(),
          ).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
          );
        });
        _controller.forward(from: 0);
      } else {
        // 過去日の参照
        final previousDocSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection('record')
            .where(FieldPath.documentId, isLessThan: selectedDate)
            .orderBy(FieldPath.documentId, descending: true)
            .limit(1)
            .get();

        double normalizedAll = 0;
        if (previousDocSnapshot.docs.isNotEmpty) {
          final prevId = previousDocSnapshot.docs.first.id;
          final prevSnap = await FirebaseFirestore.instance
              .collection('Users')
              .doc(userId)
              .collection('record')
              .doc(prevId)
              .collection(category)
              .get();

          double sumAll = 0;
          for (final doc in prevSnap.docs) {
            sumAll += doc.data()['tierProgress_all'] ?? 0;
          }
          normalizedAll = (wordCount == 0) ? 0 : (sumAll / wordCount);
        }
        setState(() {
          _progressAllAnimation = Tween<double>(
            begin: 0,
            end: normalizedAll.toDouble(),
          ).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
          );
          _progressAnimation = Tween<double>(
            begin: 0,
            end: 0,
          ).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
          );
        });
        _controller.forward(from: 0);
      }
    } catch (e) {
      print('選択された日のデータ取得エラー: $e');
    }
  }

  // -------------------------------------------------------------------------
  // カテゴリに応じた学習量
  // -------------------------------------------------------------------------
  double getTotalMinutes(String category) {
    if (category == 'TOEIC300点') {
      return 15; 
    } else if (category == 'TOEIC500点') {
      return 27 + 33 + 28;
    } else if (category == 'TOEIC700点') {
      return 39.5 + 8;
    } else if (category == 'TOEIC900点') {
      return 48 + 15 + 45;
    } else if (category == 'TOEIC990点') {
      return 58;
    } else {
      return 1;
    }
  }
}
