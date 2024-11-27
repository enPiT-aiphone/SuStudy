import '/import.dart';

class AuthenticationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0ABAB5), Color.fromARGB(255, 255, 255, 255)], // グラデーションの色設定
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double screenHeight = constraints.maxHeight;

            return Stack(
              children: [
                // 「SuStudy,」を画面の40%の位置に配置
                Positioned(
                  top: screenHeight * 0.4 - 30, // 40%の位置に配置（-30は文字の高さ調整）
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'SuStudy,',
                      style: TextStyle(
                        fontSize: 60, // フォントサイズを大きく設定
                        color: Colors.white, // 文字色を白に設定
                      ),
                    ),
                  ),
                ),
                // 新規アカウント登録ボタンを画面の80%の位置に配置
                Positioned(
                  top: screenHeight * 0.8 - 30, // 80%の位置に配置（-30はボタンの高さ調整）
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _buildAuthenticationButton(
                      context,
                      '新規アカウント登録',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignInScreen()), // SignInScreen に遷移
                        );
                      },
                    ),
                  ),
                ),
                // すでにアカウントをお持ちの方テキストをその下に配置
                Positioned(
                  top: screenHeight * 0.85, // 80%より少し下に配置
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LogInScreen()),
                        );
                      },
                      child: Text(
                        'すでにアカウントをお持ちの方',
                        style: TextStyle(
                          color: Colors.grey, // テキストの色をグレーに設定
                          fontSize: 16, // フォントサイズを設定
                          decoration: TextDecoration.underline, // 下線を引く
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ボタンを生成するウィジェット
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
//