import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'group_control.dart'; // グループ作成画面
import 'group_list.dart'; // グループ一覧画面

class GroupNavigationScreen extends StatefulWidget {
  final VoidCallback onGroupMenuTap; // グループ一覧表示コールバック
  final VoidCallback onCreateGroupTap; // グループ作成コールバック

  // コンストラクタでコールバックを受け取る
  const GroupNavigationScreen({
    super.key,
    required this.onGroupMenuTap,
    required this.onCreateGroupTap,
  });

  @override
  _GroupNavigationScreenState createState() => _GroupNavigationScreenState();
}

class _GroupNavigationScreenState extends State<GroupNavigationScreen> {
  bool _isGrouped = false;

  @override
  void initState() {
    super.initState();
    _checkIfGrouped();
  }

  Future<void> _checkIfGrouped() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final groupSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.uid)
        .collection('groups')
        .get();

    setState(() {
      _isGrouped = groupSnapshot.docs.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('グループメニュー'),
        backgroundColor: const Color(0xFF0ABAB5),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isGrouped)
              ElevatedButton(
                onPressed: widget.onCreateGroupTap, // グループ作成コールバックを呼び出し
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0ABAB5),
                ),
                child: const Text('グループを作成'),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: widget.onGroupMenuTap, // グループ一覧表示コールバックを呼び出し
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0ABAB5),
              ),
              child: const Text('グループ一覧'),
            ),
          ],
        ),
      ),
    );
  }
}