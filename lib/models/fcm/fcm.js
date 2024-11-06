// Firebase Admin SDKをインポート
const admin = require('firebase-admin');
// Firebaseプロジェクトのサービスアカウントキーをインポート
const serviceAccount = require('./serviceAccountKey.json'); 

// Firebase Admin SDKの初期化
admin.initializeApp({
  // サービスアカウントキーを使って認証を行い、Firebaseの管理者権限で操作を実行できるようにする
  credential: admin.credential.cert(serviceAccount),
});

// FirestoreからユーザーのFCMトークンを取得し、通知を送信する関数
// - userId: ユーザーのID（Firestoreの`user_id`フィールドで検索）
// - title: 送信する通知のタイトル
// - body: 送信する通知の本文
async function sendNotificationToUser(userId, title, body) {
  try {
    // Firestoreの`Users`コレクションから、指定の`user_id`に一致するドキュメントを検索
    const querySnapshot = await admin.firestore()
      .collection('Users') // `Users`コレクションの参照を取得
      .where('user_id', '==', userId) // `user_id`フィールドが指定したuserIdと一致するドキュメントを検索
      .get(); // クエリを実行して結果を取得

    // ユーザーが見つかった場合の処理
    if (!querySnapshot.empty) {
      // 最初のドキュメント（期待する唯一のユーザードキュメント）の参照を取得
      const userDoc = querySnapshot.docs[0].ref;

      // fcmTokenサブコレクションからトークンのドキュメントを取得
      // `token`というドキュメントにFCMトークンが保存されていると想定
      const tokenDoc = await userDoc.collection('fcmToken').doc('token').get();

      // トークンドキュメントが存在し、かつ`token`フィールドに値があるか確認
      if (tokenDoc.exists && tokenDoc.data().token) {
        // トークンを`registrationToken`として取得
        const registrationToken = tokenDoc.data().token;

        // 送信する通知メッセージの内容を設定
        const message = {
          notification: {
            title: title, // 通知のタイトル
            body: body,   // 通知の本文
          },
          data: {
            additionalData: '通知に含めたい追加データなど', // 任意の追加データ（文字列のみ）
          },
          token: registrationToken, // 通知を送信するターゲットデバイストークン
        };

        // Firebase Messagingを使用してメッセージを送信
        const response = await admin.messaging().send(message);
        console.log('Successfully sent message:', response); // メッセージの送信成功時のログ出力
      } else {
        // トークンが存在しない場合の処理
        console.log(`No FCM token found for user with ID: ${userId}`);
      }
    } else {
      // `user_id`が指定の値に一致するユーザーが見つからない場合の処理
      console.log(`User with user_id ${userId} not found.`);
    }
  } catch (error) {
    // エラーが発生した場合の処理
    console.log('Error sending message:', error);
  }
}

// 通知を送信する対象のユーザーID（Firestoreの`user_id`フィールドで指定）
const userId = 'ASAHIdayo'; // テスト用のユーザーIDを指定
const title = 'テスト通知'; // 通知のタイトルを設定
const body = 'テストのプッシュ通知です'; // 通知の本文を設定

// 関数の呼び出し
sendNotificationToUser(userId, title, body); // 指定したユーザーIDとメッセージ内容で関数を実行
