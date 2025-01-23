import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReplyScreen extends StatefulWidget {
  final Map<String, dynamic> post; // 返信する元の投稿

  const ReplyScreen({Key? key, required this.post}) : super(key: key);

  @override
  _ReplyScreenState createState() => _ReplyScreenState();
}

class _ReplyScreenState extends State<ReplyScreen> {
  late TextEditingController _replyController;
  late Stream<List<Map<String, dynamic>>> _repliesStream;
  String? _currentUserId; // 現在のユーザーID

  @override
  void initState() {
    super.initState();
    _replyController = TextEditingController();
    _repliesStream = FirebaseFirestore.instance
        .collection('Timeline')
        .doc(widget.post['post_id'])
        .collection('replies')
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList());
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

    Future<void> _sendReply(String postId, String replyContent) async {
      try {
        final postDoc = FirebaseFirestore.instance.collection('Timeline').doc(postId);
        final postSnapshot = await postDoc.get();
        
        if (!postSnapshot.exists) {
          print('指定された投稿が存在しません');
          return;
        }

        final postData = postSnapshot.data()!;
        final userDoc = FirebaseFirestore.instance.collection('Users').doc(_currentUserId);
        final userData = (await userDoc.get()).data()!;

        final newReplyRef = userDoc.collection('replies').doc();
        final newRepliedRef = postDoc.collection('replies').doc();

        final replyData = {
          'description': replyContent,
          'post_id': newReplyRef.id,
          'reply_id': postId,
          'createdAt': FieldValue.serverTimestamp(),
          'like_count': 0,
          'auth_uid': userData['auth_uid'],
          'category': postData['category'],
        };

        final repliedData = {
          'description': replyContent,
          'post_id': newRepliedRef.id,
          'createdAt': FieldValue.serverTimestamp(),
          'like_count': 0,
          'auth_uid': userData['auth_uid'],
          'category': postData['category'],
        };

        await newReplyRef.set(replyData);
        await newRepliedRef.set(repliedData);
        await userDoc.collection('post_timeline_ids').doc(postId).set({'is_reply':true}, SetOptions(merge: true));


        print('返信を送信しました');
      } catch (e) {
        print('返信の送信に失敗しました: $e');
        }
      }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('返信 - ${widget.post['user_name']}'),
      ),
      body: Column(
        children: [
          // タップした投稿の表示
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '元の投稿:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  widget.post['description'],
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),

          // 返信リスト
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _repliesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('返信はありません'));
                }

                final replies = snapshot.data!;
                return ListView.builder(
                  itemCount: replies.length,
                  itemBuilder: (context, index) {
                    final reply = replies[index];
                    return ListTile(
                      title: Text(reply['description']),
                      subtitle: Text(reply['auth_uid']),
                      trailing: Text(_timeAgo(reply['createdAt'])),
                    );
                  },
                );
              },
            ),
          ),

          // 新しい返信を入力するテキストフィールド
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _replyController,
              decoration: InputDecoration(
                labelText: '返信内容を入力してください',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ),

          // 返信送信ボタン
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                final replyContent = _replyController.text;
                if (replyContent.isNotEmpty) {
                  _sendReply(widget.post['post_id'], replyContent);
                  _replyController.clear(); // テキストフィールドをクリア
                }
              },
              child: Text('返信'),
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(Timestamp timestamp) {
    final time = timestamp.toDate();
    final difference = DateTime.now().difference(time);
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}年前';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}ヶ月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}日前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分前';
    } else {
      return 'たった今';
    }
  }
}
