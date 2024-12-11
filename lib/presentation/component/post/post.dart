import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/import.dart';

class NewPostScreen extends StatelessWidget {
  final String selectedCategory;
  final VoidCallback? onPostSubmitted; // 投稿完了時のコールバック


  NewPostScreen({
    required this.selectedCategory,
    this.onPostSubmitted});

  @override
  Widget build(BuildContext context) {
    final TextEditingController postController = TextEditingController();

    Future<void> _submitPost(String postContent) async {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ログインしていないため、投稿できません')),
        );
        return;
      }

      try {
        final userDoc = FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid);

        final newPostRef = userDoc.collection('posts').doc();

        final postData = {
          'description': postContent,
          'post_id': newPostRef.id,
          'createdAt': FieldValue.serverTimestamp(),
          'like_count': 0,
          'user_id': currentUser.uid,
          'category': selectedCategory,
        };

        // Usersコレクションに追加
        await newPostRef.set(postData);

        // Timelineコレクションに追加
        await FirebaseFirestore.instance
            .collection('Timeline')
            .doc(newPostRef.id)
            .set(postData);

        if (onPostSubmitted != null) {
          onPostSubmitted!();
        }

        // HomeScreenに戻る
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

    return Scaffold(
      appBar: AppBar(
        title: Text('新規投稿'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            // HomeScreenに戻る
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (route) => false,
            );
          },
        ),
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
                labelText: '投稿内容',
                hintText: 'ここに投稿内容を入力してください',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final postContent = postController.text.trim();
                if (postContent.isNotEmpty) {
                  _submitPost(postContent);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('投稿内容を入力してください')),
                  );
                }
              },
              child: Text('送信'),
            ),
          ],
        ),
      ),
    );
  }
}