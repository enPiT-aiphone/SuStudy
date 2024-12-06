import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDetailsPage extends StatefulWidget {
  final String userId;
  final String userName;

  UserDetailsPage({required this.userId, required this.userName});

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  bool _isFollowed = false;

  @override
  void initState() {
    super.initState();
    _checkIfFollowed();
  }

  // フォロー状態を確認
  Future<void> _checkIfFollowed() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    final followSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserId)
        .collection('follows')
        .where('user_id', isEqualTo: widget.userId)
        .get();

    setState(() {
      _isFollowed = followSnapshot.docs.isNotEmpty;
    });
  }

  // フォロー処理
  Future<void> _followUser() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    try {
      final currentUserDoc =
          FirebaseFirestore.instance.collection('Users').doc(currentUserId);

    // 自分のuser_idを取得
    final currentUserSnapshot = await currentUserDoc.get();
    final currentUserUserId = currentUserSnapshot.data()?['user_id'];
    if (currentUserUserId == null) {
      print('自分のuser_idが見つかりません');
      return;
    }

      // フォローするユーザーのドキュメントを検索
      final targetUserQuery = await FirebaseFirestore.instance
          .collection('Users')
          .where('user_id', isEqualTo: widget.userId)
          .limit(1)
          .get();

      if (targetUserQuery.docs.isEmpty) {
        print('フォローする対象ユーザーが見つかりません');
        return;
      }

      final targetUserDoc = targetUserQuery.docs.first.reference;

      if (!_isFollowed) {
        // 自分のfollowsサブコレクションに追加
        await currentUserDoc.collection('follows').doc(widget.userId).set({
          'timestamp': FieldValue.serverTimestamp(),
          'user_id': widget.userId,
        });

        // 自分のfollow_countを+1
        await currentUserDoc.update({
          'follow_count': FieldValue.increment(1),
        });

        // 対象ユーザーのfollower_countを+1
        await targetUserDoc.update({
          'follower_count': FieldValue.increment(1),
        });

        // フォローされる側のfollowersサブコレクションに自分のuser_idを追加
        await targetUserDoc.collection('followers').doc(currentUserUserId).set({
          'timestamp': FieldValue.serverTimestamp(),
          'user_id': currentUserUserId,
        });

        setState(() {
          _isFollowed = true;
        });

      }
    } catch (e) {
      print('フォロー中にエラーが発生しました: $e');
    }
  }

  // フォロー解除処理
  Future<void> _unfollowUser() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    try {
      final currentUserDoc =
          FirebaseFirestore.instance.collection('Users').doc(currentUserId);

      // フォロー解除するユーザーのドキュメントを検索
      final targetUserQuery = await FirebaseFirestore.instance
          .collection('Users')
          .where('user_id', isEqualTo: widget.userId)
          .limit(1)
          .get();

      if (targetUserQuery.docs.isEmpty) {
        print('フォロー解除する対象ユーザーが見つかりません');
        return;
      }

      final targetUserDoc = targetUserQuery.docs.first.reference;

      if (_isFollowed) {
    
        // 自分のfollow_countを-1
        await currentUserDoc.update({
          'follow_count': FieldValue.increment(-1),
        });

        // 対象ユーザーのfollower_countを-1
        await targetUserDoc.update({
          'follower_count': FieldValue.increment(-1),
        });

        setState(() {
          _isFollowed = false;
        });

      }
    } catch (e) {
      print('フォロー解除中にエラーが発生しました: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              child: Text(
                widget.userName[0].toUpperCase(),
                style: TextStyle(fontSize: 40),
              ),
            ),
            SizedBox(height: 20),
            Text(
              widget.userName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '@${widget.userId}',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isFollowed ? _unfollowUser : _followUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFollowed ? Colors.grey : Color(0xFF0ABAB5),
              ),
              child: Text(
                _isFollowed ? 'フォロー解除' : 'フォローする',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
