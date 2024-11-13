// 各種必要なパッケージをインポート
import 'import.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // kIsWebを使用してWebかどうかを判定
import 'package:firebase_auth/firebase_auth.dart';
void main() async {
  // Flutterエンジンの初期化（asyncを用いるためにawaitが必要）
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebaseアプリの初期化（プロジェクト設定に基づいた設定を指定）
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Firebase Messagingのセットアップ関数を呼び出し、通知設定の初期化
  await setupFirebaseMessaging();

  // マルチプロバイダーを設定し、アプリ全体をラップ
  runApp(
    MultiProvider(
      providers: [
        // ChangeNotifierProviderを使用してBadgeViewModelを提供
        ChangeNotifierProvider(create: (_) => BadgeViewModel()),
      ],
      // アプリのルートとしてMyAppを指定
      child: MyApp(),
    ),
  );
}

// Firebase Messagingのセットアップ関数
Future<void> setupFirebaseMessaging() async {
  final messagingInstance = FirebaseMessaging.instance; // Firebase Messagingインスタンスの取得

  // 初回トークンの取得（ユーザーごとのデバイストークン）
  String? fcmToken = await messagingInstance.getToken();
  if (fcmToken != null) {
    // 取得したトークンをFirestoreのサブコレクションに保存
    await saveTokenToSubcollection(fcmToken);
  }

  // トークンが更新された場合に再保存するようリスナーを設定
  messagingInstance.onTokenRefresh.listen(saveTokenToSubcollection);

  // フォアグラウンドでメッセージ受信時の処理
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    final notification = message.notification; // 通知メッセージの情報を取得
    final android = message.notification?.android; // Android向けの通知設定を取得

    // WebでないかつAndroidプラットフォームでローカル通知を表示
    if (!kIsWeb && Platform.isAndroid) {
      final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      await flutterLocalNotificationsPlugin.show(
        0, // 通知ID
        notification?.title, // 通知タイトル
        notification?.body, // 通知内容
        NotificationDetails(
          android: AndroidNotificationDetails(
            'default_notification_channel', // チャンネルID
            'プッシュ通知のチャンネル名', // チャンネル名
            importance: Importance.max, // 通知の重要度設定
            icon: android?.smallIcon, // アイコン
          ),
        ),
        payload: json.encode(message.data), // 通知ペイロード（データ）をJSONでエンコード
      );
    }

    // BadgeViewModelに通知を追加する処理
    final context = navigatorKey.currentContext; // NavigatorKeyを使用して現在のコンテキストを取得
    if (context != null) {
      // ProviderでBadgeViewModelを取得し、通知内容を更新
      final badgeViewModel = Provider.of<BadgeViewModel>(context, listen: false);
      final notificationTitle = notification?.title ?? '通知'; // 通知タイトル
      final notificationBody = notification?.body ?? '本文がありません'; // 通知内容
      badgeViewModel.addNotification(notificationTitle, notificationBody); // 通知をViewModelに追加
    }
  });
}

// FirestoreのUsersコレクション内の特定ユーザーにfcmTokenサブコレクションを作成し、トークンを保存する関数
Future<void> saveTokenToSubcollection(String token) async {
  // Usersコレクションから特定のユーザーID（user_idがASAHIdayoのユーザー）を取得
  final querySnapshot = await FirebaseFirestore.instance
      .collection('Users')
      .where('user_id', isEqualTo: 'ASAHIdayo')
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    // ユーザードキュメントの参照を取得
    final userDoc = querySnapshot.docs.first.reference;
    // fcmTokenという名前のサブコレクションにトークンを保存する
    await userDoc.collection('fcmToken').doc('token').set({
      'token': token, // トークン情報を保存
      'timestamp': FieldValue.serverTimestamp(), // サーバータイムスタンプを追加
    });
  } else {
    print('ユーザーが見つかりませんでした'); // 該当ユーザーが存在しない場合
  }
}

// アプリ起動時の初期通知設定
Future<void> _initNotification() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin(); // ローカル通知のプラグインインスタンス

  // バックグラウンドで通知がタップされた場合にリッスン
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    // バックグラウンドからアプリが起動されたときの処理
  });

  // ローカル通知の初期化設定
  flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'), // Androidのアイコン設定
      iOS: DarwinInitializationSettings(), // iOSの設定
    ),
    onDidReceiveNotificationResponse: (details) {
      // 通知がタップされたときの処理
      if (details.payload != null) {
        // ペイロード（データ）をデコードしてログに出力
        final payloadMap = json.decode(details.payload!) as Map<String, dynamic>;
        debugPrint(payloadMap.toString());
      }
    },
  );
}

// グローバルなNavigatorKeyの設定（どこからでもNavigatorを使って画面遷移を管理するため）
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// アプリケーションのルートウィジェット
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: navigatorKey, // NavigatorKeyを設定
//       //home: TOEICLevelSelection(), // アプリのホーム画面を指定
//       home: MyHomePage(),
//     );
//   }
// }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthChecker(),  // 認証状態を監視
    );
  }
}

class AuthChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // 認証状態を監視
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          // ユーザーがログインしている場合、TOEICLevelSelection画面に遷移
          return TOEICLevelSelection();
        } else {
          // ログインしていない場合、ログイン画面を表示
          return MyHomePage();
        }
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

//新しく追加（ログイン）
class _MyHomePageState extends State<MyHomePage> {
  // 入力したメールアドレス・パスワード
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // 1行目 メールアドレス入力用テキストフィールド
              TextFormField(
                decoration: const InputDecoration(labelText: 'メールアドレス'),
                onChanged: (String value) {
                  setState(() {
                    _email = value;
                  });
                },
              ),
              // 2行目 パスワード入力用テキストフィールド
              TextFormField(
                decoration: const InputDecoration(labelText: 'パスワード'),
                obscureText: true,
                onChanged: (String value) {
                  setState(() {
                    _password = value;
                  });
                },
              ),
              
              ElevatedButton(
                 child: const Text('ユーザ登録'),
                 onPressed: () async {
                   try {
                      final User? user = (await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                      email: _email, password: _password))
                      .user;

      if (user != null) {
        print("ユーザ登録しました ${user.email} , ${user.uid}");
        
        // Firestoreにユーザー情報を保存
        await FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
          'email': user.email,
          "user_id" : user.uid,
          //'createdAt': FieldValue.serverTimestamp(),
          // 必要に応じて他のフィールドを追加
        });
        
        print("Firestoreにユーザー情報を保存しました");
      }
    } catch (e) {
      print(e);
    }
  },
),
              // 4行目 ログインボタン
              ElevatedButton(
                child: const Text('ログイン'),
                onPressed: () async {
                  try {
                    // メール/パスワードでログイン
                    final User? user = (await FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                                email: _email, password: _password))
                        .user;
                    if (user != null)
                      print("ログインしました　${user.email} , ${user.uid}");
                  } catch (e) {
                    print(e);
                  }
                },
              ),
              // 5行目 パスワードリセット登録ボタン
              ElevatedButton(
                  child: const Text('パスワードリセット'),
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance
                          .sendPasswordResetEmail(email: _email);
                      print("パスワードリセット用のメールを送信しました");
                    } catch (e) {
                      print(e);
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}