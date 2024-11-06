import 'dart:async'; // 非同期処理のためのdart:asyncパッケージをインポート
import 'package:flutter/material.dart'; // FlutterのUIコンポーネントのためのパッケージ
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestoreへのアクセスのためのパッケージ

// BadgeViewModelクラスを定義し、ChangeNotifierを継承してリスナーへ通知する機能を持つ
class BadgeViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> _notifications = []; // 通知を保存するリスト
  bool _showBadge = false; // バッジ表示の状態を管理するフラグ
  int _badgeCount = 0; // バッジに表示する未読通知数

  // FirestoreのUsersコレクションの参照を取得（ユーザーの通知データを管理）
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('Users');
  late final StreamSubscription _notificationSubscription; // リアルタイム更新のリスナーを保持する変数

  // コンストラクタ：オブジェクト生成時に通知のリアルタイム監視を開始
  BadgeViewModel() {
    _subscribeToNotifications(); // メソッドを呼び出して監視開始
  }

  // 通知のリアルタイム監視設定：Firestoreからユーザーの通知を監視する
  void _subscribeToNotifications() {
    _notificationSubscription = _usersCollection
        .where('user_id', isEqualTo: 'ASAHIdayo') // ユーザーIDが 'ASAHIdayo' のドキュメントを検索
        .snapshots() // リアルタイムで変更があるたびに更新
        .listen((querySnapshot) { // 変更があればコールバックが呼ばれる
      if (querySnapshot.docs.isNotEmpty) { // 対象のユーザーが存在するかチェック
        final userDocRef = querySnapshot.docs.first.reference; // 対象ユーザーの参照を取得

        // Notificationsコレクションをtimestampで降順ソートして取得
        userDocRef
            .collection('Notifications') // ユーザーの通知サブコレクション
            .orderBy('timestamp', descending: true) // timestampフィールドで最新順にソート
            .snapshots() // 通知データのリアルタイムリスナーを設定
            .listen((snapshot) {
          _notifications = snapshot.docs.map((doc) { // 取得したドキュメントのデータを変換
            return {
              'title': doc['title'] as String? ?? 'No Title', // タイトルを取得し、nullなら 'No Title' を代入
              'body': doc['body'] as String? ?? 'No Body', // 本文を取得し、nullなら 'No Body' を代入
              'isRead': doc['isRead'] as bool? ?? false, // 既読状態を取得（デフォルトはfalse）
              'id': doc.id, // ドキュメントIDを保存
              'timestamp': doc['timestamp'] as Timestamp?, // タイムスタンプを保存
            };
          }).toList(); // リストに変換して _notifications に格納

          // 未読通知のみをカウント
          _badgeCount = _notifications.where((notif) => notif['isRead'] == false).length; // 未読の通知のみを数える
          _showBadge = _badgeCount > 0; // 未読がある場合はバッジ表示フラグをtrueに

          notifyListeners(); // UIへ状態更新を通知
        });
      } else {
        print('User with user_id "ASAHIdayo" not found.'); // ユーザーが見つからない場合のログ出力
      }
    });
  }

  // 通知を追加（titleとbodyの両方を受け取る）
  Future<void> addNotification(String title, String body) async {
    final newNotification = {'title': title, 'body': body, 'isRead': false}; // 通知内容のマップを生成し、未読状態で追加

    _notifications.add(newNotification); // ローカルの通知リストに追加
    _badgeCount += 1; // 未読カウントを増加
    _showBadge = true; // バッジ表示フラグをtrueに

    // Firestoreに新しい通知を追加
    final querySnapshot = await _usersCollection.where('user_id', isEqualTo: 'ASAHIdayo').get(); // ユーザーIDで検索
    if (querySnapshot.docs.isNotEmpty) { // ユーザーが見つかった場合
      final userDocRef = querySnapshot.docs.first.reference; // ユーザーのドキュメント参照を取得
      await userDocRef.collection('Notifications').add({ // サブコレクション 'Notifications' に通知を追加
        'title': title, // 通知のタイトル
        'body': body, // 通知の本文
        'isRead': false, // 既読状態
        'timestamp': FieldValue.serverTimestamp(), // Firestoreサーバーのタイムスタンプ
      });
    } else {
      print('User with user_id "ASAHIdayo" not found.'); // ユーザーが見つからない場合のログ出力
    }

    notifyListeners(); // UIへ状態更新を通知
  }

  // 通知を既読にするメソッド
  Future<void> markNotificationAsRead(String docId) async {
    final querySnapshot = await _usersCollection.where('user_id', isEqualTo: 'ASAHIdayo').get(); // ユーザーIDで検索
    if (querySnapshot.docs.isNotEmpty) { // ユーザーが見つかった場合
      final userDocRef = querySnapshot.docs.first.reference; // ユーザーのドキュメント参照を取得
      final notifDocRef = userDocRef.collection('Notifications').doc(docId); // 通知ドキュメントの参照を取得

      await notifDocRef.update({'isRead': true}); // 通知ドキュメントの 'isRead' フィールドをtrueに更新

      // ローカルリストの通知も更新
      final index = _notifications.indexWhere((notif) => notif['id'] == docId); // 通知のIDを使ってローカルリストからインデックスを取得
      if (index != -1) { // インデックスが見つかった場合
        _notifications[index]['isRead'] = true; // ローカルリストの通知の既読状態を更新
        _badgeCount = _notifications.where((notif) => notif['isRead'] == false).length; // 未読カウントを再計算
        _showBadge = _badgeCount > 0; // バッジの表示状態を更新
        notifyListeners(); // UIへ状態更新を通知
      }
    }
  }

  // リスナーを解除するメソッド（不要時にコールする）
  @override
  void dispose() {
    _notificationSubscription.cancel(); // リアルタイムリスナーを解除
    super.dispose(); // 親クラスのdisposeメソッドを呼び出してリソースを解放
  }

  // バッジ表示フラグのgetter
  bool get showBadge => _showBadge;

  // バッジカウントのgetter
  int get badgeCount => _badgeCount;

  // 通知リストのgetter
  List<Map<String, dynamic>> get notifications => _notifications;

  // バッジを非表示にするメソッド
  void hideBadge() {
    _showBadge = false; // バッジ表示フラグをfalseに設定
    notifyListeners(); // UIへ状態更新を通知
  }
}
