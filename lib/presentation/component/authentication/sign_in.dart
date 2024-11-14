import '/import.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuthをインポート

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  String _email = '';
  String _password = '';

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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                      'user_id': user.uid,
                    });
                    // InformationRegistrationScreenに遷移
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InformationRegistrationScreen(
                          userId: user.uid,
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  print('登録エラー: $e');
                }
              },
              child: Text('サインイン'),
            ),
          ],
        ),
      ),
    );
  }
}
