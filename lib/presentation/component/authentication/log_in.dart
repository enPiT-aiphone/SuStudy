import '/import.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuthをインポート

class LogInScreen extends StatefulWidget {
  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  String _email = '';
  String _password = '';
  String? _errorMessage; // エラーメッセージを保存する変数

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
                    fontSize: 25, // フォントサイズを20に設定
                    color: Colors.white, // 文字色を白に設定
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // エラーメッセージを表示するウィジェット
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(labelText: 'メールアドレス'),
              onChanged: (value) => setState(() => _email = value),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'パスワード'),
              obscureText: true,
              onChanged: (value) => setState(() => _password = value),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _errorMessage = null; // エラーメッセージをリセット
                });
                try {
                  final user = await FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: _email, password: _password);
                  if (user != null) {
                    print('ログイン成功: ${user.user?.email}');
                    Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => HomeScreen()),
                    ); // 遷移先の画面を指定
                  }
                } on FirebaseAuthException catch (e) {
                  // エラーメッセージを設定
                  setState(() {
                    if (e.code == 'user-not-found') {
                      _errorMessage = 'このメールアドレスのユーザーは見つかりません。';
                    } else if (e.code == 'wrong-password') {
                      _errorMessage = 'パスワードが間違っています。';
                    } else if (e.code == 'invalid-email') {
                      _errorMessage = '有効なメールアドレスを入力してください。';
                    } else {
                      _errorMessage = 'エラーが発生しました。もう一度お試しください。';
                    }
                  });
                } catch (e) {
                  setState(() {
                    _errorMessage = '予期しないエラーが発生しました。';
                  });
                  print('ログインエラー: $e');
                }
              },
              child: Text('ログイン'),
            ),
          ],
        ),
      ),
    );
  }
}
