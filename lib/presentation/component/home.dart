import 'dart:ui'; // for ImageFilter
import 'dart:html' as html; // Safari動的高さ用
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

// ---- あなたのプロジェクト固有の import 群 ----
import '../add_word.dart';
import '../add_grammar.dart';
import '/import.dart';
import 'notification/notification.dart';
import 'record/record_TOEIC.dart';
import 'record/add_daily.dart';
import 'record/problem_toeic_word.dart';
import 'search/user_profile_screen.dart';
import 'post/post.dart';
import 'search/search.dart';
import 'ranking_dashboard.dart';
import 'group/group_navigation.dart';
import 'group/group_control.dart';
import 'timeline.dart';
import 'group/group_list.dart';
import '../add_idiom.dart';
import 'package:sustudy_add/main.dart' show saveTokenToSubcollection;

import 'home_dashboard.dart'; // 「ダッシュボード」画面
import 'user_view_model.dart';
import 'reply_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserViewModel(),
      child: MaterialApp(
        home: const HomeScreen(),
        theme: ThemeData(
          primaryColor: const Color(0xFF0ABAB5),
        ),
      ),
    );
  }
}
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0; // 初期値が 0: タイムライン
  bool _isRecordPageVisible = false;
  bool _isPostCreateVisible = false;
  bool _showExtraButtons = false;
  bool _isProfileVisible = false;
  bool _isGroupCreateVisible = false;
  bool _isGroupShowVisible = false;

  String _profileUserId = '';
  String _currentUserId = '';
  int _loginStreak = 0; // ログイン連続日数

  OverlayEntry? _overlayEntry;
  bool _isNotificationVisible = false;
  String _selectedCategory = '';
  String _selectedTab = '最新';

  bool _isUserProfileVisible = false; 
  String? _userprofileUserId;

  // Firebase user info
  String _accountName = '';
  String _accountId = '';
  int _userNumber = 0;
  int _followers = 0;
  int _follows = 0;
  List<String> _followingSubjects = [];
  List<dynamic> _loginHistory = [];

  bool _isReplyScreenVisible = false;          // ReplyScreen を表示中かどうか
  Map<String, dynamic>? _replyPost;           // 返信先の投稿データ

  // Safariの動的高さ対応
  double _browserHeight = (html.window.innerHeight ?? 0).toDouble();

  // 下スクロール時に BottomNavigationBar を半透明に
  double _bottomNavOpacity = 1.0;

  // コーチマーク管理
  TutorialCoachMark? tutorialCoachMark;
  final GlobalKey dataTabKey = GlobalKey(); // データタブ
  final GlobalKey fabKey = GlobalKey();     // FAB

  // コーチマーク表示済み
  bool hasShownDataTabCoach = false;
  bool hasShownFabSolveCoach = false;
  bool hasShownFabLongPressCoach = false;

  // ダッシュボード終了フラグ (dashProgress, dashActivity)
  bool hasShownDashProgress = false;
  bool hasShownDashActivity = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  // 初回ビルド後に一度だけ呼び出したいフラグ
  bool _initialCoachMarkCheckDone = false;

  @override
  void initState() {
    super.initState();

    // Safariのアドレスバー
    if (!kIsWeb) {
      html.window.addEventListener('resize', (event) {
        setState(() {
          _browserHeight = (html.window.innerHeight ?? 0).toDouble();
        });
      });
    }

    // Firebaseユーザー情報 + コーチマーク状態取得
    _fetchUserData();
    _fetchCoachMarksState();

    // 通知Overlayアニメ
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 220),
      vsync: this,
    );
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1.05).chain(CurveTween(curve: Curves.easeOut)),
        weight: 170,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_animationController);

    _opacityAnimation = Tween<double>(begin: 0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // 画面描画後に一度だけコーチマークをチェック
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runInitialCoachMarkCheck();
      _showFabSolveCoachMarkIfNeeded();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 画面が初回にビルドされたあとに一度だけ呼び出す
  void _runInitialCoachMarkCheck() async {
    if (_initialCoachMarkCheckDone) return;
    _initialCoachMarkCheckDone = true;

    // もし現在のタブが 0 (タイムライン) なら、データタブコーチマークやFABコーチマークをチェック
    if (_currentIndex == 0) {
      // 1) データタブコーチマーク
      await _showDataTabCoachMarkIfNeeded();

      // 2) FAB「問題を解く」コーチマーク
      _showFabSolveCoachMarkIfNeeded();

      // 3) t_solved_* >= 6 => FAB長押しコーチマーク
      final solvedCount = await _checkSolvedCount();
      _showFabLongPressCoachMarkIfNeeded(solvedCount);
    }
  }

  // ---------------------------
  // Firestore コーチマークの状態
  // ---------------------------
  Future<void> _fetchCoachMarksState() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      if (!snap.exists) return;

      final data = snap.data() ?? {};
      final coachMarks = data['coachMarks'] as Map<String, dynamic>?;

      if (coachMarks != null) {
        setState(() {
          hasShownDataTabCoach   = coachMarks['dataTab']     ?? false;
          hasShownFabSolveCoach  = coachMarks['fabSolve']    ?? false;
          hasShownFabLongPressCoach = coachMarks['fabLongPress'] ?? false;

          hasShownDashProgress   = coachMarks['dashProgress'] ?? false;
          hasShownDashActivity   = coachMarks['dashActivity'] ?? false;
        });
      }
    } catch (e) {
      print('コーチマーク状態の取得エラー: $e');
    }
  }

  Future<void> _saveCoachMarkState({
    bool? dataTab,
    bool? fabSolve,
    bool? fabLongPress,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final updates = <String, dynamic>{};
      if (dataTab != null)       updates['coachMarks.dataTab']       = dataTab;
      if (fabSolve != null)      updates['coachMarks.fabSolve']      = fabSolve;
      if (fabLongPress != null)  updates['coachMarks.fabLongPress']  = fabLongPress;

      if (updates.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .update(updates);
      }
    } catch (e) {
      print('コーチマーク状態の保存エラー: $e');
    }
  }

  // ---------------------------
  // データタブコーチマーク
  // ---------------------------
  Future<void> _showDataTabCoachMarkIfNeeded() async {
    if (hasShownDataTabCoach) {
      print('[DataTabCoach] already shown => skip');
      return;
    }

    final hasTodayRecord = await _checkHasTodayRecord();
    if (!hasTodayRecord) {
      print('[DataTabCoach] No record doc found for today. skip');
      return;
    }

    if (!hasShownDataTabCoach && hasTodayRecord) {
    print('[DataTabCoach] showing...');
    tutorialCoachMark = TutorialCoachMark(
      targets: [
        TargetFocus(
          identify: "DataTab",
          keyTarget: dataTabKey,
          shape: ShapeLightFocus.Circle,
          focusAnimationDuration: Duration.zero,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) {
                return const Text(
                  '「データ」から今日の達成度を確認しよう！',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ],
        ),
      ],
      onClickOverlay: (_) {
        tutorialCoachMark?.finish();
        return true;
      },
      onFinish: () {
        print('[DataTabCoach] finished');
        setState(() => hasShownDataTabCoach = true);
        _saveCoachMarkState(dataTab: true);
        return true;
      },
      hideSkip: true,
      onSkip: () {
        print('[DataTabCoach] skipped');
        setState(() => hasShownDataTabCoach = true);
        _saveCoachMarkState(dataTab: true);
        return true;
      },
    );

    tutorialCoachMark?.show(context: context);
    }
  }

  Future<bool> _checkHasTodayRecord() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        print("ユーザードキュメントが存在しません");
        return false;
      }

      final data = userDoc.data();
      if (data == null || !data.containsKey('login_history')) {
        print("login_historyフィールドが存在しません");
        return false;
      }

      final List<dynamic> loginHistory = data['login_history'] ?? [];

      // 今日の日付
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // login_historyに今日の日付が含まれるかチェック
      for (var timestamp in loginHistory) {
        if (timestamp is Timestamp) {
          final loginDate = timestamp.toDate();
          final normalizedDate = DateTime(loginDate.year, loginDate.month, loginDate.day);
          if (normalizedDate == today) {
            return true; // 今日の日付が存在する場合
          }
        }
      }

      return false; // 今日の日付が存在しない場合
    } catch (e) {
      print("エラー: $e");
      return false;
    }
  }

  // ---------------------------
  // FAB「問題を解く」コーチマーク
  // ---------------------------
  void _showFabSolveCoachMarkIfNeeded() {
    if (!hasShownDashProgress || !hasShownDashActivity) {
      print('[FabSolveCoach] dashProgress or dashActivity = false => skip');
      return;
    }
    if (hasShownFabSolveCoach) {
      print('[FabSolveCoach] already shown => skip');
      return;
    }
    // タイムライン以外ならスキップ
    if (_currentIndex != 0) {
      print('[FabSolveCoach] currentIndex != 0 => skip');
      return;
    }

    print('[FabSolveCoach] showing...');
    tutorialCoachMark = TutorialCoachMark(
      targets: [
        TargetFocus(
          identify: "FabSolve",
          keyTarget: fabKey,
          shape: ShapeLightFocus.Circle,
          focusAnimationDuration: Duration.zero,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) {
                return const Text(
                  'このボタンから新たに問題を解くことができます',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ],
        ),
      ],
      onClickOverlay: (_) {
        tutorialCoachMark?.finish();
        return true;
      },
      onFinish: () {
        print('[FabSolveCoach] finished');
        setState(() => hasShownFabSolveCoach = true);
        _saveCoachMarkState(fabSolve: true);
        return true;
      },
      hideSkip: true,
      onSkip: () {
        print('[FabSolveCoach] skipped');
        setState(() => hasShownFabSolveCoach = true);
        _saveCoachMarkState(fabSolve: true);
        return true;
      },
    );

    tutorialCoachMark?.show(context: context);
  }

  // ---------------------------
  // FAB長押し(投稿)コーチマーク
  // ---------------------------
  void _showFabLongPressCoachMarkIfNeeded(int solvedCount) {
    if (hasShownFabLongPressCoach) {
      print('[FabLongPressCoach] already shown => skip');
      return;
    }
    if (solvedCount < 6) {
      print('[FabLongPressCoach] solvedCount < 6 => skip');
      return;
    }
    // ※ fabSolveCoach が必ずしも true とは限らないが、仕様に合わせて条件追加
    if (!hasShownFabSolveCoach) {
      print('[FabLongPressCoach] fabSolve not shown => skip');
      return;
    }

    print('[FabLongPressCoach] showing...');
    tutorialCoachMark = TutorialCoachMark(
      targets: [
        TargetFocus(
          identify: "FabLongPress",
          keyTarget: fabKey,
          shape: ShapeLightFocus.Circle,
          focusAnimationDuration: Duration.zero,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) {
                return const Text(
                  '長押しすると、タイムラインにあなたの気づきを投稿することもできます',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ],
        ),
      ],
      onClickOverlay: (_) {
        tutorialCoachMark?.finish();
        return true;
      },
      onFinish: () {
        print('[FabLongPressCoach] finished');
        setState(() => hasShownFabLongPressCoach = true);
        _saveCoachMarkState(fabLongPress: true);
        return true;
      },
      hideSkip: true,
      onSkip: () {
        print('[FabLongPressCoach] skipped');
        setState(() => hasShownFabLongPressCoach = true);
        _saveCoachMarkState(fabLongPress: true);
        return true;
      },
    );

    tutorialCoachMark?.show(context: context);
  }

  // ログイン日数コールバック
  void _onLoginStreakCalculated(int loginStreak) {
    setState(() {
      _loginStreak = loginStreak;
    });
  }

  // ユーザーデータ取得
  Future<void> _fetchUserData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        print('ログインしているユーザーがいません');
        return;
      }

      final userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('auth_uid', isEqualTo: userId)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final userData = userSnapshot.docs.first.data();
        setState(() {
          _accountName = userData['user_name'] ?? 'Unknown';
          _accountId   = userData['user_id']   ?? 'ID Unknown';
          _currentUserId = userData['auth_uid'] ?? 'uid Unknown';
          _userNumber = userData['user_number'] ?? 0;
          _followers  = userData['follower_count'];
          _follows    = userData['follow_count'];
          _followingSubjects = List<String>.from(userData['following_subjects'] ?? []);
          _loginHistory = userData['login_history'] ?? [];
          if (_followingSubjects.isNotEmpty) {
            _selectedCategory = '全体';
          }
        });

        // 初回ログイン処理
        if (_loginHistory.isEmpty) {
          _showWelcomeDialog(userId, isFirstLogin: true);
          _showNotificationDialog();
        } else if (!_hasLoggedInToday()) {
          _showWelcomeDialog(userId, isFirstLogin: false);
        }
      }
    } catch (e) {
      print('データ取得エラー: $e');
    }
  }

  bool _hasLoggedInToday() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    for (var ts in _loginHistory) {
      final loginDate = (ts as Timestamp).toDate();
      final normalizedDate = DateTime(loginDate.year, loginDate.month, loginDate.day);
      if (normalizedDate == todayDate) return true;
    }
    return false;
  }

  // 通知許可
  Future<void> _requestNotificationPermission() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final fcmToken = await messaging.getToken();
      if (fcmToken != null) {
        await saveTokenToSubcollection(fcmToken);
        messaging.onTokenRefresh.listen(saveTokenToSubcollection);
        print('通知が許可され、トークンを取得: $fcmToken');
      }
    } catch (e) {
      print('通知許可リクエスト中にエラー: $e');
    }
  }

  void _showNotificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('通知を許可して問題の通知やリアクションを受け取る'),
        content: const Text(
          '「次の画面で通知を許可」ボタンを押すと、\nブラウザから通知許可ダイアログが表示されます。'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('あとで'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _requestNotificationPermission();
            },
            child: const Text('次の画面で通知を許可'),
          ),
        ],
      ),
    );
  }

  // ウェルカム
  void _showWelcomeDialog(String userId, {required bool isFirstLogin}) {
    final toeicLevel = _extractToeicLevel(_followingSubjects);
    final titleMessage = isFirstLogin
        ? '$_accountNameさん、初めまして！'
        : '$_accountNameさん、おかえりなさい！';
    final contentMessage = isFirstLogin
        ? 'まず今日のログイン問題に取り組んで\nログインカウントを貯めていこう！🔥'
        : '今日もログイン問題に取り組んで\nログインカウントを貯めていこう！🔥';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(),
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleMessage,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      contentMessage,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () async {
                            await addDailyRecord(_selectedCategory, context);
                            Navigator.of(context).pop();
                            _navigateToQuiz(toeicLevel);
                          },
                          child: const Text('挑戦する'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _extractToeicLevel(List<String> subjects) {
    final toeicSubject = subjects.firstWhere(
      (subj) => subj.startsWith('TOEIC'),
      orElse: () => '',
    );
    final scoreMatch = RegExp(r'\d+').firstMatch(toeicSubject);
    return scoreMatch != null ? 'up_to_${scoreMatch.group(0)}' : 'up_to_500';
  }

  void _navigateToQuiz(String level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TOEICWordQuiz(level: level, questionType: 'random'),
      ),
    );
  }

  // FAB & サブボタン
  void _onLongPress() {
    setState(() => _showExtraButtons = !_showExtraButtons);
  }

  void _onMenuItemTap(String menu) {
    setState(() => _showExtraButtons = false);
    if (menu == "btn1") {
      setState(() {
        _isRecordPageVisible = true;
        _isPostCreateVisible = false;
      });
    } else if (menu == "btn2") {
      setState(() {
        _isPostCreateVisible = true;
        _isRecordPageVisible = false;
      });
    }
  }

  // カテゴリ
  void _selectCategory(String category) {
    setState(() => _selectedCategory = category);
  }

  void _selectTab(String tab) {
    setState(() => _selectedTab = tab);
  }

  // 通知Overlay
  void _toggleNotificationOverlay(BuildContext ctx) {
    if (_isNotificationVisible) {
      _animationController.reverse().then((_) => _removeOverlay());
    } else {
      _showOverlay(ctx);
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _showOverlay(BuildContext ctx) {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(ctx).insert(_overlayEntry!);
    _isNotificationVisible = true;
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isNotificationVisible = false;
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (ctx) => Stack(
        children: [
          GestureDetector(
            onTap: () => _toggleNotificationOverlay(ctx),
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            top: kToolbarHeight + 10,
            right: 50,
            child: ScaleTransition(
              scale: _scaleAnimation,
              alignment: Alignment.topRight,
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 250,
                    height: 300,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Consumer<BadgeViewModel>(
                        builder: (context, badgeViewModel, _) {
                          return NotificationPage(
                            notifications: badgeViewModel.notifications,
                            onNotificationTap: (docId) async {
                              final selectedNotification = badgeViewModel
                                  .notifications
                                  .firstWhere(
                                (notif) => notif['id'] == docId,
                                orElse: () => {},
                              );
                              if (selectedNotification.isNotEmpty) {
                                final level =
                                    selectedNotification['level'] ?? 'up_to_500';
                                await badgeViewModel.markNotificationAsRead(docId);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TOEICWordQuiz(
                                      level: level,
                                      questionType: 'random',
                                    ),
                                  ),
                                );
                              }
                              _removeOverlay();
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () => _toggleNotificationOverlay(context),
        ),
        Positioned(
          right: 0,
          child: Consumer<BadgeViewModel>(
            builder: (ctx, badgeViewModel, _) {
              if (badgeViewModel.showBadge && badgeViewModel.badgeCount > 0) {
                return CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.red,
                  child: Text(
                    '${badgeViewModel.badgeCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                );
              }
              return Container();
            },
          ),
        ),
      ],
    );
  }

  // グループナビ
  OverlayEntry _createGroupNavigationOverlay() {
    return OverlayEntry(
      builder: (ctx) => Stack(
        children: [
          GestureDetector(
            onTap: () => _removeOverlay(),
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            top: kToolbarHeight + 10,
            right: 50,
            child: ScaleTransition(
              scale: _scaleAnimation,
              alignment: Alignment.topRight,
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 250,
                    height: 300,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GroupNavigationScreen(
                        onGroupMenuTap: () {
                          setState(() {
                            _isGroupShowVisible = true;
                            _removeOverlay();
                          });
                        },
                        onCreateGroupTap: () {
                          setState(() {
                            _isGroupCreateVisible = true;
                            _removeOverlay();
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleGroupNavigationOverlay(BuildContext ctx) {
    if (_isNotificationVisible) {
      _animationController.reverse().then((_) => _removeOverlay());
    } else {
      _overlayEntry = _createGroupNavigationOverlay();
      Overlay.of(ctx).insert(_overlayEntry!);
      _isNotificationVisible = true;
      _animationController.reset();
      _animationController.forward();
    }
  }

  // 表示する中身
  Widget get _currentScreen {
    if (_isGroupShowVisible) {
      return const UserGroupsScreen();
    } else if (_isGroupCreateVisible) {
      return CreateGroupScreen();
    } else if (_isProfileVisible) {
      return UserProfileScreen(
        userId: _profileUserId,
        onBack: () {
          setState(() {
            _isProfileVisible = false;
            _profileUserId = '';
          });
        },
      );
    } else if (_currentIndex == 0) {
      return TimelineScreen(
        selectedTab: _selectedTab,
        selectedCategory: _selectedCategory,
        onUserProfileTap: (userId) {
          setState(() {
            _isProfileVisible = true;
            _profileUserId = userId;
          });
        },
        onReplyRequested: (post) {
          // タイムライン投稿をタップ→返信画面を表示
          setState(() {
            _isReplyScreenVisible = true;
            _replyPost = post;
          });
        },
      );
    } else if (_currentIndex == 1) {
      return RankingScreen(
        selectedTab: _selectedTab,
        selectedCategory: _selectedCategory,
        onUserProfileTap: (userId) {
          setState(() {
            _isProfileVisible = true;
            _profileUserId = userId;
          });
        },
      );
    } else if (_currentIndex == 2) {
      return const SearchScreen();
    } else {
      // データタブ => HomeDashboardScreen
      return HomeDashboardScreen(
        selectedTab: _selectedTab,
        selectedCategory: _selectedCategory,
        onLoginStreakCalculated: _onLoginStreakCalculated,
        onDashCoachMarkFinished: () {
        // DashProgress と DashActivity が完了したことを反映
          setState(() {
            hasShownDashProgress = true;
            hasShownDashActivity = true;
          });
        },
      );
    }
  }

  void _handleScrollNotification(ScrollNotification scrollInfo) {
    if (scrollInfo.metrics.pixels > 100 && _bottomNavOpacity != 0.5) {
      setState(() => _bottomNavOpacity = 0.5);
    } else if (scrollInfo.metrics.pixels <= 100 && _bottomNavOpacity != 1.0) {
      setState(() => _bottomNavOpacity = 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      drawerEnableOpenDragGesture: true,
      drawer: _buildDrawer(),
      body: Container(
        height: _browserHeight,
        color: Colors.white,
        child: NestedScrollView(
          physics: const ClampingScrollPhysics(),
          headerSliverBuilder: (ctx, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                pinned: false,
                floating: true,
                snap: true,
                elevation: 0,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                expandedHeight: (_currentIndex == 2 || _currentIndex == 3) ? 70 : 100,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF0ABAB5).withOpacity(1.0),
                          Colors.white.withOpacity(0.4),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF0ABAB5).withOpacity(1.0),
                              Colors.white.withOpacity(0.4),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () => Scaffold.of(ctx).openDrawer(),
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 18,
                                  child: Text(
                                    _accountName.isNotEmpty ? _accountName[0] : '?',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Color(0xFF0ABAB5),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'SuStudy,',
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.group_add),
                                onPressed: () {
                                  _toggleGroupNavigationOverlay(ctx);
                                },
                              ),
                              _buildNotificationIcon(),
                              IconButton(
                                icon: const Icon(Icons.mail),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                bottom: _shouldShowTabBar
                    ? PreferredSize(
                        preferredSize: const Size.fromHeight(50),
                        child: Container(
                          color: Colors.transparent,
                          alignment: Alignment.center,
                          child: _buildTabBarArea(),
                        ),
                      )
                    : null,
              ),
            ];
          },
          body: NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              _handleScrollNotification(scrollInfo);
              return false;
            },
            child: Stack(
              children: [
                Positioned.fill(child: _buildBodyStack()),
                if (!_isUserProfileVisible &&!_isProfileVisible &&!_isReplyScreenVisible &&_currentIndex != 2)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 80.0),
                      child: _buildCategoryBar(context),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AnimatedOpacity(
        opacity: _bottomNavOpacity,
        duration: const Duration(milliseconds: 200),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF0ABAB5),
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) async {
            setState(() {
              _isRecordPageVisible = false;
              _isPostCreateVisible = false;
              _isProfileVisible = false;
              _isGroupShowVisible = false;
              _isGroupCreateVisible = false;
              _isReplyScreenVisible = false;
              _isUserProfileVisible = false;
              _currentIndex = index;
            });

            // -------------------------------------------
            // タイムラインタブ(index=0) → コーチマークのチェック
            // -------------------------------------------
            if (index == 0) {
              // 1) データタブ
              await _showDataTabCoachMarkIfNeeded();
              // 2) FAB「問題を解く」
              _showFabSolveCoachMarkIfNeeded();
              // 3) t_solved_* >=6 => FAB長押し
              final solvedCount = await _checkSolvedCount();
              _showFabLongPressCoachMarkIfNeeded(solvedCount);
            }
          },
          selectedItemColor: _isRecordPageVisible || _isPostCreateVisible
              ? const Color.fromARGB(255, 68, 68, 68)
              : Colors.white,
          unselectedItemColor: const Color.fromARGB(255, 68, 68, 68),
          selectedLabelStyle: const TextStyle(fontSize: 12.0),
          unselectedLabelStyle: const TextStyle(fontSize: 10.0),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'タイムライン',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard),
              label: 'ランキング',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: '検索',
            ),
            BottomNavigationBarItem(
              icon: Container(
                key: dataTabKey,
                child: const Icon(Icons.timeline),
              ),
              label: 'データ',
            ),
          ],
        ),
      ),
      floatingActionButton: (_isRecordPageVisible || _isPostCreateVisible || _isReplyScreenVisible || _isProfileVisible || _isUserProfileVisible)
          ? null
          : _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  bool get _shouldShowTabBar {
    return !_isProfileVisible &&
        !_isRecordPageVisible &&
        !_isPostCreateVisible &&
        (_currentIndex == 0 || _currentIndex == 1);
  }

  Widget _buildTabBarArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabButton('最新'),
          _buildTabButton('フォロー中'),
          _buildTabButton('グループ'),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tab) {
    final bool selected = (_selectedTab == tab);
    return GestureDetector(
      onTap: () => _selectTab(tab),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0ABAB5) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          tab,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontSize: selected ? 14 : 12,
          ),
        ),
      ),
    );
  }

  Widget _buildBodyStack() {
    return Stack(
      children: [
        Positioned.fill(child: _currentScreen),
        if (_isRecordPageVisible)
          LanguageCategoryScreen(
            selectedCategory: _selectedCategory,
            onClose: () {
              setState(() => _isRecordPageVisible = false);
            },
            categoryBar: _buildCategoryBar(context),
          )
        else if (_isPostCreateVisible)
          NewPostScreen(
            selectedCategory: _selectedCategory,
            onPostSubmitted: () {
              setState(() => _isPostCreateVisible = false);
            },
          )
        else if (_isReplyScreenVisible && _replyPost != null)
          ReplyScreen(
            post: _replyPost!,
            onBack: () {
              // 戻る操作
              setState(() {
                _isReplyScreenVisible = false;
                _replyPost = null; // クリア
              });
            },
            onUserProfileRequested: (userId) {
              setState(() {
                _isReplyScreenVisible = false; // 返信画面は閉じる
                _isUserProfileVisible = true;
                _userprofileUserId = userId; // 対象ユーザーIDをセット
              });
            },
          )
        else if (_isUserProfileVisible && _userprofileUserId != null)
          UserProfileScreen(
            userId: _userprofileUserId!,
            onBack: () {
              setState(() {
                _isUserProfileVisible = false;
                _userprofileUserId = null; // クリア
              });
            },
          ),
      ],
    );
  }

  Widget _buildCategoryBar(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, userViewModel, _) {
        final followingSubjects = userViewModel.followingSubjects;

        return Align(
          alignment: Alignment.bottomCenter,
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              final maxBarWidth = constraints.maxWidth * 0.68;
              double totalWidth = 0.0;
              final categoryButtons = <Widget>[];

              // 「全体」ボタンを追加
              final allButtonWidth = _calculateButtonWidth('全体');
              categoryButtons.add(_buildCategoryButton('全体'));
              totalWidth += allButtonWidth;

              // 各教科ボタンを追加
              for (final subj in followingSubjects) {
                final bw = _calculateButtonWidth(subj);
                categoryButtons.add(_buildCategoryButton(subj));
                totalWidth += bw;
              }

              final barWidth = (totalWidth < maxBarWidth) ? totalWidth : maxBarWidth;

              return Container(
                width: barWidth,
                margin: const EdgeInsets.only(left: 8.0, right: 8.0),
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(50),
                    right: Radius.circular(50),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: categoryButtons),
                ),
              );
            },
          ),
        );
      },
    );
  }

  double _calculateButtonWidth(String text) {
    const textStyle = TextStyle(fontSize: 14.0);
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    const paddingWidth = 36.0;
    return textPainter.width + paddingWidth;
  }

  Widget _buildCategoryButton(String category) {
    final bool isSelected = (_selectedCategory == category);
    return GestureDetector(
      onTap: () => _selectCategory(category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0ABAB5) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

Widget _buildDrawer() {
  return Consumer<UserViewModel>(
    builder: (context, userViewModel, child) {
      return SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Drawer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isProfileVisible = true;
                          _profileUserId = _currentUserId;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF0ABAB5),
                              Color.fromARGB(255, 255, 255, 255),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 30,
                              child: Text(
                                userViewModel.userName.isNotEmpty
                                    ? userViewModel.userName[0]
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 35,
                                  color: Color(0xFF0ABAB5),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                if (_loginStreak < 8)
                                  Container()
                                else if (_loginStreak < 15)
                                  Image.asset('images/smallCrown.png', width: 24, height: 24)
                                else if (_loginStreak < 22)
                                  Image.asset('images/middleCrown.png', width: 24, height: 24)
                                else
                                  Image.asset('images/bigCrown.png', width: 24, height: 24),
                                const SizedBox(width: 5),
                                Text(
                                  userViewModel.userName,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 100, 100, 100),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '@${userViewModel.userId}',
                              style: const TextStyle(
                                color: Color.fromARGB(179, 160, 160, 160),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 9),
                            Row(
                              children: [
                                Text(
                                  'フォロワー: ${userViewModel.followers}',
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 100, 100, 100),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'フォロー中: ${userViewModel.following}',
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 100, 100, 100),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'フォロー中の教科: ${userViewModel.followingSubjects.join(', ')}',
                              style: const TextStyle(
                                color: Color.fromARGB(255, 100, 100, 100),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      constraints: const BoxConstraints(
                        maxHeight: 45, // 最大高さを設定
                      ),
                      child:ListTile(
                        leading: Icon(
                          Icons.person,
                          size: 23, // アイコンサイズを小さく
                        ),
                        title: Text(
                          'プロフィール',
                          style: const TextStyle(
                            fontSize: 15, // 文字サイズを小さく
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _isProfileVisible = true;
                            _profileUserId = userViewModel.userId;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Container(
                      constraints: const BoxConstraints(
                        maxHeight: 45, // 最大高さを設定
                      ),
                      child:ListTile(
                        leading: Icon(
                          Icons.settings,
                          size: 23,
                        ),
                        title: Text(
                          '設定',
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Container(
                      constraints: const BoxConstraints(
                        maxHeight: 45, // 最大高さを設定
                      ),
                      child:ListTile(
                        leading: Icon(
                          Icons.logout,
                          size: 23,
                        ),                      
                        title: Text(
                          'ログアウト',
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),                      
                        onTap: () async {
                          try {
                            await FirebaseAuth.instance.signOut();
                            FirebaseAuth.instance.authStateChanges().listen(
                              (User? user) {
                                if (user == null) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AuthenticationScreen(),
                                    ),
                                  );
                                }
                              },
                            );
                            print('ログアウト成功');
                          } catch (e) {
                            print('ログアウトエラー: $e');
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (_userNumber >= 1 && _userNumber <= 6)
                ListTile(
                  leading: const Icon(Icons.build),
                  title: const Text('データベース管理フォーム'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => const ViewFormSelection(),
                      ),
                    );
                  },
                ),
              if (_userNumber == 1)
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('単語を追加'),
                  onTap: () async {
                    try {
                      await uploadWordsToFirestore();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('単語の追加が完了しました！')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('単語の追加中にエラーが発生しました: $e'),
                        ),
                      );
                    }
                  },
                ),
              if (_userNumber == 4)
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('文法を追加'),
                  onTap: () async {
                    try {
                      await uploadGrammarToFirestore();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('文法の追加が完了しました！')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('文法の追加中にエラーが発生しました: $e'),
                        ),
                      );
                    }
                  },
                ),
            ],
          ),
        ),
      );
    },
  );
}


  Widget _buildFAB() {
    return Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        if (_showExtraButtons)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _showExtraButtons = false),
              child: Container(color: Colors.transparent),
            ),
          ),
        if (_showExtraButtons)
          Stack(
            children: [
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.05 + 100,
                right: 10,
                child: FloatingActionButton(
                  heroTag: null,
                  shape: const CircleBorder(),
                  backgroundColor: const Color(0xFF0ABAB5),
                  child: const Icon(Icons.edit_note),
                  onPressed: () => _onMenuItemTap("btn1"),
                ),
              ),
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.05 + 70,
                right: 70,
                child: FloatingActionButton(
                  heroTag: null,
                  shape: const CircleBorder(),
                  backgroundColor: const Color.fromARGB(255, 23, 214, 208),
                  child: const Icon(Icons.text_snippet),
                  onPressed: () => _onMenuItemTap("btn2"),
                ),
              ),
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.05 + 10,
                right: 100,
                child: FloatingActionButton(
                  heroTag: null,
                  shape: const CircleBorder(),
                  backgroundColor: const Color.fromARGB(255, 64, 239, 234),
                  child: const Icon(Icons.done),
                  onPressed: () {
                    // 何かの処理
                  },
                ),
              ),
            ],
          ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.05,
          right: 0,
          child: SizedBox(
            width: 80,
            height: 80,
            child: GestureDetector(
              key: fabKey,
              onLongPress: _onLongPress,
              child: FloatingActionButton(
                heroTag: null,
                onPressed: () async {
                  setState(() {
                    if (_showExtraButtons) {
                      _showExtraButtons = false;
                    } else {
                      _isRecordPageVisible = true;
                    }
                  });
                  // ※ ここではコーチマークは呼ばない
                  //  コーチマークは bottomNavigationBar の onTap や
                  //  初回表示チェックで呼び出す。
                },
                backgroundColor: const Color(0xFF0ABAB5),
                shape: const CircleBorder(),
                child: Icon(
                  _showExtraButtons ? Icons.close : Icons.post_add,
                  size: 36,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 当日の "t_solved_xxx" フィールド値を合計
  Future<int> _checkSolvedCount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return 0;
      }

      final now = DateTime.now();
      final docId = "${now.year.toString().padLeft(4, '0')}"
          "-${now.month.toString().padLeft(2, '0')}"
          "-${now.day.toString().padLeft(2, '0')}";

      final docRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('record')
          .doc(docId);

      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        return 0;
      }

      final data = docSnapshot.data();
      if (data == null) {
        return 0;
      }


      int solvedCount = 0;

      data.forEach((key, value) {
        if (key.startsWith('t_solved_count_') && value is int) {
          solvedCount += value;
        }
      });

      return solvedCount;
    } catch (e) {
      return 0;
    }
  }
}
