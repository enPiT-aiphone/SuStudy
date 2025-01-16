// 必要なパッケージのインポート
import 'dart:ui'; // ImageFilterを使用するためのインポート
import 'package:sustudy_add/presentation/component/group_navigation.dart';
import '../add_word.dart';
import '../add_grammar.dart';
import '/import.dart'; // 他ファイルの内容を含む
import 'notification.dart'; // NotificationPageクラスが定義されているファイル
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuthをインポート
import 'record/record_TOEIC.dart'; // 記録画面のコンポーネント
import 'record/add_daily.dart';
import 'record/problem_toeic_word.dart'; // 記録画面のコンポーネント
import 'search/user_profile_screen.dart';
import 'post/post.dart';
import 'search/search.dart';
import 'ranking_dashboard.dart';
import 'group_navigation.dart';
import 'group_control.dart';
import 'timeline.dart';
import 'group_list.dart';
import '../add_idiom.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // メインのFlutterアプリケーション構築
    return MaterialApp(
      home: HomeScreen(), // アプリの初期画面をHomeScreenに設定
      theme: ThemeData(
        primaryColor: const Color(0xFF0ABAB5), // テーマカラーを設定
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0; // 現在選択されているボトムナビゲーションのインデックス
  bool _isRecordPageVisible = false;
  bool _isPostCreateVisible = false;
  bool _showExtraButtons = false; // サブボタンを表示するかの状態管理
  bool _isProfileVisible = false;
  bool _isGroupCreateVisible = false;
  bool _isGroupShowVisible = false;
  String _profileUserId = '';
  String _currentUserId = ''; 
  int _loginStreak = 0; // ログイン日数
  OverlayEntry? _overlayEntry; // OverlayEntryの参照を保持
  bool _isNotificationVisible = false; // 通知が表示されているかどうかを管理
  String _selectedCategory = ''; // 現在選択されたカテゴリ
  String _selectedTab = '最新'; // 現在選択されたタブ
  late AnimationController _animationController; // アニメーションコントローラ
  late Animation<double> _scaleAnimation; // スケールアニメーション
  late Animation<double> _opacityAnimation; // 透過アニメーション

  // Firebaseから取得したユーザー情報の変数
  String _accountName = ''; // ユーザー名
  String _accountId = ''; // ユーザーID
  int _userNumber = 0; // ユーザー番号
  int _followers = 0; // フォロワー数
  int _follows = 0; // フォロー数
  List<String> _followingSubjects = []; // フォロー中の教科のリスト
  List<dynamic> _loginHistory = [];

  @override
  // コールバック関数を定義
  void _onLoginStreakCalculated(int loginStreak) {
    setState(() {
      _loginStreak = loginStreak;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Firebaseからのユーザーデータ取得を呼び出し
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 220), // アニメーション時間を設定
      vsync: this, // アニメーションコントローラの初期化
    );

    // スケールアニメーションの設定
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1.05)
            .chain(CurveTween(curve: Curves.easeOut)), // スケールアップ
        weight: 170,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)), // スケールダウン
        weight: 50,
      ),
    ]).animate(_animationController);

    // 透過アニメーションの設定
    _opacityAnimation = Tween<double>(begin: 0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  // Firebaseからユーザーデータを取得
  Future<void> _fetchUserData() async {
    try {
      // FirebaseAuthを使用して現在ログイン中のユーザーIDを取得
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        print('ログインしているユーザーがいません');
        return;
      }

      // Usersコレクションから現在ログイン中のユーザーのデータを取得
      final userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('auth_uid', isEqualTo: userId)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final userData = userSnapshot.docs.first.data();
        setState(() {
          _accountName = userData['user_name'] ?? 'Unknown'; // ユーザー名
          _accountId = userData['user_id'] ?? 'ID Unknown'; // ユーザーID
          _currentUserId = userData['auth_uid'] ?? 'uid Unknown';
          _userNumber = userData['user_number'] ?? 0; // ユーザー番号
          _followers = userData['follower_count'];
          _follows = userData['follow_count'];
          _followingSubjects = List<String>.from(
              userData['following_subjects'] ?? []); // フォロー中の教科
          _loginHistory = userData['login_history'] ?? [];
          if (_followingSubjects.isNotEmpty) {
            _selectedCategory = _followingSubjects[0]; // 最初の教科を選択
          }
        });
      if (_loginHistory.isEmpty) {
        // 初回ログイン
        _showWelcomeDialog(userId, isFirstLogin: true);
      } else if (!_hasLoggedInToday()) {
        // 過去にログインしたことはあるが当日の履歴がない場合
        _showWelcomeDialog(userId, isFirstLogin: false);
      }
      } else {
        print('ユーザーデータが見つかりません');
      }
    } catch (e) {
      print('データ取得エラー: $e');
    }
  }

  // 当日の日付でログイン履歴をチェック
  bool _hasLoggedInToday() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    for (var timestamp in _loginHistory) {
      final loginDate = (timestamp as Timestamp).toDate();
      final normalizedDate = DateTime(loginDate.year, loginDate.month, loginDate.day);
      if (normalizedDate == todayDate) {
        return true; // 当日ログインが見つかった場合
      }
    }

    return false; // 当日のログインが存在しない場合
  }

// ウェルカムダイアログを表示
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
              child: Container(
              ),
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
                          onPressed: () async {// ダイアログを閉じる
                            await addDailyRecord(_selectedCategory, context); // ゴール値を設定
                            Navigator.of(context).pop();  
                            _navigateToQuiz(toeicLevel); // クイズ画面に遷移
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
    final toeicSubject =
        subjects.firstWhere((subject) => subject.startsWith('TOEIC'), orElse: () => '');
    final scoreMatch = RegExp(r'\d+').firstMatch(toeicSubject);
    return scoreMatch != null ? 'up_to_${scoreMatch.group(0)}' : 'up_to_500';
  }

  void _navigateToQuiz(String level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TOEICWordQuiz(level: level, questionType:'random'),
      ),
    );
  }

  // フローティングボタンを長押しした際にサブボタンを表示
void _onLongPress() {
  setState(() {
    _showExtraButtons = !_showExtraButtons;
  });
}


 // サブボタンをクリックした際の処理
void _onMenuItemTap(String menu) {
  setState(() {
    _showExtraButtons = false; // サブボタンを閉じる
  });

  if (menu == "btn1") {
    // btn1 特有の処理: LanguageCategoryScreen を表示
    setState(() {
      _isRecordPageVisible = true; // 記録ページ表示状態に設定
      _isPostCreateVisible = false; // 他の状態をリセット
    });
  }else if(menu == "btn2") {
    // btn2 特有の処理: NewPostScreen を表示
    setState(() {
      _isPostCreateVisible = true; // 投稿作成ページを表示状態に設定
      _isRecordPageVisible = false; // 他の状態をリセット
    });
  }
}
  

  // カテゴリの選択処理
  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  // タブの選択処理
  void _selectTab(String tab) {
    setState(() {
      _selectedTab = tab;
    });
  }

  @override
  void dispose() {
    _animationController.dispose(); // アニメーションコントローラの破棄
    super.dispose();
  }

  // 通知リストをOverlayで表示
  void _toggleNotificationOverlay(BuildContext context) {
    if (_isNotificationVisible) {
      _animationController.reverse().then((_) {
        _removeOverlay();
      });
    } else {
      _showOverlay(context);
      _animationController.reset(); // アニメーションの状態をリセット
      _animationController.forward(); // アニメーション開始
    }
  }

  // 通知オーバーレイを表示
  void _showOverlay(BuildContext context) {
    _overlayEntry = _createOverlayEntry(); // OverlayEntryを生成
    Overlay.of(context).insert(_overlayEntry!); // オーバーレイに挿入
    _isNotificationVisible = true;
  }

  // 通知オーバーレイを削除
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isNotificationVisible = false;
  }


  // 通知オーバーレイのエントリを生成
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

                            // クリックされた通知を取得
                            final selectedNotification = badgeViewModel.notifications.firstWhere(
                              (notif) => notif['id'] == docId,
                              orElse: () => {},
                            );

                            if (selectedNotification.isNotEmpty) {
                              // レベルを取得（デフォルトは 'up_to_500'）
                              final level = selectedNotification['level'] ?? 'up_to_500';

                              // 通知を既読にする処理
                              await badgeViewModel.markNotificationAsRead(docId);

                              // NotificationTOEICWordQuiz に遷移
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TOEICWordQuiz(level: level, questionType:'random'),
                                ),
                              );
                            } else {
                              print('通知が見つかりませんでした');
                            }
                            // オーバーレイを閉じる
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



  // 通知アイコンのウィジェットを構築
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
                        '${badgeViewModel.badgeCount}', // バッジに未読数を表示
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



  OverlayEntry _createGroupNavigationOverlay() {
  return OverlayEntry(
    builder: (context) => Stack(
      children: [
        // 背景をタップするとオーバーレイを閉じる
        GestureDetector(
          onTap: () => _removeOverlay(), // オーバーレイを閉じる
          child: Container(color: Colors.transparent),
        ),
        // グループナビゲーション画面
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
                        // グループ一覧を表示
                        setState(() {
                          _isGroupShowVisible = true;
                          _removeOverlay(); // オーバーレイを閉じる
                        });
                      },
                      onCreateGroupTap: () {
                        // グループ作成を表示
                        setState(() {
                          _isGroupCreateVisible = true;
                          _removeOverlay(); // オーバーレイを閉じる
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
    _overlayEntry = _createGroupNavigationOverlay(); // 新しいオーバーレイを作成
    Overlay.of(context).insert(_overlayEntry!);
    _isNotificationVisible = true; // オーバーレイ表示状態を管理
    _animationController.reset();
    _animationController.forward();
  }
}


// ボトムナビゲーションバーの項目を管理
Widget get _currentScreen {
  if (_isGroupShowVisible) {
      return const UserGroupsScreen(); // グループ一覧画面
    } else if (_isGroupCreateVisible) {
      return CreateGroupScreen(); // グループ作成画面
    } if (_isProfileVisible) {
    return UserProfileScreen(
          userId: _profileUserId ,
          onBack: () {
            setState(() {
              _isProfileVisible = false; // プロフィール画面を閉じる
              _profileUserId = ''; // プロフィール表示のユーザーIDをリセット
            });
          },
        );
      } else if (_currentIndex == 0) {
    return  TimelineScreen(
      selectedTab: _selectedTab,
      onUserProfileTap: (userId) { // コールバックの実装
        setState(() {
          _isProfileVisible = true; // プロフィール画面を表示
          _profileUserId = userId; // ユーザーIDを保存
        });
      },
    );
  } else if (_currentIndex == 1) {
    return RankingScreen(
      selectedTab: _selectedTab,
      selectedCategory: _selectedCategory,
    );
  } else if (_currentIndex == 2) {
    return SearchScreen();
  } else {
    return DashboardScreen(
      selectedTab: _selectedTab,
      selectedCategory: _selectedCategory,
      onLoginStreakCalculated: _onLoginStreakCalculated,
    );
  }
}




@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        Positioned.fill(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0ABAB5), Color(0xFFFFFFFF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  AppBar(
                    automaticallyImplyLeading: false,
                    title: Builder(
                      builder: (context) => Row(
                        children: [
                          GestureDetector(
                            onTap: () => Scaffold.of(context).openDrawer(),
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 18,
                                      child: Text(
                                _accountName.isNotEmpty ? _accountName[0] : '?', // user_nameの一文字目
                                style: const TextStyle(
                                  fontSize: 20, // フォントサイズ
                                  color: Color(0xFF0ABAB5), // テキストカラー
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'SuStudy,',
                            style: TextStyle(fontSize: 25, color: Colors.white),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.group_add),
                            onPressed: () {
                              _toggleGroupNavigationOverlay(context);
                            },
                          ),
                          _buildNotificationIcon(), // 通知アイコンを表示
                          IconButton(icon: const Icon(Icons.mail), onPressed: () {}),
                          
                        ],
                      ),
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                  if (!_isProfileVisible && !_isRecordPageVisible && !_isPostCreateVisible && _currentIndex == 0 || !_isProfileVisible && !_isRecordPageVisible && !_isPostCreateVisible && _currentIndex == 1)
                    _buildCustomTabBar(), // タブバーを表示
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  _currentScreen,
                  if (_isRecordPageVisible)
                    LanguageCategoryScreen(
                      selectedCategory: _selectedCategory,
                      onClose: () {
                        setState(() {
                          _isRecordPageVisible = false; // フローティングボタンで開いたページを閉じる
                        });
                      },
                      categoryBar: _buildCategoryBar(context), // カテゴリバーを渡す
                    )
                  else if (_isPostCreateVisible)
                    NewPostScreen(
                      selectedCategory: _selectedCategory,
                      onPostSubmitted: (){
                        setState(() {
                          _isPostCreateVisible = false; // 投稿後にページを閉じる
                        });
                      },
                    ),
                ],
              ),
            ),
           ],
         ),
        ),
          if (!_isRecordPageVisible && !_isPostCreateVisible && _currentIndex != 2)
          Positioned(
            bottom: 0, // 画面の下部に配置
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10.0), // 下のマージン調整
              child: _buildCategoryBar(context),
            ),
          ),
      ],
    ),
    drawerEnableOpenDragGesture: true,
    drawer: _buildDrawer(), // ドロワー

floatingActionButton: _isRecordPageVisible || _isPostCreateVisible
    ? null // 記録画面が表示中の場合、フローティングボタンを非表示
    : Stack(
      alignment: Alignment.bottomRight,
        clipBehavior: Clip.none, // Stack の外も描画できるようにする
        children: [
          // サブボタンを閉じるための透明なタップ領域
          if (_showExtraButtons)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showExtraButtons = false; // サブボタンを閉じる
                  });
                },
                child: Container(
                  color: Colors.transparent, // 背景を透明にする
                ),
              ),
            ),
          // サブボタンを表示
          if (_showExtraButtons)
            Stack(
              children: [
                // サブボタン1（左上）
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.05 + 100,
                  right: MediaQuery.of(context).size.width * 0 + 10,
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
                // サブボタン2（真上）
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.05 + 70,
                  right: MediaQuery.of(context).size.width * 0+ 70,
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
                // サブボタン3（左）
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.05 + 10,
                  right: MediaQuery.of(context).size.width * 0 + 100,
                  child: FloatingActionButton(
                    heroTag: null,
                    shape: const CircleBorder(),
                    backgroundColor: const Color.fromARGB(255, 64, 239, 234),
                    child: const Icon(Icons.done),
                    onPressed: () {
                    },
                  ),
                ),
              ],
            ),

          // メインフローティングボタン
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.05,
            right: MediaQuery.of(context).size.width * 0,
            child: SizedBox(
              width: 80, // ボタンの幅を適切なサイズに設定
              height: 80, // ボタンの高さを適切なサイズに設定
              child: GestureDetector(
                onLongPress: _onLongPress, // 長押しでサブボタンを表示
                child: FloatingActionButton(
                  heroTag: null,
                  onPressed: () {
                    setState(() {
                      if (_showExtraButtons) {
                        _showExtraButtons = false; // サブボタンを閉じる
                      } else {
                        _isRecordPageVisible = true; // 記録画面を表示
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
      ),
floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,



    bottomNavigationBar: BottomNavigationBar(
      backgroundColor: const Color(0xFF0ABAB5),
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          if (_isRecordPageVisible || _isPostCreateVisible || _isProfileVisible ||_isGroupShowVisible ||_isGroupCreateVisible) {
            _isRecordPageVisible = false; // フロート画面を閉じる
            _isPostCreateVisible = false;
            _isProfileVisible = false; // プロフィール画面を閉じる
            _isGroupShowVisible = false;
            _isGroupCreateVisible = false;
          }
          _currentIndex = index; // ボトムナビゲーションバーの選択を反映
        });
      },
      selectedItemColor: _isRecordPageVisible || _isPostCreateVisible
          ? const Color.fromARGB(255, 68, 68, 68) // フロート画面時は全てグレー
          : Colors.white, // 通常時は選択された項目を白色に
      unselectedItemColor: const Color.fromARGB(255, 68, 68, 68), // 未選択は常にグレー
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
  );
}



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
                    _profileUserId = _currentUserId; // 自分の userId
                  });
                  Navigator.pop(context); // ドロワーを閉じる
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 30,
                          child: Text(
                          _accountName.isNotEmpty ? _accountName[0] : '?', // user_nameの一文字目
                          style: const TextStyle(
                            fontSize: 35, // フォントサイズ
                            color: Color(0xFF0ABAB5), // テキストカラー
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
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
                            color: Color.fromARGB(255, 100, 100, 100)),
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
                      _profileUserId = _currentUserId; // 自分の userId を設定
                    });
                    Navigator.pop(context); // ドロワーを閉じる
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
                      await FirebaseAuth.instance.signOut(); // Firebaseでログアウト
                      // FirebaseAuth の状態を監視
                      FirebaseAuth.instance.authStateChanges().listen((User? user) {
                        if (user == null) {
                          // ユーザーがログアウトした場合は AuthenticationScreen に遷移
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => AuthenticationScreen()),
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
          // ���定のユーザ番号に応じてデータベース管理フォームを表示
        if (_userNumber >= 1 && _userNumber <= 6)
              ListTile(
                leading: const Icon(Icons.build),
                title: const Text('データベース管理フォーム'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ViewFormSelection()),
                  );
                },
              ),
          if (_userNumber == 1)
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('単語を追加'),
                onTap: () async {
                  try {
                    await uploadWordsToFirestore(); // add_word.dartの関数を呼び出し
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
                    await uploadGrammarToFirestore(); // add_grammar.dartの関数を呼び出し
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

  // タブバーを構築するメソッド
Widget _buildCustomTabBar() {
  return Container(
    color: Colors.transparent,
    padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
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
  return GestureDetector(
    onTap: () {
      setState(() {
        _selectedTab = tab; // 選択されたタブを更新
      });
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: _selectedTab == tab ? const Color(0xFF0ABAB5) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tab,
        style: TextStyle(
          color: _selectedTab == tab ? Colors.white : Colors.black,
          fontSize: 14,
        ),
      ),
    ),
  );
}


  // カテゴリバーの構築メソッド
Widget _buildCategoryBar(BuildContext context) {
  return Align(
    alignment: Alignment.bottomCenter,
    child: LayoutBuilder(
      builder: (context, constraints) {
        // 画面幅の0.7倍を最大幅として設定
        double maxBarWidth = constraints.maxWidth * 0.68;

        // 各カテゴリのボタンを生成して、その合計幅を計算
        double totalWidth = 0.0;
        List<Widget> categoryButtons = [];

        if (!_isRecordPageVisible && _currentIndex == 0 ||
            !_isRecordPageVisible && _currentIndex == 1 ||
            !_isRecordPageVisible && _currentIndex == 3) {
          double buttonWidth = _calculateButtonWidth('全体');
          categoryButtons.add(_buildCategoryButton('全体'));
          totalWidth += buttonWidth;
        }

        for (String subject in _followingSubjects) {
          double buttonWidth = _calculateButtonWidth(subject);
          categoryButtons.add(_buildCategoryButton(subject));
          totalWidth += buttonWidth;
        }

        // カテゴリバーの幅を、教科に依存する合計幅と最大幅の小さい方に設定
        double barWidth = totalWidth < maxBarWidth ? totalWidth : maxBarWidth;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0), // 上下の余白を調整
          child: Container(
            width: barWidth,
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
            decoration: BoxDecoration(
              color: Colors.grey[200], // バーの背景色
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(50),
                right: Radius.circular(50),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12, // 軽い影をつけてバーを浮かせる
                  blurRadius: 4.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categoryButtons,
              ),
            ),
          ),
        );
      },
    ),
  );
}


  // 各カテゴリボタンの幅を計算するメソッド
  double _calculateButtonWidth(String text) {
    // テキストスタイルを定義
    TextStyle textStyle = const TextStyle(
      fontSize: 14.0, // ボタン内のテキストのフォントサイズ
    );

    // TextPainterを使ってテキストの幅を計算
    TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(); // テキストのレイアウトを計算

    // テキスト幅に余白を加算
    double paddingWidth = 36.0; // 両サイドの余白
    return textPainter.width + paddingWidth;
  }

  // カテゴリボタンの構築メソッド
  Widget _buildCategoryButton(String category) {
    return GestureDetector(
      onTap: () {
        _selectCategory(category);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: _selectedCategory == category
              ? const Color(0xFF0ABAB5)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: _selectedCategory == category ? Colors.white : Colors.black,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

