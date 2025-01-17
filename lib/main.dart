// 各種必要なパッケージをインポート
import 'import.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // kIsWebを使用してWebかどうかを判定
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuthをインポート


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

  // // 初回トークンの取得（ユーザーごとのデバイストークン）
  // String? fcmToken = await messagingInstance.getToken();
  // if (fcmToken != null) {
  //   // 取得したトークンをFirestoreのサブコレクションに保存
  //   await saveTokenToSubcollection(fcmToken);
  // }

  // // トークンが更新された場合に再保存するようリスナーを設定
  // messagingInstance.onTokenRefresh.listen(saveTokenToSubcollection);

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
  // FirebaseAuthを使用して現在ログイン中のユーザーIDを取得
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    print('ログインしていません');
    return;
  }

  // Usersコレクションから特定のユーザーID（現在ログイン中のユーザー）を取得
  final querySnapshot = await FirebaseFirestore.instance
      .collection('Users')
      .where('auth_uid', isEqualTo: userId)
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
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        fontFamily: 'NotoSansJP',
        primarySwatch: Colors.blue,
      ),
      home: AuthChecker(), // AuthCheckerがアプリの初期画面を決定する
    );
  }
}

// 認証状態を監視して適切な画面を表示するウィジェット
class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // 認証状態を監視
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(valueColor:  AlwaysStoppedAnimation<Color>(Color(0xFF0ABAB5)),));
        }

        if (snapshot.hasData) {
          // ユーザーがログインしている場合、ホーム画面に遷移
          //ここでLogin_historyに追加
           // ユーザーがログインしている場合、userId を取得
          final userId = snapshot.data?.uid; // snapshotからuidを取得
          return HomeScreen();
        } else {
          // ログインしていない場合、認証選択画面を表示
          return AuthenticationScreen();
        }
      },
    );
  }
}
