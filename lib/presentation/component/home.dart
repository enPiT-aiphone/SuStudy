import '/import.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
      theme: ThemeData(
        primaryColor: Color(0xFF0ABAB5),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _selectedCategory = '';
  String _selectedTab = '最新';

  String _accountName = '';
  String _accountId = '';
  int _userNumber = 0;
  int _followers = 0;
  int _following = 0;
  List<String> _followingSubjects = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('user_id', isEqualTo: 'ASAHIdayo')
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final userData = userSnapshot.docs.first.data();
        setState(() {
          _accountName = userData['user_name'] ?? 'Unknown';
          _accountId = userData['user_id'] ?? 'ID Unknown';
          _userNumber = userData['user_number'] ?? 0;

          // follower_idsのリスト長をフォロワー数として使用
          _followers = (userData['follower_ids'] as List<dynamic>?)?.length ?? 0;

          // following_subjectsのリストをフォロー中の教科として使用
          _followingSubjects = List<String>.from(userData['following_subjects'] ?? []);
          
          if (_followingSubjects.isNotEmpty) {
            _selectedCategory = _followingSubjects[0];
          }
        });

        final followingsSnapshot = await userSnapshot.docs.first.reference
            .collection('followings')
            .get();

        setState(() {
          _following = followingsSnapshot.docs.length;
        });
      } else {
        print('ユーザーデータが見つかりません');
      }
    } catch (e) {
      print('データ取得エラー: $e');
    }
  }

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

  void _onBottomNavigationTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (_currentIndex == 2 && _selectedCategory == '全体') {
        _selectedCategory = _followingSubjects.isNotEmpty ? _followingSubjects[0] : 'TOEIC';
      }
    });
  }

  List<Widget> get _pages => [
        Center(child: Text('$_selectedTabの$_selectedCategoryのタイムライン画面')),
        Center(child: Text('$_selectedTabの$_selectedCategoryのランキング画面')),
        Center(child: Text('$_selectedCategoryの記録をつける画面')),
        DashboardScreen(
          selectedTab: _selectedTab,
          selectedCategory: _selectedCategory,
        ),
        Center(child: Text('設定画面')),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0ABAB5), const Color.fromARGB(255, 255, 255, 255)],
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
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.notifications),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.mail),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                if (_currentIndex == 0 || _currentIndex == 1) _buildCustomTabBar(),
              ],
            ),
          ),
          Expanded(
            child: _pages[_currentIndex],
          ),
          if (_currentIndex != 4) _buildCategoryBar(context),
        ],
      ),
      drawerEnableOpenDragGesture: true,
      drawer: _buildDrawer(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

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
                        colors: [Color(0xFF0ABAB5), Color.fromARGB(255, 255, 255, 255)],
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
                          child: Icon(Icons.person, color: Color(0xFF0ABAB5), size: 40),
                        ),
                        SizedBox(height: 10),
                        Text(
                          _accountName,
                          style: TextStyle(
                            color: Color.fromARGB(255, 100, 100, 100),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                              style: TextStyle(color: Color.fromARGB(255, 100, 100, 100)),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'フォロー中: $_following',
                              style: TextStyle(color: Color.fromARGB(255, 100, 100, 100)),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          'フォロー中の教科: ${_followingSubjects.join(', ')}',
                          style: TextStyle(color: Color.fromARGB(255, 100, 100, 100)),
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
                    leading: Icon(Icons.logout),
                    title: Text('ログアウト'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            if (_userNumber >= 1 && _userNumber <= 6)
              ListTile(
                leading: Icon(Icons.build),
                title: Text('データベース管理フォーム'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ViewFormSelection()),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

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
          icon: Icon(Icons.post_add),
          label: '記録',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.timeline),
          label: 'データ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: '設定',
        ),
      ],
    );
  }

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

  Widget _buildCategoryBar(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double barWidth = screenWidth * 0.7;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Container(
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
            children: [
              if (_currentIndex == 0 || _currentIndex == 1 || _currentIndex == 3)
                _buildCategoryButton('全体'),
              if (_followingSubjects.isNotEmpty)
                for (String subject in _followingSubjects)
                  _buildCategoryButton(subject),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String category) {
    return GestureDetector(
      onTap: () {
        _selectCategory(category);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: _selectedCategory == category ? Color(0xFF0ABAB5) : Colors.transparent,
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
