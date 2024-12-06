// Firebase Admin SDKをインポート
const admin = require('firebase-admin');
// Firebaseプロジェクトのサービスアカウントキーをインポート
const serviceAccount = require('./serviceAccountKey.json'); 

// Firebase Admin SDKの初期化
admin.initializeApp({
  // サービスアカウントキーを使って認証を行い、Firebaseの管理者権限で操作を実行できるようにする
  credential: admin.credential.cert(serviceAccount),
});

// Firestoreからすべてのユーザーを取得し、通知を送信する関数
// - title: 送信する通知のタイトル
// - body: 送信する通知の本文
// - level: クイズや通知内容に関連するレベル
async function sendNotificationToAllUsers(title, body, level) {
  try {
    // Usersコレクションの全ユーザーを取得
    const usersSnapshot = await admin.firestore().collection('Users').get();

    if (!usersSnapshot.empty) {
      const notificationPromises = [];

      usersSnapshot.forEach(async (userDoc) => {
        const userRef = userDoc.ref;

        try {
          // fcmTokenを取得
          const tokenDoc = await userRef.collection('fcmToken').doc('token').get();

          if (tokenDoc.exists && tokenDoc.data().token) {
            const registrationToken = tokenDoc.data().token;

            // 通知メッセージを準備
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

            // 通知を送信
            const response = admin.messaging().send(message);
            console.log(`Successfully sent message to ${userDoc.id}:`, response);

            // Firestoreに通知を保存
            const saveNotification = userRef.collection('Notifications').add({
              title: title,
              body: body,
              level: level, // Firestoreにも保存
              isRead: false,
              timestamp: admin.firestore.FieldValue.serverTimestamp(), // サーバータイムスタンプ
            });
            notificationPromises.push(saveNotification);
          } else {
            console.log(`No FCM token found for user with ID: ${userDoc.id}`);
          }
        } catch (error) {
          console.log(`Error sending notification to user with ID ${userDoc.id}:`, error);
        }
      });

      // 全ての通知保存処理が完了するのを待つ
      await Promise.all(notificationPromises);
      console.log('Notifications sent and saved for all users.');
    } else {
      console.log('No users found in the Users collection.');
    }
  } catch (error) {
    console.log('Error sending notifications to all users:', error);
  }
}

// 通知内容を設定
const title = 'ログイン問題'; // 通知のタイトル
const body = '本日のログイン問題の時間です'; // 通知の本文
const level = 'up_to_500'; // レベルを指定

// 関数の呼び出し
sendNotificationToAllUsers(title, body, level);
