import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateGroupScreen extends StatefulWidget {
  final Function(String groupId, String groupName)? onGroupCreated;

  CreateGroupScreen({Key? key, this.onGroupCreated}) : super(key: key);

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  bool _isCreating = false;

  Future<void> _createGroup() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // ユーザーがログインしていない場合
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ログインが必要です')),
      );
      return;
    }

    final groupName = _groupNameController.text.trim();
    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('グループ名を入力してください')),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      // Firestoreのサブコレクション "groups" に新しいグループを作成
      final groupId = FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .collection('groups')
          .doc()
          .id; // 新しいグループのIDを生成

      final groupData = {
        'groupId': groupId,
        'groupName': groupName,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': currentUser.uid,
      };

      // ユーザーのサブコレクションに追加
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .collection('groups')
          .doc(groupId)
          .set(groupData);

      // トップレベルの "Groups" コレクションにも追加
      await FirebaseFirestore.instance
          .collection('Groups')
          .doc(groupId)
          .set(groupData);

      // コールバック関数が指定されている場合、呼び出す
      if (widget.onGroupCreated != null) {
        widget.onGroupCreated!(groupId, groupName);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('グループ "$groupName" を作成しました')),
      );

      // フォームをリセット
      _groupNameController.clear();

      // 作成後に画面を閉じる
      Navigator.pop(context);
    } catch (e) {
      print('グループ作成エラー: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('グループ作成に失敗しました')),
      );
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('グループ作成'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                labelText: 'グループ名',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            _isCreating
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _createGroup,
                    child: Text('グループを作成'),
                  ),
          ],
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class CreateGroupScreen extends StatefulWidget {
//   final Function(String groupId, String groupName)? onGroupCreated;

//   CreateGroupScreen({Key? key, this.onGroupCreated}) : super(key: key);

//   @override
//   _CreateGroupScreenState createState() => _CreateGroupScreenState();
// }

// class _CreateGroupScreenState extends State<CreateGroupScreen> {
//   final TextEditingController _groupNameController = TextEditingController();
//   bool _isCreating = false;

//   Future<void> _createGroup() async {
//     final currentUser = FirebaseAuth.instance.currentUser;

//     if (currentUser == null) {
//       // ユーザーがログインしていない場合
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('ログインが必要です')),
//       );
//       return;
//     }

//     final groupName = _groupNameController.text.trim();
//     if (groupName.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('グループ名を入力してください')),
//       );
//       return;
//     }

//     setState(() {
//       _isCreating = true;
//     });

//     try {
//       // Firestoreのサブコレクション "groups" に新しいグループを作成
//       final groupId = FirebaseFirestore.instance
//           .collection('Users')
//           .doc(currentUser.uid)
//           .collection('groups')
//           .doc()
//           .id; // 新しいグループのIDを生成

//       await FirebaseFirestore.instance
//           .collection('Users')
//           .doc(currentUser.uid)
//           .collection('groups')
//           .doc(groupId)
//           .set({
//         'groupId': groupId,
//         'groupName': groupName,
//         'createdAt': FieldValue.serverTimestamp(),
//         'createdBy': currentUser.uid,
//       });

//       // コールバック関数が指定されている場合、呼び出す
//       if (widget.onGroupCreated != null) {
//         widget.onGroupCreated!(groupId, groupName);
//       }

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('グループ "$groupName" を作成しました')),
//       );

//       // フォームをリセット
//       _groupNameController.clear();

//       // 作成後に画面を閉じる
//       Navigator.pop(context);
//     } catch (e) {
//       print('グループ作成エラー: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('グループ作成に失敗しました')),
//       );
//     } finally {
//       setState(() {
//         _isCreating = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('グループ作成'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _groupNameController,
//               decoration: InputDecoration(
//                 labelText: 'グループ名',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16),
//             _isCreating
//                 ? CircularProgressIndicator()
//                 : ElevatedButton(
//                     onPressed: _createGroup,
//                     child: Text('グループを作成'),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }