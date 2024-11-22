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
// - level: クイズや通知内容に関連するレベル
async function sendNotificationToUser(userId, title, body, level) {
  try {
    const querySnapshot = await admin.firestore()
      .collection('Users')
      .where('user_id', '==', userId)
      .get();

    if (!querySnapshot.empty) {
      const userDoc = querySnapshot.docs[0].ref;

      // fcmTokenを取得
      const tokenDoc = await userDoc.collection('fcmToken').doc('token').get();

      if (tokenDoc.exists && tokenDoc.data().token) {
        const registrationToken = tokenDoc.data().token;

        // 通知を送信
        const message = {
          notification: {
            title: title,
            body: body,
          },
          data: {
            level: level, // level をデータに含める
            additionalData: '通知に含めたい追加データなど',
          },
          token: registrationToken,
        };

        const response = await admin.messaging().send(message);
        console.log('Successfully sent message:', response);

        // Firestoreに通知を保存
        await userDoc.collection('Notifications').add({
          title: title,
          body: body,
          level: level, // Firestoreにも保存
          isRead: false,
          timestamp: admin.firestore.FieldValue.serverTimestamp(), // サーバータイムスタンプ
        });
        console.log('Notification saved to Firestore');
      } else {
        console.log(`No FCM token found for user with ID: ${userId}`);
      }
    } else {
      console.log(`User with user_id ${userId} not found.`);
    }
  } catch (error) {
    console.log('Error sending message:', error);
  }
}

// 通知を送信する対象のユーザーID（Firestoreの`user_id`フィールドで指定）
const userId = 'yzWtpexbc1fRbYPzIgEJIvT0qtg1'; // テスト用のユーザーIDを指定
const title = 'テスト通知'; // 通知のタイトルを設定
const body = 'テストのプッシュ通知です'; // 通知の本文を設定
const level = 'up_to_500'; // レベルを指定

// 関数の呼び出し
sendNotificationToUser(userId, title, body, level); // 指定したユーザーIDとメッセージ内容で関数を実行
