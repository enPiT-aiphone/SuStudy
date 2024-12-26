import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TimelineScreen extends StatefulWidget {
  final String selectedTab;
  final Function(String userId) onUserProfileTap; // コールバック関数を追加


  const TimelineScreen({super.key, required this.selectedTab, required this.onUserProfileTap});

  @override
  _TimelineScreenState createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  final List<Map<String, dynamic>> _timelinePosts = []; // タイムラインの投稿リスト
  bool _isLoading = true;
  String? _currentUserId; // 現在のユーザーID
  List<String> _followingUserIds = []; // フォロー中のユーザーIDリスト
  DocumentSnapshot? _lastDocument; // 最後に読み取ったドキュメント
  bool _isFetchingMore = false;    // データ取得中かどうか
  final int _fetchLimit = 10;      // 一度に読み取る投稿数


  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
    _fetchFollowingUsers();
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

  // フォロー中のユーザーIDを取得
  Future<void> _fetchFollowingUsers() async {
    if (_currentUserId == null) return;

    try {
      final followingSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(_currentUserId)
          .collection('follows')
          .get();

      setState(() {
        _followingUserIds = followingSnapshot.docs
            .map((doc) => doc.id) // ドキュメント名をuser_idとして取得
            .toList();
      });
    } catch (e) {
      print('フォロー中のユーザー取得中にエラーが発生しました: $e');
    }
  }

  // Timelineコレクションから投稿を取得
// Timelineコレクションから投稿を取得
Future<void> _fetchTimelinePosts({bool isFetchingMore = false}) async {
  if (_isFetchingMore) return;

  setState(() {
    _isFetchingMore = true;
    if (!isFetchingMore) _isLoading = true;
  });

  try {
    // クエリ作成
    Query query = FirebaseFirestore.instance
        .collection('Timeline')
        .orderBy('createdAt', descending: true)
        .limit(_fetchLimit);

    if (_lastDocument != null && isFetchingMore) {
      query = query.startAfterDocument(_lastDocument!);
    }

    // クエリを実行
    final timelineSnapshot = await query.get();

    if (timelineSnapshot.docs.isNotEmpty) {
      final List<Map<String, dynamic>> newPosts = [];
      final List<String> userIds = timelineSnapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['auth_uid'] as String)
          .toList();

      // ユーザー情報を一括で取得
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('auth_uid', whereIn: userIds)
          .get();

      final Map<String, Map<String, dynamic>> usersMap = {
        for (var userDoc in usersSnapshot.docs)
          userDoc.data()['auth_uid']: userDoc.data()
      };

      for (var postDoc in timelineSnapshot.docs) {
        final postData = postDoc.data() as Map<String, dynamic>;

        // フォロー中タブの場合、フォローしていないユーザーの投稿を除外
        if (widget.selectedTab == 'フォロー中' &&
            !_followingUserIds.contains(postData['auth_uid'])) {
          continue;
        }

        // ユーザー情報を取得
        final userData = usersMap[postData['auth_uid']];
        if (userData == null) continue;

        newPosts.add({
          'post_id': postDoc.id,
          'description': postData['description'],
          'user_name': userData['user_name'],
          'auth_uid': userData['auth_uid'],
          'user_id': userData['user_id'],
          'createdAt': postData['createdAt'],
          'like_count': postData['like_count'],
          'is_liked': await _checkIfLiked(postDoc.id),
        });
      }

      setState(() {
        _timelinePosts.addAll(newPosts);
        _lastDocument = timelineSnapshot.docs.last; // 最後のドキュメントを更新
        _isFetchingMore = false;
        if (!isFetchingMore) _isLoading = false;
      });
    } else {
      setState(() {
        _isFetchingMore = false;
        if (!isFetchingMore) _isLoading = false;
      });
    }
  } catch (e) {
    print('タイムラインデータの取得中にエラーが発生しました: $e');
    setState(() {
      _isFetchingMore = false;
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
    if (!postSnapshot.exists) {
      print('postSnapshot does not exist for postId: $postId');
      return;
    }

    final postData = postSnapshot.data();
    final userIdInTimeline = postData?['auth_uid'];

    final userPostRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userIdInTimeline)
        .collection('posts')
        .doc(postId);

    if (isLiked) {
      await postRef.update({'like_count': currentLikeCount - 1});
      await userPostRef.update({'like_count': FieldValue.increment(-1)});
      await userLikeRef.set({'is_liked': false});
    } else {
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


  // 時間を人間が読みやすい形式に変換する
  String _timeAgo(Timestamp timestamp) {
    final now = DateTime.now();
    final dateTime = timestamp.toDate();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}秒前';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}時間前';
    } else {
      return '${difference.inDays}日前';
    }
  }

  @override
  void didUpdateWidget(TimelineScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedTab != oldWidget.selectedTab) {
      setState(() {
        _timelinePosts.clear(); // タイムライン投稿をクリア
        _lastDocument = null; // 最後のドキュメントもリセット
      });
      _fetchTimelinePosts(); // 新しいタブに基づいて投稿を再取得
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(valueColor:  AlwaysStoppedAnimation<Color>(Color(0xFF0ABAB5)),))
          : NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent &&
                    !_isFetchingMore) {
                  // スクロール位置が一番下に到達した場合、次の投稿を取得
                  _fetchTimelinePosts(isFetchingMore: true);
                }
                return false;
              },
              child: _timelinePosts.isEmpty
                  ? const Center(child: Text('投稿がありません'))
                  : ListView.separated(
                      itemCount: _timelinePosts.length,
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.grey[300], // 線の色を指定
                        thickness: 1, // 線の太さを指定
                        height: 1, // 線の高さ
                      ),
                      itemBuilder: (context, index) {
                        final post = _timelinePosts[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          // プロフィール表示のコールバックを実行
                                          widget.onUserProfileTap(post['auth_uid']);
                                        },
                                        child: CircleAvatar(
                                          radius: 27,
                                          backgroundColor: Colors.grey[200],
                                          child: Text(
                                            post['user_name'] != null ? post['user_name'][0] : '?',
                                            style: const TextStyle(
                                              fontSize: 25,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                post['user_name'],
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '@${post['user_id']}',
                                                style: const TextStyle(
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
                                        ? _timeAgo(post['createdAt'])
                                        : '',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.only(left: 64.0), // descriptionの位置を調整
                                child: Text(
                                  post['description'],
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      post['is_liked']
                                          ? Icons.thumb_up_alt
                                          : Icons.thumb_up_alt_outlined,
                                      color: post['is_liked'] ? Colors.blue : Colors.grey,
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
                        );
                      },
                    ),
            ),
    );
  }
}