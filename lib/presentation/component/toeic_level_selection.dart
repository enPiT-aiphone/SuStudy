import '/import.dart';  // 必要なパッケージをインポート

// TOEICレベル選択画面を表示するためのStatelessWidget
class TOEICLevelSelection extends StatelessWidget {
  const TOEICLevelSelection({Key? key}) : super(key: key);  // コンストラクタ

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0ABAB5),  // AppBarの背景色を0xFF0ABAB5に設定
        title: Row(
          children: const [
            // アプリのタイトル「SuStudy,」を表示
            Text(
              'SuStudy, ',
              style: TextStyle(
                fontSize: 20,  // フォントサイズを20に設定
                fontWeight: FontWeight.bold,  // 太字で表示
                color: Colors.white,  // 文字色を白に設定
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 画面の上半分にタイトルを表示
          Expanded(
            child: Center(
              // タイトル「TOEICのレベルを選んでください」を中央に配置
              child: const Text(
                'TOEICのレベルを選んでください',
                style: TextStyle(fontSize: 20),  // フォントサイズを20に設定
                textAlign: TextAlign.center,  // テキストを中央揃えに設定
              ),
            ),
          ),
          // 画面の下半分にレベル選択ボタンを配置
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),  // 全体に16pxの余白を追加
              child: Column(
                children: [
                  // レベル選択ボタンを画面サイズに応じて自動調整する
                  Flexible(
                    // 「300点レベル」ボタン
                    child: _buildLevelButton(context, 'up_to_300', '300点レベル'),
                  ),
                  Flexible(
                    // 「500点レベル」ボタン
                    child: _buildLevelButton(context, 'up_to_500', '500点レベル'),
                  ),
                  Flexible(
                    // 「700点レベル」ボタン
                    child: _buildLevelButton(context, 'up_to_700', '700点レベル'),
                  ),
                  Flexible(
                    // 「900点レベル」ボタン
                    child: _buildLevelButton(context, 'up_to_900', '900点レベル'),
                  ),
                  Flexible(
                    // 「990点レベル」ボタン
                    child: _buildLevelButton(context, 'up_to_990', '990点レベル'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // レベル選択ボタンを生成するメソッド
  Widget _buildLevelButton(BuildContext context, String level, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),  // ボタンの上下に10pxの余白を追加
      child: GestureDetector(
        onTap: () {
          // ボタンが押されたときに、対応するTOEICWordQuiz画面に遷移
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TOEICWordQuiz(level: level),  // 各レベルに応じたクイズ画面を表示
            ),
          );
        },
        child: Container(
          alignment: Alignment.center,  // ボタン内のテキストを中央に配置
          decoration: BoxDecoration(
            color: Colors.white,  // ボタンの背景色を白に設定
            border: Border.all(color: const Color(0xFF0ABAB5)),  // ボタンの境界線の色を設定
            borderRadius: BorderRadius.circular(10),  // 角を10px丸くする
          ),
          child: Text(
            label,  // ボタンのラベル
            style: const TextStyle(
              color: Color(0xFF0ABAB5),  // テキストの色を設定
              fontSize: 18,  // フォントサイズを18に設定
            ),
          ),
        ),
      ),
    );
  }
}
