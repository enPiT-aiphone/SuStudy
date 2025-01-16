import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupDetailsPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupDetailsPage(
      {super.key, required this.groupId, required this.groupName});

  @override
  _GroupDetailsPageState createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  bool _isJoined = false;
  bool _isGrouped = false;

  @override
  void initState() {
    super.initState();
    _checkIfJoined();
    _checkIfGrouped();
  }

  // 表示グループへの参加状態を確認
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

  // 参加グループ有無を確認
  Future<void> _checkIfGrouped() async {
    final isGrouped = await checkIfGrouped();
    setState(() {
      _isGrouped = isGrouped;
    });
  }

  Future<bool> checkIfGrouped() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;

    final groupSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.uid)
        .collection('groups')
        .get();

    setState(() {
      _isGrouped = groupSnapshot.docs.isNotEmpty;
    });
    
    return groupSnapshot.docs.isNotEmpty;
  }

  // グループに参加
  Future<void> _joinGroup() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    try {
      final userDoc =
          FirebaseFirestore.instance.collection('Users').doc(currentUserId);
      final userSnapshot = await userDoc.get();
      final userName = userSnapshot['user_name'];

      if (!_isJoined) {
        // グループをユーザーのサブコレクションに追加
        await userDoc.collection('groups').doc(widget.groupId).set({
          'groupId': widget.groupId,
          'groupName': widget.groupName,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // グループの参加者情報を更新
        final groupDoc =
            FirebaseFirestore.instance.collection('Groups').doc(widget.groupId);
        await groupDoc.collection('members_id').doc().set({
          'auth_uid': currentUserId,
          'userName': userName,
          'joined_at': FieldValue.serverTimestamp(),
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
      final userDoc =
          FirebaseFirestore.instance.collection('Users').doc(currentUserId);

      if (_isJoined) {
        // ユーザーのサブコレクションからグループを削除
        await userDoc.collection('groups').doc(widget.groupId).delete();

        // グループの参加者数を更新
        final groupDoc =
            FirebaseFirestore.instance.collection('Groups').doc(widget.groupId);
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
        backgroundColor: const Color(0xFF0ABAB5),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.groupName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'グループID: ${widget.groupId}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            if (!_isGrouped)
            ElevatedButton(
              onPressed: _isJoined ? _leaveGroup : _joinGroup,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isJoined ? Colors.grey : const Color(0xFF0ABAB5),
              ),
              child: Text(
                _isJoined ? '参加をキャンセル' : '参加する',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
