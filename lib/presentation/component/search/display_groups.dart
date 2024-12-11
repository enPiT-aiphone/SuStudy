import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupDetailsPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  GroupDetailsPage({required this.groupId, required this.groupName});

  @override
  _GroupDetailsPageState createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  bool _isJoined = false;

  @override
  void initState() {
    super.initState();
    _checkIfJoined();
  }

  // グループ参加状態を確認
  Future<void> _checkIfJoined() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    final groupSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserId)
        .collection('groups')
        .doc(widget.groupId)
        .get();

    setState(() {
      _isJoined = groupSnapshot.exists;
    });
  }

  // グループに参加
  Future<void> _joinGroup() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    try {
      final userDoc = FirebaseFirestore.instance.collection('Users').doc(currentUserId);

      if (!_isJoined) {
        // グループをユーザーのサブコレクションに追加
        await userDoc.collection('groups').doc(widget.groupId).set({
          'group_name': widget.groupName,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // グループの参加者数を更新
        final groupDoc = FirebaseFirestore.instance.collection('Groups').doc(widget.groupId);
        await groupDoc.update({
          'member_count': FieldValue.increment(1),
        });

        setState(() {
          _isJoined = true;
        });
      }
    } catch (e) {
      print('グループ参加中にエラーが発生しました: $e');
    }
  }

  // グループ参加をキャンセル
  Future<void> _leaveGroup() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    try {
      final userDoc = FirebaseFirestore.instance.collection('Users').doc(currentUserId);

      if (_isJoined) {
        // ユーザーのサブコレクションからグループを削除
        await userDoc.collection('groups').doc(widget.groupId).delete();

        // グループの参加者数を更新
        final groupDoc = FirebaseFirestore.instance.collection('Groups').doc(widget.groupId);
        await groupDoc.update({
          'member_count': FieldValue.increment(-1),
        });

        setState(() {
          _isJoined = false;
        });
      }
    } catch (e) {
      print('グループ退会中にエラーが発生しました: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        backgroundColor: Color(0xFF0ABAB5),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.groupName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'グループID: ${widget.groupId}',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isJoined ? _leaveGroup : _joinGroup,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isJoined ? Colors.grey : Color(0xFF0ABAB5),
              ),
              child: Text(
                _isJoined ? '参加をキャンセル' : '参加する',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
