import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TimelineScreen extends StatefulWidget {
  @override
  _TimelineScreenState createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  List<Map<String, dynamic>> _timelinePosts = []; // タイムラインの投稿リスト
  bool _isLoading = true;
  String? _currentUserId; // 現在のユーザーID

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
    _fetchTimelinePosts();
  }

  // 現在のユーザーIDを取得
  Future<void> _fetchCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });
    }
  }

  // Timelineコレクションから投稿を取得し、関連するユーザー情報を取得
  Future<void> _fetchTimelinePosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final timelineSnapshot = await FirebaseFirestore.instance
          .collection('Timeline')
          .orderBy('createdAt', descending: true)
          .get();

      final List<Future<Map<String, dynamic>?>> postFutures =
          timelineSnapshot.docs.map((postDoc) async {
        final postData = postDoc.data();

        final userSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('auth_uid', isEqualTo: postData['user_id'])
            .limit(1)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          final userData = userSnapshot.docs.first.data();

          return {
            'post_id': postDoc.id,
            'description': postData['description'],
            'user_name': userData['user_name'],
            'user_id': userData['user_id'],
            'createdAt': postData['createdAt'],
            'like_count': postData['like_count'],
            'is_liked': await _checkIfLiked(postDoc.id),
          };
        }
        return null;
      }).toList();

      final posts = await Future.wait(postFutures);

      setState(() {
        _timelinePosts =
            posts.where((post) => post != null).cast<Map<String, dynamic>>().toList();
        _isLoading = false;
      });
    } catch (e) {
      print('タイムラインデータの取得中にエラーが発生しました: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 投稿がいいねされているか確認
  Future<bool> _checkIfLiked(String postId) async {
    if (_currentUserId == null) return false;

    final likeDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(_currentUserId)
        .collection('post_timeline_ids')
        .doc(postId)
        .get();

    return likeDoc.exists && likeDoc.data()?['is_liked'] == true;
  }

  // いいねボタンが押された時の処理
Future<void> _toggleLike(String postId, bool isLiked, int currentLikeCount) async {
  if (_currentUserId == null) return;

  try {
    final postRef = FirebaseFirestore.instance.collection('Timeline').doc(postId);
    final userLikeRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(_currentUserId)
        .collection('post_timeline_ids')
        .doc(postId);

    // Timeline ドキュメントの投稿データを取得
    final postSnapshot = await postRef.get();
    if (!postSnapshot.exists) return;

    final postData = postSnapshot.data();
    final postOwnerId = postData?['user_id']; // 投稿したユーザーのID

    if (postOwnerId == null) return;

    // 投稿したユーザーのサブコレクションの該当ドキュメント参照
    final userPostRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(postOwnerId)
        .collection('posts')
        .doc(postId);

    if (isLiked) {
      // いいねを解除
      await postRef.update({'like_count': currentLikeCount - 1});
      await userPostRef.update({'like_count': FieldValue.increment(-1)});
      await userLikeRef.set({'is_liked': false});
    } else {
      // いいねを追加
      await postRef.update({'like_count': currentLikeCount + 1});
      await userPostRef.update({'like_count': FieldValue.increment(1)});
      await userLikeRef.set({'is_liked': true});
    }

    setState(() {
      final post = _timelinePosts.firstWhere((element) => element['post_id'] == postId);
      post['is_liked'] = !isLiked;
      post['like_count'] = isLiked ? currentLikeCount - 1 : currentLikeCount + 1;
    });
  } catch (e) {
    print('いいね処理中にエラーが発生しました: $e');
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _timelinePosts.isEmpty
              ? Center(child: Text('投稿がありません'))
              : ListView.builder(
                  itemCount: _timelinePosts.length,
                  itemBuilder: (context, index) {
                    final post = _timelinePosts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 27,
                                      backgroundColor: Colors.grey[200],
                                      child: Text(
                                        post['user_name'] != null
                                            ? post['user_name'][0]
                                            : '?',
                                        style: TextStyle(
                                          fontSize: 25,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              post['user_name'],
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '@${post['user_id']}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Text(
                                  post['createdAt'] != null
                                      ? (post['createdAt'] as Timestamp)
                                          .toDate()
                                          .toString()
                                      : '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              post['description'],
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    post['is_liked']
                                        ? Icons.thumb_up_alt
                                        : Icons.thumb_up_alt_outlined,
                                    color: post['is_liked']
                                        ? Colors.blue
                                        : Colors.grey,
                                  ),
                                  onPressed: () {
                                    _toggleLike(post['post_id'], post['is_liked'],
                                        post['like_count']);
                                  },
                                ),
                                Text('${post['like_count']}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
