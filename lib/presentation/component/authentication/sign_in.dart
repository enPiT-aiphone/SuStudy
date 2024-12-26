import '/import.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuthをインポート

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  String _email = '';
  String _password = '';
  String _confirmPassword = ''; // 確認用パスワードを保存する変数
  String? _errorMessage; // エラーメッセージを保存するための変数

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
            const Text('メールドレスを登録',
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
            TextFormField(
              decoration: const InputDecoration(labelText: 'パスワードの確認'),
              obscureText: true,
              onChanged: (value) => setState(() => _confirmPassword = value),
            ),
            const Spacer(), // ボタンを画面下部に押し出す
            _buildAuthenticationButton(
              context,
              'サインイン',
              () async {
                setState(() {
                  _errorMessage = null; // エラーが発生する前にリセット
                });

                // パスワードと確認用パスワードが一致しているかチェック
                if (_password != _confirmPassword) {
                  setState(() {
                    _errorMessage = 'パスワードが一致しません。';
                  });
                  return;
                }

                // パスワードが英文字と数字を含むか確認
                if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]+$')
                    .hasMatch(_password)) {
                  setState(() {
                    _errorMessage = 'パスワードには少なくとも英字と数字の両方を含めてください。';
                  });
                  return;
                }

                try {
                  final userCredential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: _email, password: _password);
                  final user = userCredential.user;
                  if (user != null) {
                    print('登録成功: ${user.email}');
                    // Firestoreに登録情報を保存
                    await FirebaseFirestore.instance
                        .collection('Users')
                        .doc(user.uid)
                        .set({
                      'email': user.email,
                      'auth_uid': user.uid,
                    });
                    // InformationRegistrationScreenに遷移
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InformationRegistrationScreen(userId: user.uid),
                    ),
                  );
                  }
                } on FirebaseAuthException catch (e) {
                  // エラーメッセージを設定
                  setState(() {
                    if (e.code == 'email-already-in-use') {
                      _errorMessage = 'このメールアドレスは既に使用されています。';
                    } else if (e.code == 'invalid-email') {
                      _errorMessage = '有効なメールアドレスを入力してください。';
                    } else if (e.code == 'weak-password') {
                      _errorMessage = 'パスワードは6文字以上にしてください。';
                    } else {
                      _errorMessage = 'エラーが発生しました。もう一度お試しください。';
                    }
                  });
                } catch (e) {
                  setState(() {
                    _errorMessage = '予期しないエラーが発生しました。';
                  });
                  print('登録エラー: $e');
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

