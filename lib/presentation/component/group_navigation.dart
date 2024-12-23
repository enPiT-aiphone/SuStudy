import 'package:flutter/material.dart';
import 'group_control.dart'; // グループ作成画面
import 'group_list.dart'; // グループ一覧画面


class GroupNavigationScreen extends StatelessWidget {
  final VoidCallback onGroupMenuTap; // グループ一覧表示コールバック
  final VoidCallback onCreateGroupTap; // グループ作成コールバック

  // コンストラクタでコールバックを受け取る
  const GroupNavigationScreen({
    super.key,
    required this.onGroupMenuTap,
    required this.onCreateGroupTap,
  });

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
            ElevatedButton(
              onPressed: onCreateGroupTap, // グループ作成コールバックを呼び出し
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0ABAB5),
              ),
              child: const Text(
                'グループを作成',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onGroupMenuTap, // グループ一覧コールバックを呼び出し
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0ABAB5),
              ),
              child: const Text(
                'グループ一覧を見る',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
