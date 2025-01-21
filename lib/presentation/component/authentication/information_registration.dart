import '/import.dart';
import 'registration_subjects.dart';

class InformationRegistrationScreen extends StatefulWidget {
  final String userId; // サインイン時に自動生成されたユーザーIDを渡す

  const InformationRegistrationScreen({super.key, required this.userId});

  @override
  _InformationRegistrationScreenState createState() =>
      _InformationRegistrationScreenState();
}

class _InformationRegistrationScreenState
    extends State<InformationRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _userName = '';
  String _userId = '';
  String _ModifieduserId = '';
  int _age = 0;
  String _occupation = '';
  String _subOccupation = '';
  int _userNumber = 0;
  final int _followcount = 0;
  final int _followercount = 0;
  String? _userIdError;
  Map<String, String?> _errors = {};
  

  // 職業選択肢のリスト
  final List<String> _occupations = [
    '中学生',
    '浪人生',
    '高校生',
    '大学生',
    '大学院生',
    '社会人'
  ];

   // 年齢選択肢のリスト (10歳～100歳)
  final List<int> _ages = List<int>.generate(91, (i) => i + 10);

  final List<String> _juniorHighAndHighSchoolGrades = ['1年生', '2年生', '3年生'];
  final List<String> _universityGrades = [
    '1年生',
    '2年生',
    '3年生',
    '4年生',
    '5年生',
    '6年生'
  ];
  final List<String> _graduateCourses = ['修士課程', '博士課程'];
  final List<String> _jobIndustries = [
    'IT・通信・インターネット',
    'メーカー',
    '商社',
    'サービス・レジャー',
    '流通・小売・フード',
    'マスコミ・広告・デザイン',
    '金融・保険',
    'コンサルティング',
    '不動産・建設・設備',
    '運輸・交通・物流・倉庫',
    '環境・エネルギー',
    '公的機関'
  ];

  @override
  void initState() {
    super.initState();
    _userId = widget.userId; // 初期値として渡されたユーザーIDをセット
  }

    // ユーザーIDが既に使用されているか確認する非同期関数
  Future<bool> _isUserIdAvailable(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('user_id', isEqualTo: userId)
        .get();
    return snapshot.docs.isEmpty;
  }

  // ユーザー情報をFirebaseに保存するメソッド
  Future<void> _saveUserInfo() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor:  AlwaysStoppedAnimation<Color>(Color(0xFF0ABAB5)),
          ),
        );
      },
    );

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final isAvailable = await _isUserIdAvailable(_ModifieduserId);
      if (!isAvailable) {
        setState(() {
          _userIdError = 'このユーザーIDはすでに使われています';
        });
        return;
      }
      
      bool hasError = false;

      setState(() {
        _errors.clear(); // エラーメッセージをリセット

        // 年齢バリデーション
        if (_age == 0) {
          _errors['age'] = '年齢を選択してください。';
          hasError = true;
        }

        // 職業バリデーション
        if (_occupation.isEmpty) {
          _errors['occupation'] = '職業を選択してください。';
          hasError = true;
        }

        // サブカテゴリーのバリデーション
        if (_occupation == '中学生' || _occupation == '高校生') {
          if (_subOccupation.isEmpty) {
            _errors['subOccupation'] = '学年を選択してください。';
            hasError = true;
          }
        } else if (_occupation == '大学生') {
          if (_subOccupation.isEmpty) {
            _errors['subOccupation'] = '学年を選択してください。';
            hasError = true;
          }
        } else if (_occupation == '大学院生') {
          if (_subOccupation.isEmpty) {
            _errors['subOccupation'] = '課程を選択してください。';
            hasError = true;
          }
        } else if (_occupation == '社会人') {
          if (_subOccupation.isEmpty) {
            _errors['subOccupation'] = '業界を選択してください。';
            hasError = true;
          }
        }
      });

      if (hasError) {
        Navigator.of(context).pop(); 
        return; // エラーがある場合、保存処理を中断
      }

      try {
        // Firebaseにユーザー情報を保存
        final userDoc = FirebaseFirestore.instance.collection('Users').doc(_userId);
        final userCollection = FirebaseFirestore.instance.collection('Users');
        final userSnapshot = await userCollection.get();
        _userNumber = userSnapshot.docs.length;

        // ユーザー情報を保存
        await userDoc.update({
          'user_name': _userName,
          'user_id': _ModifieduserId,
          'age': _age,
          'user_number': _userNumber,
          'occupation': _occupation,
          'sub_occupation': _subOccupation,
          'follower_count': _followercount, // 空のリスト
          'follow_count':_followcount,
          'following_subjects': [], // 空のリスト
          'login_history': <Timestamp>[],
          't_solved_count': 0, 
          'registrationStep': 1,
        });

        // サブコレクションを作成
        await userDoc.collection('post_timeline_ids').doc('init').set({});
        await userDoc.collection('posts').doc('init').set({});
        // `follows` サブコレクションに `SuStudy` ドキュメントを作成してタイムスタンプを保存
        await userDoc.collection('follows').doc('SuStudy').set({
          'timestamp': FieldValue.serverTimestamp(), // 現在のタイムスタンプ
        });
        await userDoc.collection('followers').doc('init').set({});

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubjectSelectionScreen(userId: widget.userId),
        ),
      );
      } catch (e) {
        print('エラーが発生しました: $e');
      }
    }
  }

    // オーバーレイで年齢を選択
  Future<void> _selectAge() async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: _ages.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text('${_ages[index]} 歳'),
              onTap: () {
                setState(() {
                  _age = _ages[index];
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  // オーバーレイで職業を選択
  Future<void> _selectOccupation() async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: _occupations.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(_occupations[index]),
              onTap: () {
                setState(() {
                  _occupation = _occupations[index];
                  _subOccupation = '';
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

    Future<void> _selectSubOccupation(List<String> options) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: options.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(options[index]),
              onTap: () {
                setState(() {
                  _subOccupation = options[index];
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  // カスタムボタン
  Widget _buildAuthenticationButton(
      BuildContext context, String label, VoidCallback onPressed) {
    final double buttonWidth = MediaQuery.of(context).size.width * 0.75; // ボタンの幅を画面の0.75倍に設定

    return InkWell(
      onTap: onPressed, // ボタンが押されたときの処理
      child: Container(
        width: buttonWidth, // ボタンの幅を設定
        alignment: Alignment.center, // ボタン内のテキストを中央に配置
        padding: const EdgeInsets.symmetric(vertical: 15), // ボタンの上下パディングを設定
        decoration: BoxDecoration(
          color: Colors.white, // ボタンの背景色を白に設定
          border: Border.all(color: const Color(0xFF0ABAB5)), // ボタンの境界線の色を設定
          borderRadius: BorderRadius.circular(15), // 角を丸くする
        ),
        child: Text(
          label, // ボタンのラベル
          style: const TextStyle(
            color: Color(0xFF0ABAB5), // テキストの色を設定
            fontSize: 18, // フォントサイズを設定
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            title: const Row(
              children: [
                // アプリのタイトル「SuStudy,」を表示
                Text(
                  'SuStudy, ',
                  style: TextStyle(
                    fontSize: 25,  // フォントサイズを20に設定
                    color: Colors.white,  // 文字色を白に設定
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),
            const Text('ユーザー情報の登録',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 50, 50, 50),
              ),
            ),
            const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    // ユーザーネームの入力フィールド
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'ユーザーネーム'),
                      onSaved: (value) {
                        _userName = value ?? '';
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'ユーザーネームを入力してください';
                        }
                        return null;
                      },
                    ),
                    // ユーザーIDの編集可能なフィールド
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'ユーザーID',
                        errorText: _userIdError,
                        ),
                      initialValue: _userId,
                      onSaved: (value) {
                        _ModifieduserId = value ?? '';
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'ユーザーIDを入力してください';
                        }
                        if (!RegExp(r'^[A-Za-z0-9_]+$').hasMatch(value)) {
                          return 'ユーザーIDはローマ字(A, a)、アンダーバー(_)、数字(1, 2)のみを使用してください';
                        }
                        return null;
                      },
                    ),
                    // 年齢選択
                    if (_errors['age'] != null)
                      Text(
                        _errors['age']!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ListTile(
                      title: Text(_age > 0 ? '年齢: $_age 歳' : '年齢を選択'),
                      trailing: const Icon(Icons.keyboard_arrow_down),
                      onTap: _selectAge,
                    ),
                    const Divider(),

                    // 職業選択
                    if (_errors['occupation'] != null)
                      Text(
                        _errors['occupation']!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ListTile(
                      title: Text(_occupation.isNotEmpty ? '職業: $_occupation' : '職業を選択'),
                      trailing: const Icon(Icons.keyboard_arrow_down),
                      onTap: _selectOccupation,
                    ),

                    // サブカテゴリー選択
                    if (_errors['subOccupation'] != null)
                      Text(
                        _errors['subOccupation']!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    if (_occupation == '中学生' || _occupation == '高校生')
                      ListTile(
                        title: Text(
                            _subOccupation.isNotEmpty ? '学年: $_subOccupation' : '学年を選択'),
                        trailing: const Icon(Icons.keyboard_arrow_down),
                        onTap: () => _selectSubOccupation(_juniorHighAndHighSchoolGrades),
                      ),
                    if (_occupation == '大学生')
                      ListTile(
                        title: Text(
                            _subOccupation.isNotEmpty ? '学年: $_subOccupation' : '学年を選択'),
                        trailing: const Icon(Icons.keyboard_arrow_down),
                        onTap: () => _selectSubOccupation(_universityGrades),
                      ),
                    if (_occupation == '大学院生')
                      ListTile(
                        title: Text(
                            _subOccupation.isNotEmpty ? '課程: $_subOccupation' : '課程を選択'),
                        trailing: const Icon(Icons.keyboard_arrow_down),
                        onTap: () => _selectSubOccupation(_graduateCourses),
                      ),
                    if (_occupation == '社会人')
                      ListTile(
                        title: Text(
                            _subOccupation.isNotEmpty ? '業界: $_subOccupation' : '業界を選択'),
                        trailing: const Icon(Icons.keyboard_arrow_down),
                        onTap: () => _selectSubOccupation(_jobIndustries),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildAuthenticationButton(context, '保存', _saveUserInfo),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
