import '/import.dart';

class InformationRegistrationScreen extends StatefulWidget {
  final String userId; // サインイン時に自動生成されたユーザーIDを渡す

  InformationRegistrationScreen({required this.userId});

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
  int _userNumber = 0;

  @override
  void initState() {
    super.initState();
    _userId = widget.userId; // 初期値として渡されたユーザーIDをセット
  }

  // ユーザー情報をFirebaseに保存するメソッド
  Future<void> _saveUserInfo() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

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
          'follower_ids': [], // 空のリスト
          'following_subjects': [], // 空のリスト
          'login_history': <Timestamp>[],
        });

        // サブコレクションを作成
        await userDoc.collection('post_timeline_ids').doc('init').set({});
        await userDoc.collection('posts').doc('init').set({});
        await userDoc.collection('followings').doc('init').set({});

        // following_subjects サブコレクションにドキュメントを追加
        final List<String> subjects = [
          'TOEIC',
          'TOEFL',
          '高校数学',
          '大学数学',
          'SPI',
          'プログラミング'
        ];
        for (String subject in subjects) {
          final subjectDoc = userDoc.collection('following_subjects').doc(subject);
          await subjectDoc.set({
            'name': subject, // 必要に応じて追加情報を保存
          });

          // TOEIC と TOEFL のサブコレクションを作成
          if (subject == 'TOEIC' || subject == 'TOEFL') {
            final List<String> levels = subject == 'TOEIC'
                ? ['up_to_300', 'up_to_500', 'up_to_700', 'up_to_900', 'up_to_990']
                : ['up_to_40', 'up_to_60', 'up_to_80', 'up_to_100', 'up_to_120'];

            for (String level in levels) {
              final levelDoc = subjectDoc.collection(level).doc();
              await levelDoc.set({});

              // 各レベルに「Words」「Grammar」「Listening」ドキュメントを作成
              final List<String> categories = ['Words', 'Grammar', 'Listening'];
              for (String category in categories) {
                final categoryDoc = subjectDoc.collection(level).doc(category);
                await categoryDoc.set({
                  'category_name': category, // 必要に応じてフィールドを追加
                });

                // 「Words」カテゴリの場合、「Word」「Idioms」のサブコレクションを作成
                if (category == 'Words') {
                  final List<String> wordCollections = ['Word', 'Idioms'];
                  for (String wordCollection in wordCollections) {
                    await categoryDoc.collection(wordCollection).doc('init').set({
                      'init_field': 'value', // 必要なら初期値を設定
                    });
                  }
                }
              }
            }
          }
        }

        print('ユーザー情報とサブコレクションが保存されました');

        // HomeScreen に遷移
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } catch (e) {
        print('エラーが発生しました: $e');
      }
    }
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
            backgroundColor: Colors.transparent, // AppBar自体の背景色を透明に
            elevation: 0,
            title: Row(
              children: const [
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
          child: ListView(
            children: [
              // ユーザーネームの入力フィールド
              TextFormField(
                decoration: InputDecoration(labelText: 'ユーザーネーム'),
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
                decoration: InputDecoration(labelText: 'ユーザーID'),
                initialValue: _userId,
                onSaved: (value) {
                  _ModifieduserId = value ?? '';
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ユーザーIDを入力してください';
                  }
                  return null;
                },
              ),
              // 年齢の入力フィールド
              TextFormField(
                decoration: InputDecoration(labelText: '年齢'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _age = int.tryParse(value ?? '0') ?? 0;
                },
                validator: (value) {
                  if (value == null || int.tryParse(value) == null || int.parse(value) <= 0) {
                    return '有効な年齢を入力してください';
                  }
                  return null;
                },
              ),
              // 職業の入力フィールド
              TextFormField(
                decoration: InputDecoration(labelText: '職業'),
                onSaved: (value) {
                  _occupation = value ?? '';
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '職業を入力してください';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // 保存ボタン
              ElevatedButton(
                onPressed: () async {
                  await addLoginHistory(_userId); // ログイン履歴の追加
                  await _saveUserInfo(); // ユーザー情報を保存する関数
                },
                child: Text('保存'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0ABAB5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
