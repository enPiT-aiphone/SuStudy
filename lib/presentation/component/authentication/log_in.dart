import '/import.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuthをインポート

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

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
      backgroundColor: Colors.white,
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
            iconTheme: const IconThemeData(
              color: Colors.white,
            ),
            title: const Row(
              children: [
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // エラーメッセージを表示するウィジェット
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 10),
            const Text('登録したメールアドレスでログイン',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 50, 50, 50),
                ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(labelText: 'メールアドレス'),
              onChanged: (value) => setState(() => _email = value),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'パスワード'),
              obscureText: true,
              onChanged: (value) => setState(() => _password = value),
            ),
            const Spacer(), // ボタンを画面下部に押し出す
            _buildAuthenticationButton(
              context,
              'ログイン',
              () async {
                setState(() {
                  _errorMessage = null; // エラーメッセージをリセット
                });
                try {
                  final user = await FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: _email, password: _password);
                  print('ログイン成功: ${user.user?.email}');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  ); // 遷移先の画面を指定
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
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

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
}
