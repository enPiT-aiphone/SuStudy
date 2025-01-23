import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/import.dart';

class NewPostScreen extends StatefulWidget {
  final String selectedCategory;
  final VoidCallback? onPostSubmitted;

  const NewPostScreen({
    Key? key,
    required this.selectedCategory,
    this.onPostSubmitted,
  }) : super(key: key);

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
        const SnackBar(content: Text('ログインしていないため、投稿できません')),
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
          const SnackBar(content: Text('ユーザーデータが見つかりません')),
        );
        return;
      }

      final userData = userDoc.data();
      final userId = userData != null && userData['auth_uid'] != null
          ? userData['auth_uid']
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
        'auth_uid': userId,
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
        const SnackBar(content: Text('投稿保存中にエラーが発生しました')),
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
          borderRadius: BorderRadius.circular(20),
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
      // 背景にグラデーション
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.white, // 明るい水色
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar的な上部エリア
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  color: Colors.white10, // 半透明で重ねる
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 閉じるボタン
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black54),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                          (route) => false,
                        );
                      },
                    ),
                    // タイトル
                    const Text(
                      '投稿を作成',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    // 投稿ボタン
                    _buildPostButton(context, '投稿', () {
                      final postContent = postController.text.trim();
                      if (postContent.isNotEmpty) {
                        _submitPost(postContent);
                      }
                    }),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // アイコン + テキスト
                            Row(
                              children: [
                                const Icon(Icons.edit_note, size: 28, color: Color(0xFF0ABAB5)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '今日の気づきや学んだことを投稿してみよう！',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // テキストフィールド
                            TextField(
                              controller: postController,
                              maxLines: 8,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.comment),
                                fillColor: Colors.grey[200],
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                hintText: 'ここに投稿内容を入力してください',
                                hintStyle: TextStyle(color: Colors.grey[500]),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // 選択中のカテゴリを表示（任意）
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '投稿カテゴリ: ${widget.selectedCategory}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // 下部にちょっとしたアピール
                            const Text(
                              'みんなの学びをシェアして、\n相互に刺激を受け合おう！',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
