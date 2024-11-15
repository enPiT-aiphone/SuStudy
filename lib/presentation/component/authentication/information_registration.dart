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
  int _age = 0;
  String _occupation = '';

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

        // ユーザー情報を保存
        await userDoc.set({
          'user_name': _userName,
          'user_id': _userId,
          'age': _age,
          'occupation': _occupation,
          'follower_ids': [], // 空のリスト
          'following_subjects': [], // 空のリスト
        });

        // サブコレクションを作成
        await userDoc.collection('post_timeline_ids').doc('init').set({});
        await userDoc.collection('posts').doc('init').set({});
        await userDoc.collection('followings').doc('init').set({});
        await userDoc.collection('following_subjects').doc('init').set({});

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
                  _userId = value ?? '';
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
                onPressed: _saveUserInfo,
                child: Text('保存'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0ABAB5), // `primary` を `backgroundColor` に変更
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
