import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/import.dart';

class NewPostScreen extends StatefulWidget {
  final String selectedCategory;
  final VoidCallback? onPostSubmitted;

  NewPostScreen({
    required this.selectedCategory,
    this.onPostSubmitted,
  });

  @override
  _NewPostScreenState createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final TextEditingController postController = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    // テキスト入力の変更を監視
    postController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    postController.dispose(); // コントローラを破棄
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      // 入力内容が空ならボタンを無効に、それ以外なら有効に
      _isButtonEnabled = postController.text.trim().isNotEmpty;
    });
  }

  Future<void> _submitPost(String postContent) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ログインしていないため、投稿できません')),
      );
      return;
    }

    try {
      // ユーザードキュメントを取得
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ユーザーデータが見つかりません')),
        );
        return;
      }

      final userData = userDoc.data();
      final userId = userData != null && userData['user_id'] != null
          ? userData['user_id']
          : currentUser.uid;

      final newPostRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .collection('posts')
          .doc();

      final postData = {
        'description': postContent,
        'post_id': newPostRef.id,
        'createdAt': FieldValue.serverTimestamp(),
        'like_count': 0,
        'user_id': userId,
        'category': widget.selectedCategory,
      };

      await newPostRef.set(postData);
      await FirebaseFirestore.instance
          .collection('Timeline')
          .doc(newPostRef.id)
          .set(postData);

      if (widget.onPostSubmitted != null) {
        widget.onPostSubmitted!();
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      print('投稿保存中にエラーが発生しました: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('投稿保存中にエラーが発生しました')),
      );
    }
  }

  Widget _buildPostButton(BuildContext context, String label, VoidCallback onPressed) {
    return InkWell(
      onTap: _isButtonEnabled ? onPressed : null, // ボタンが無効ならタップ不可
      child: Container(
        height: 35,
        width: 80,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        decoration: BoxDecoration(
          color: _isButtonEnabled
              ? const Color(0xFF0ABAB5) // 有効時の色
              : Colors.white, // 無効時の色
          border: Border.all(
              color: _isButtonEnabled
                  ? const Color(0xFF0ABAB5)
                  : Colors.grey), // ボーダー色
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: _isButtonEnabled ? Colors.white : Colors.black54, // テキスト色
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('記録なし投稿'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (route) => false,
            );
          },
        ),
        actions: [
          _buildPostButton(context, '投稿', () {
            final postContent = postController.text.trim();
            if (postContent.isNotEmpty) {
              _submitPost(postContent);
            }
          }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: postController,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'ここに投稿内容を入力してください',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
