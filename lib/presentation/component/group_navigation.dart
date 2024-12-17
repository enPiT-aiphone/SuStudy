import 'package:flutter/material.dart';
import 'group_control.dart'; // グループ作成画面
import 'group_list.dart'; // グループ一覧画面


class GroupNavigationScreen extends StatelessWidget {
  // コンストラクタを追加
  const GroupNavigationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('グループメニュー'),
        backgroundColor: Color(0xFF0ABAB5),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // グループ作成画面へ遷移
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateGroupScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0ABAB5),
              ),
              child: Text(
                'グループを作成',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // グループ一覧画面へ遷移
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserGroupsScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0ABAB5),
              ),
              child: Text(
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
