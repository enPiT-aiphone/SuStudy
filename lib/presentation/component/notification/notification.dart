import '../../../import.dart'; // 必要なパッケージをインポートする

// NotificationPageクラスを定義し、StatelessWidgetを継承して静的なUIを作成
class NotificationPage extends StatelessWidget {
  final List<Map<String, dynamic>> notifications; // 通知のリストを保持するフィールド
  final Function(String) onNotificationTap; // 通知がタップされた際の処理を受け取るコールバック関数

  // コンストラクタ：必須の引数として通知リストとコールバック関数を受け取る
  const NotificationPage({super.key, required this.notifications, required this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return notifications.isNotEmpty // 通知リストにアイテムがあるかをチェック
        ? SizedBox(
            height: 250, // リストの高さを設定
            child: ListView.builder( // 通知アイテムをリスト形式で表示するListView.builderを使用
              physics: const AlwaysScrollableScrollPhysics(), // スクロール時にバウンスエフェクトを適用
              itemCount: notifications.length, // 通知リストのアイテム数を指定
              itemBuilder: (context, index) { // 各アイテムを生成するためのビルダー関数
                final notification = notifications[index]; // 現在の通知アイテムを取得
                final isRead = notification['isRead'] as bool; // 'isRead'フィールドで既読状態を判定

                return ListTile( // 通知アイテムを表示するListTileウィジェットを作成
                  leading: const Icon(Icons.notification_important), // アイコンを表示
                  title: Text(
                    notification['title'] ?? 'No Title', // タイトルを表示、nullの場合はデフォルト値
                    style: TextStyle(
                      color: isRead ? Colors.grey : Colors.black, // 既読ならグレー、未読なら黒色
                    ),
                  ),
                  subtitle: Text(
                    notification['body'] ?? 'No Body', // 本文を表示、nullの場合はデフォルト値
                    style: TextStyle(
                      color: isRead ? Colors.grey : Colors.black, // 既読ならグレー、未読なら黒色
                    ),
                  ),
                  onTap: () {
                    // 通知がタップされたときにコールバック関数を呼び出し、通知を既読にする
                    onNotificationTap(notification['id']); // 通知のIDを渡して既読処理を実行
                  },
                );
              },
            ),
          )
        : const Center( // 通知リストが空の場合
            child: Text('通知はありません',
            style: TextStyle(
                      fontSize: 14
              ),
             ), // メッセージを表示
          );
  }
}
