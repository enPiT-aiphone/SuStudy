import 'dart:async'; // 非同期処理のためのdart:asyncパッケージをインポート
import 'package:flutter/material.dart'; // FlutterのUIコンポーネントのためのパッケージ
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestoreへのアクセスのためのパッケージ
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authへのアクセスのためのパッケージ

// BadgeViewModelクラスを定義し、ChangeNotifierを継承してリスナーへ通知する機能を持つ
class BadgeViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> _notifications = []; // 通知を保存するリスト
  bool _showBadge = false; // バッジ表示の状態を管理するフラグ
  int _badgeCount = 0; // バッジに表示する未読通知数

  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Authインスタンス
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('Users'); // FirestoreのUsersコレクション参照
  StreamSubscription? _notificationSubscription; // リアルタイム更新のリスナーを保持する変数

  // コンストラクタ：オブジェクト生成時に通知のリアルタイム監視を開始
  BadgeViewModel() {
    _subscribeToNotifications(); // メソッドを呼び出して監視開始
  }

  // 通知のリアルタイム監視設定：Firestoreからユーザーの通知を監視する
  void _subscribeToNotifications() {
    final User? currentUser = _auth.currentUser; // 現在ログインしているユーザーを取得
    if (currentUser != null) {
      String userId = currentUser.uid; // ログイン中のユーザーIDを取得

      _notificationSubscription = _usersCollection
          .where('auth_uid', isEqualTo: userId) // 現在のユーザーIDを使用してドキュメントを検索
          .snapshots() // リアルタイムで変更があるたびに更新
          .listen((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) { // 対象のユーザーが存在するかチェック
          final userDocRef = querySnapshot.docs.first.reference; // 対象ユーザーの参照を取得

          // Notificationsコレクションをtimestampで降順ソートして取得
          userDocRef
              .collection('Notifications') // ユーザーの通知サブコレクション
              .orderBy('timestamp', descending: true) // timestampフィールドで最新順にソート
              .snapshots() // 通知データのリアルタイムリスナーを設定
              .listen((snapshot) {
            _notifications = snapshot.docs.map((doc) {
              return {
                'title': doc['title'] as String? ?? 'No Title',
                'body': doc['body'] as String? ?? 'No Body',
                'isRead': doc['isRead'] as bool? ?? false,
                'id': doc.id,
                'timestamp': doc['timestamp'] as Timestamp?,
              };
            }).toList();

            // 未読通知のみをカウント
            _badgeCount = _notifications.where((notif) => notif['isRead'] == false).length;
            _showBadge = _badgeCount > 0;

            notifyListeners(); // UIへ状態更新を通知
          });
        } else {
          print('User with auth_uid "$userId" not found.');
        }
      });
    } else {
      print('No user is currently logged in.');
    }
  }

  // 通知を追加（titleとbodyの両方を受け取る）
Future<void> addNotification(String title, String body, {String? level}) async {
  final User? currentUser = _auth.currentUser;
  if (currentUser != null) {
    String userId = currentUser.uid;

    final newNotification = {
      'title': title,
      'body': body,
      'isRead': false,
      'level': level, // レベル情報を追加
    };

    _notifications.add(newNotification);
    _badgeCount += 1;
    _showBadge = true;

    final querySnapshot = await _usersCollection.where('', isEqualTo: userId).get();
    if (querySnapshot.docs.isNotEmpty) {
      final userDocRef = querySnapshot.docs.first.reference;
      await userDocRef.collection('Notifications').add({
        'title': title,
        'body': body,
        'isRead': false,
        'level': level, // Firestoreにもレベル情報を保存
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      print('User with auth_uid "$userId" not found.');
    }

    notifyListeners();
  }
}


  // 通知を既読にするメソッド
  Future<void> markNotificationAsRead(String docId) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      String userId = currentUser.uid;

      final querySnapshot = await _usersCollection.where('auth_uid', isEqualTo: userId).get();
      if (querySnapshot.docs.isNotEmpty) {
        final userDocRef = querySnapshot.docs.first.reference;
        final notifDocRef = userDocRef.collection('Notifications').doc(docId);

        await notifDocRef.update({'isRead': true});

        // ローカルリストの通知も更新
        final index = _notifications.indexWhere((notif) => notif['id'] == docId);
        if (index != -1) {
          _notifications[index]['isRead'] = true;
          _badgeCount = _notifications.where((notif) => notif['isRead'] == false).length;
          _showBadge = _badgeCount > 0;
          notifyListeners();
        }
      }
    }
  }

  // リスナーを解除するメソッド（不要時にコールする）
  @override
  void dispose() {
    _notificationSubscription?.cancel(); // リアルタイムリスナーを解除
    super.dispose();
  }

  // バッジ表示フラグのgetter
  bool get showBadge => _showBadge;

  // バッジカウントのgetter
  int get badgeCount => _badgeCount;

  // 通知リストのgetter
  List<Map<String, dynamic>> get notifications => _notifications;

  // バッジを非表示にするメソッド
  void hideBadge() {
    _showBadge = false;
    notifyListeners();
  }
}

