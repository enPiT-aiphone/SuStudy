import 'package:flutter/material.dart';

class NewPostScreen extends StatelessWidget {
  final VoidCallback? onPostSubmitted; // 投稿完了時のコールバック

  NewPostScreen({this.onPostSubmitted});

  @override
  Widget build(BuildContext context) {
    final TextEditingController postController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('新規投稿'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
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
                final postContent = postController.text;
                if (postContent.isNotEmpty) {
                  // 投稿の送信処理を実行
                  print('投稿内容: $postContent');
                  if (onPostSubmitted != null) {
                    onPostSubmitted!();
                  }
                  Navigator.of(context).pop();
                } else {
                  // 入力が空の場合のエラーメッセージを表示
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