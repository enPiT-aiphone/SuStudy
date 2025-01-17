import 'dart:ui'; // for ImageFilter
import 'dart:html' as html; // Safari動的高さ用
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sustudy_add/presentation/component/group_navigation.dart';
import '../add_word.dart';
import '../add_grammar.dart';
import '/import.dart'; 
import 'notification.dart';
import 'record/record_TOEIC.dart';
import 'record/add_daily.dart';
import 'record/problem_toeic_word.dart';
import 'search/user_profile_screen.dart';
import 'post/post.dart';
import 'search/search.dart';
import 'ranking_dashboard.dart';
import 'group_navigation.dart';
import 'group_control.dart';
import 'timeline.dart';
import 'group_list.dart';
import '../add_idiom.dart';
import 'package:sustudy_add/main.dart' show saveTokenToSubcollection;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
      theme: ThemeData(
        primaryColor: const Color(0xFF0ABAB5),
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
  int _currentIndex = 0;
  bool _isRecordPageVisible = false;
  bool _isPostCreateVisible = false;
  bool _showExtraButtons = false;
  bool _isProfileVisible = false;
  bool _isGroupCreateVisible = false;
  bool _isGroupShowVisible = false;
  String _profileUserId = '';
  String _currentUserId = '';
  int _loginStreak = 0;
  OverlayEntry? _overlayEntry;
  bool _isNotificationVisible = false;
  String _selectedCategory = '';
  String _selectedTab = '最新';

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  // Firebase
  String _accountName = '';
  String _accountId = '';
  int _userNumber = 0;
  int _followers = 0;
  int _follows = 0;
  List<String> _followingSubjects = [];
  List<dynamic> _loginHistory = [];

  // Safariの動的高さ対応
  double _browserHeight = (html.window.innerHeight ?? 0).toDouble();

  // 下スクロール時に BottomNavigationBar を半透明に
  double _bottomNavOpacity = 1.0;

  @override
  void initState() {
    super.initState();

    // Safariのアドレスバー表示/非表示を拾う
    html.window.addEventListener('resize', (event) {
      setState(() {
        _browserHeight = (html.window.innerHeight ?? 0).toDouble();
      });
    });

    _fetchUserData();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 220),
      vsync: this,
    );

    _scaleAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1.05)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 170,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_animationController);

    _opacityAnimation = Tween<double>(begin: 0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  //==================================================
  // ログイン日数
  //==================================================
  void _onLoginStreakCalculated(int loginStreak) {
    setState(() {
      _loginStreak = loginStreak;
    });
  }
  //==================================================
  // Firebase関連
  //==================================================
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
          _accountId = userData['user_id'] ?? 'ID Unknown';
          _currentUserId = userData['auth_uid'] ?? 'uid Unknown';
          _userNumber = userData['user_number'] ?? 0;
          _followers = userData['follower_count'];
          _follows = userData['follow_count'];
          _followingSubjects =
              List<String>.from(userData['following_subjects'] ?? []);
          _loginHistory = userData['login_history'] ?? [];
          if (_followingSubjects.isNotEmpty) {
            _selectedCategory = _followingSubjects[0];
          }
        });
        if (_loginHistory.isEmpty) {
          _showWelcomeDialog(userId, isFirstLogin: true);
          _showNotificationDialog();
        } else if (!_hasLoggedInToday()) {
          _showWelcomeDialog(userId, isFirstLogin: false);
        }
      } else {
        print('ユーザーデータが見つかりません');
      }
    } catch (e) {
      print('データ取得エラー: $e');
    }
  }

  bool _hasLoggedInToday() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    for (var timestamp in _loginHistory) {
      final loginDate = (timestamp as Timestamp).toDate();
      final normalizedDate = DateTime(loginDate.year, loginDate.month, loginDate.day);
      if (normalizedDate == todayDate) {
        return true;
      }
    }
    return false;
  }

  //==================================================
  // 通知許可ダイアログ etc
  //==================================================
  Future<void> _requestNotificationPermission() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final fcmToken = await messaging.getToken();
      if (fcmToken != null) {
        await saveTokenToSubcollection(fcmToken);
        messaging.onTokenRefresh.listen(saveTokenToSubcollection);
        print('通知が許可され、トークンを取得しました: $fcmToken');
      }
    } catch (e) {
      print('通知許可リクエスト中にエラー: $e');
    }
  }

  void _showNotificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('通知を許可して問題の通知やリアクションを受け取る'),
          content:
              const Text('「次の画面で通知を許可」ボタンを押すと、ブラウザから通知許可ダイアログが表示されます。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('あとで'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _requestNotificationPermission();
              },
              child: const Text('次の画面で通知を許可'),
            ),
          ],
        );
      },
    );
  }

  //==================================================
  // ウェルカムダイアログ
  //==================================================
  void _showWelcomeDialog(String userId, {required bool isFirstLogin}) {
    final toeicLevel = _extractToeicLevel(_followingSubjects);
    final titleMessage = isFirstLogin
        ? '$_accountNameさん、初めまして！'
        : '$_accountNameさん、おかえりなさい！';
    final contentMessage = isFirstLogin
        ? 'まず今日のログイン問題に取り組んでログインカウントを貯めていこう！🔥'
        : '今日もログイン問題に取り組んでログインカウントを貯めていこう！🔥';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
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
        );
      },
    );
  }

  String _extractToeicLevel(List<String> subjects) {
    final toeicSubject = subjects.firstWhere(
      (subject) => subject.startsWith('TOEIC'),
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

  //==================================================
  // フローティングボタン & サブボタン
  //==================================================
  void _onLongPress() {
    setState(() {
      _showExtraButtons = !_showExtraButtons;
    });
  }

  void _onMenuItemTap(String menu) {
    setState(() {
      _showExtraButtons = false;
    });
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

  //==================================================
  // カテゴリ関連
  //==================================================
  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _selectTab(String tab) {
    setState(() {
      _selectedTab = tab;
    });
  }

  //==================================================
  // Notification Overlay
  //==================================================
  void _toggleNotificationOverlay(BuildContext context) {
    if (_isNotificationVisible) {
      _animationController.reverse().then((_) {
        _removeOverlay();
      });
    } else {
      _showOverlay(context);
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _showOverlay(BuildContext context) {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _isNotificationVisible = true;
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isNotificationVisible = false;
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: () => _toggleNotificationOverlay(context),
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
                              } else {
                                print('通知が見つかりませんでした');
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
            builder: (context, badgeViewModel, _) {
              return badgeViewModel.showBadge && badgeViewModel.badgeCount > 0
                  ? CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.red,
                      child: Text(
                        '${badgeViewModel.badgeCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    )
                  : Container();
            },
          ),
        ),
      ],
    );
  }

  //==================================================
  // グループナビゲーション
  //==================================================
  OverlayEntry _createGroupNavigationOverlay() {
    return OverlayEntry(
      builder: (context) => Stack(
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

  void _toggleGroupNavigationOverlay(BuildContext context) {
    if (_isNotificationVisible) {
      _animationController.reverse().then((_) {
        _removeOverlay();
      });
    } else {
      _overlayEntry = _createGroupNavigationOverlay();
      Overlay.of(context).insert(_overlayEntry!);
      _isNotificationVisible = true;
      _animationController.reset();
      _animationController.forward();
    }
  }

  //==================================================
  // 表示する中身の切り替え
  //==================================================
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
      // タイムライン
      return TimelineScreen(
        selectedTab: _selectedTab,
        onUserProfileTap: (userId) {
          setState(() {
            _isProfileVisible = true;
            _profileUserId = userId;
          });
        },
      );
    } else if (_currentIndex == 1) {
      return RankingScreen(
        selectedTab: _selectedTab,
        selectedCategory: _selectedCategory,
      );
    } else if (_currentIndex == 2) {
      return const SearchScreen();
    } else {
      return DashboardScreen(
        selectedTab: _selectedTab,
        selectedCategory: _selectedCategory,
        onLoginStreakCalculated: _onLoginStreakCalculated,
      );
    }
  }

  //==================================================
  // スクロール量監視
  //==================================================
  void _handleScrollNotification(ScrollNotification scrollInfo) {
    // 100px以上スクロールするとBottomNavを半透明に
    if (scrollInfo.metrics.pixels > 100 && _bottomNavOpacity != 0.5) {
      setState(() => _bottomNavOpacity = 0.5);
    } else if (scrollInfo.metrics.pixels <= 100 && _bottomNavOpacity != 1.0) {
      setState(() => _bottomNavOpacity = 1.0);
    }
  }

  //==================================================
  // ビルド
  //==================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Bodyをボトムナビの裏まで拡張
      extendBody: true,

      /// ドロワー関連
      drawerEnableOpenDragGesture: true,
      drawer: _buildDrawer(),

      /// メインコンテンツ
      body: Container(
        height: _browserHeight,
        color: Colors.white,
        child: NestedScrollView(
          physics: const ClampingScrollPhysics(),
          // ---- SliverAppBar （+ タブバー） ----
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                // スクロール時に上へ消え、上方向にフリックで戻る
                pinned: false,
                floating: true,
                snap: true,
                elevation: 0,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                // 大きくしたいなら expandedHeightを上げる
                expandedHeight: (_currentIndex == 2 || _currentIndex == 3)? 70 :100, 
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
                          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0), // 上部を調整
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start, // 上揃え
                            children: [
                              // Drawerアイコンの代わりにアバター
                              GestureDetector(
                                onTap: () => Scaffold.of(context).openDrawer(),
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
                                  _toggleGroupNavigationOverlay(context);
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

                // タブバーを表示する画面なら bottom に設定、不要なら null
                bottom: _shouldShowTabBar
                    ? PreferredSize(
                        preferredSize: const Size.fromHeight(50),
                        child: Container(
                          color: Colors.transparent,
                          alignment: Alignment.center,
                          child: _buildTabBarArea(), // カスタムタブバー
                        ),
                      )
                    : null,
              ),
            ];
          },

          // ---- 本体部分 ----
          body: NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              _handleScrollNotification(scrollInfo);
              return false;
            },
            child: Stack(
              children: [
                Positioned.fill(child: _buildBodyStack()),

                // カテゴリバーを画面下に配置（本体が透けて見える）
                if (!_isRecordPageVisible &&
                    !_isPostCreateVisible &&
                    _currentIndex != 2)
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

      /// BottomNavBar
      bottomNavigationBar: AnimatedOpacity(
        opacity: _bottomNavOpacity,
        duration: const Duration(milliseconds: 200),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF0ABAB5),
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              // いろいろフラグが立ってたら閉じる
              if (_isRecordPageVisible ||
                  _isPostCreateVisible ||
                  _isProfileVisible ||
                  _isGroupShowVisible ||
                  _isGroupCreateVisible) {
                _isRecordPageVisible = false;
                _isPostCreateVisible = false;
                _isProfileVisible = false;
                _isGroupShowVisible = false;
                _isGroupCreateVisible = false;
              }
              _currentIndex = index;
            });
          },
          selectedItemColor: _isRecordPageVisible || _isPostCreateVisible
              ? const Color.fromARGB(255, 68, 68, 68)
              : Colors.white,
          unselectedItemColor: const Color.fromARGB(255, 68, 68, 68),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'タイムライン',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard),
              label: 'ランキング',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: '検索',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.timeline),
              label: 'データ',
            ),
          ],
        ),
      ),

      /// FAB
      floatingActionButton: _isRecordPageVisible || _isPostCreateVisible
          ? null
          : _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  //==================================================
  // タブバー
  //==================================================
  // タブバーの表示有無は _shouldShowTabBar で制御
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
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  //==================================================
  // BodyStack
  //==================================================
  Widget _buildBodyStack() {
    return Stack(
      children: [
        Positioned.fill(child: _currentScreen),
        if (_isRecordPageVisible)
          LanguageCategoryScreen(
            selectedCategory: _selectedCategory,
            onClose: () {
              setState(() {
                _isRecordPageVisible = false;
              });
            },
            categoryBar: _buildCategoryBar(context),
          )
        else if (_isPostCreateVisible)
          NewPostScreen(
            selectedCategory: _selectedCategory,
            onPostSubmitted: () {
              setState(() {
                _isPostCreateVisible = false;
              });
            },
          ),
      ],
    );
  }

  //==================================================
  // カテゴリバー
  //==================================================
  Widget _buildCategoryBar(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: LayoutBuilder(
        builder: (context, constraints) {
          double maxBarWidth = constraints.maxWidth * 0.68;
          double totalWidth = 0.0;
          List<Widget> categoryButtons = [];

          // 「全体」
          if (!_isRecordPageVisible &&
              (_currentIndex == 0 || _currentIndex == 1 || _currentIndex == 3)) {
            double buttonWidth = _calculateButtonWidth('全体');
            categoryButtons.add(_buildCategoryButton('全体'));
            totalWidth += buttonWidth;
          }

          // フォロー中の教科
          for (String subject in _followingSubjects) {
            double buttonWidth = _calculateButtonWidth(subject);
            categoryButtons.add(_buildCategoryButton(subject));
            totalWidth += buttonWidth;
          }

          double barWidth = totalWidth < maxBarWidth ? totalWidth : maxBarWidth;

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
  }

  double _calculateButtonWidth(String text) {
    const textStyle = TextStyle(fontSize: 14.0);
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    double paddingWidth = 36.0;
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

  //==================================================
  // Drawer
  //==================================================
  Widget _buildDrawer() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
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
                            Color.fromARGB(255, 255, 255, 255)
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 30,
                            child: Text(
                              _accountName.isNotEmpty ? _accountName[0] : '?',
                              style: const TextStyle(
                                fontSize: 35,
                                color: Color(0xFF0ABAB5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: <Widget>[
                              if (_loginStreak < 8)
                                Container()
                              else if (_loginStreak < 15)
                                Image.asset('images/smallCrown.png',
                                    width: 24, height: 24)
                              else if (_loginStreak < 22)
                                Image.asset('images/middleCrown.png',
                                    width: 24, height: 24)
                              else
                                Image.asset('images/bigCrown.png',
                                    width: 24, height: 24),
                              const SizedBox(width: 5),
                              Text(
                                _accountName,
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 100, 100, 100),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '@$_accountId',
                            style: const TextStyle(
                              color: Color.fromARGB(179, 160, 160, 160),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                'フォロワー: $_followers',
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 100, 100, 100)),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'フォロー中: $_follows',
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 100, 100, 100)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'フォロー中の教科: ${_followingSubjects.join(', ')}',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 100, 100, 100),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('プロフィール'),
                    onTap: () {
                      setState(() {
                        _isProfileVisible = true;
                        _profileUserId = _currentUserId;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('設定'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('ログアウト'),
                    onTap: () async {
                      try {
                        await FirebaseAuth.instance.signOut();
                        FirebaseAuth.instance
                            .authStateChanges()
                            .listen((User? user) {
                          if (user == null) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AuthenticationScreen(),
                              ),
                            );
                          }
                        });
                        print('ログアウト成功');
                      } catch (e) {
                        print('ログアウトエラー: $e');
                      }
                    },
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
                      builder: (context) => const ViewFormSelection(),
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
                      SnackBar(content: Text('単語の追加中にエラーが発生しました: $e')),
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
                      SnackBar(content: Text('文法の追加中にエラーが発生しました: $e')),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  //==================================================
  // FAB
  //==================================================
  Widget _buildFAB() {
    return Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        if (_showExtraButtons)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                setState(() => _showExtraButtons = false);
              },
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
                  onPressed: () {
                    _onMenuItemTap("btn1");
                  },
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
                  onPressed: () {
                    _onMenuItemTap("btn2");
                  },
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
              onLongPress: _onLongPress,
              child: FloatingActionButton(
                heroTag: null,
                onPressed: () {
                  setState(() {
                    if (_showExtraButtons) {
                      _showExtraButtons = false;
                    } else {
                      _isRecordPageVisible = true;
                    }
                  });
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
}
