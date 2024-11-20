// 必要なパッケージのインポート
import '/import.dart'; // 他ファイルの内容を含む
import 'notification.dart'; // NotificationPageクラスが定義されているファイル
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuthをインポート
import 'record/record_TOEIC.dart'; // 記録画面のコンポーネント

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // メインのFlutterアプリケーション構築
    return MaterialApp(
      home: HomeScreen(), // アプリの初期画面をHomeScreenに設定
      theme: ThemeData(
        primaryColor: Color(0xFF0ABAB5), // テーマカラーを設定
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0; // 現在選択されているボトムナビゲーションのインデックス
  int loginDays = 15; // ログイン日数
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
  int _following = 0; // フォロー数
  List<String> _followingSubjects = []; // フォロー中の教科のリスト

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
          .where('user_id', isEqualTo: userId)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final userData = userSnapshot.docs.first.data();
        setState(() {
          _accountName = userData['user_name'] ?? 'Unknown'; // ユーザー名
          _accountId = userData['user_id'] ?? 'ID Unknown'; // ユーザーID
          _userNumber = userData['user_number'] ?? 0; // ユーザー番号
          _followers = (userData['follower_ids'] as List<dynamic>?)?.length ??
              0; // フォロワー数
          _followingSubjects = List<String>.from(
              userData['following_subjects'] ?? []); // フォロー中の教科
          if (_followingSubjects.isNotEmpty) {
            _selectedCategory = _followingSubjects[0]; // 最初の教科を選択
          }
        });

        // フォロー数を取得
        final followingsSnapshot = await userSnapshot.docs.first.reference
            .collection('followings')
            .get();

        setState(() {
          _following = followingsSnapshot.docs.length; // フォロー数を更新
        });
      } else {
        print('ユーザーデータが見つかりません');
      }
    } catch (e) {
      print('データ取得エラー: $e');
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

  // ボトムナビゲーションの項目がタップされた時の処理
  void _onBottomNavigationTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (_currentIndex == 2 && _selectedCategory == '全体') {
        _selectedCategory = _followingSubjects.isNotEmpty
            ? _followingSubjects[0]
            : 'TOEIC'; // 記録画面でカテゴリを選択
      }
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
            onTap: () => _toggleNotificationOverlay(context), // タップでオーバーレイを閉じる
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            top: kToolbarHeight + 10, // 通知リストの位置を指定
            right: 50,
            child: ScaleTransition(
              scale: _scaleAnimation, // スケールアニメーションを適用
              alignment: Alignment.topRight,
              child: FadeTransition(
                opacity: _opacityAnimation, // 透過アニメーションを適用
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 250,
                    height: 300,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
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
                            onNotificationTap: (docId) =>
                                badgeViewModel.markNotificationAsRead(docId),
                          ); // 通知ページを表示
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
          icon: Icon(Icons.notifications),
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
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    )
                  : Container();
            },
          ),
        ),
      ],
    );
  }

  // ボトムナビゲーションバーの項目を管理
  List<Widget> get _pages => [
        Center(child: Text('$_selectedTabの$_selectedCategoryのタイムライン画面')),
        Center(child: Text('$_selectedTabの$_selectedCategoryのランキング画面')),
        Center(child: Text('検索画面')),
        LanguageCategoryScreen(
            selectedCategory: _selectedCategory), // _selectedCategory を渡す
        DashboardScreen(
          selectedTab: _selectedTab,
          selectedCategory: _selectedCategory,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
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
                            child: Icon(Icons.person, color: Color(0xFF0ABAB5)),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'SuStudy,',
                          style: TextStyle(fontSize: 25, color: Colors.white),
                        ),
                        Spacer(),
                        _buildNotificationIcon(), // 通知アイコンを表示
                        IconButton(icon: Icon(Icons.mail), onPressed: () {}),
                      ],
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                if (_currentIndex == 0 || _currentIndex == 1)
                  _buildCustomTabBar(), // タブバーを表示
              ],
            ),
          ),
          Expanded(child: _pages[_currentIndex]),
          if (_currentIndex != 2) _buildCategoryBar(context),
        ],
      ),
      drawerEnableOpenDragGesture: true,
      drawer: _buildDrawer(), // ドロワー
      bottomNavigationBar: _buildBottomNavigationBar(), // ボトムナビゲーションバー
    );
  }

  // ドロワーを構築するメソッド
  Widget _buildDrawer() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF0ABAB5),
                          Color.fromARGB(255, 255, 255, 255)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 30,
                          child: Icon(Icons.person,
                              color: Color(0xFF0ABAB5), size: 40),
                        ),
                        SizedBox(height: 10),
                        Row(children: <Widget>[
                          if (loginDays < 8) Container()
                          else if (loginDays < 15) Image.asset('images/smallCrown.png', width: 24, height: 24)
                          else if (loginDays < 22) Image.asset('images/middleCrown.png', width: 24, height: 24)
                          else Image.asset('images/bigCrown.png', width: 24, height: 24),
                          SizedBox(width: 5),
                          Text(
                            _accountName,
                            style: TextStyle(
                              color: Color.fromARGB(255, 100, 100, 100),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ]),
                        Text(
                          '@$_accountId',
                          style: TextStyle(
                            color: Color.fromARGB(179, 160, 160, 160),
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              'フォロワー: $_followers',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 100, 100, 100)),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'フォロー中: $_following',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 100, 100, 100)),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          'フォロー中の教科: ${_followingSubjects.join(', ')}',
                          style: TextStyle(
                              color: Color.fromARGB(255, 100, 100, 100)),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('プロフィール'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('設定'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('ログアウト'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            // 特定のユーザ番号に応じてデータベース管理フォームを表示
            if (_userNumber >= 1 && _userNumber <= 6)
              ListTile(
                leading: Icon(Icons.build),
                title: Text('データベース管理フォーム'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewFormSelection()),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // ボトムナビゲーションバーの構築メソッド
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: Color(0xFF0ABAB5),
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      onTap: _onBottomNavigationTapped,
      selectedItemColor: Colors.white,
      unselectedItemColor: const Color.fromARGB(255, 68, 68, 68),
      items: [
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
          icon: Icon(Icons.post_add),
          label: '記録',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.timeline),
          label: 'データ',
        ),
      ],
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

  // タブボタンの構築メソッド
  Widget _buildTabButton(String tab) {
    return GestureDetector(
      onTap: () {
        _selectTab(tab);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: _selectedTab == tab ? Color(0xFF0ABAB5) : Colors.transparent,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 画面幅の0.7倍を最大幅として設定
          double maxBarWidth = constraints.maxWidth * 0.7;

          // 各カテゴリのボタンを生成して、その合計幅を計算
          double totalWidth = 0.0;
          List<Widget> categoryButtons = [];

          if (_currentIndex == 0 || _currentIndex == 1 || _currentIndex == 4) {
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

          return Container(
            width: barWidth,
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(50),
                right: Radius.circular(50),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categoryButtons,
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
    TextStyle textStyle = TextStyle(
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
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: _selectedCategory == category
              ? Color(0xFF0ABAB5)
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
