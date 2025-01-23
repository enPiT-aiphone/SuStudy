import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// ※ あなたの環境に合わせて import 調整
import 'search/user_profile_screen.dart';

class ReplyScreen extends StatefulWidget {
  final Map<String, dynamic> post; // 返信する元の投稿
  final VoidCallback? onBack;
  final Function(String userId) onUserProfileRequested;

  const ReplyScreen({
    Key? key,
    required this.post,
    this.onBack,
    required this.onUserProfileRequested,
  }) : super(key: key);

  @override
  _ReplyScreenState createState() => _ReplyScreenState();
}

class _ReplyScreenState extends State<ReplyScreen> {
  // 返信テキスト入力コントローラ
  late TextEditingController _replyController;

  // 返信一覧ストリーム
  late Stream<List<Map<String, dynamic>>> _repliesStream;

  // 返信一覧をスクロールするためのコントローラ
  final ScrollController _replyListController = ScrollController();

  String? _currentUserId;
  bool _isFollowed = false; // 投稿者をフォローしているかどうか
  bool _isLiked   = false; // 投稿にいいねしているかどうか
  int  _likeCount = 0;     // 投稿のいいね数

  // ユーザードキュメントをキャッシュするMap
  final Map<String, Map<String, dynamic>?> _userCache = {};

  @override
  void initState() {
    super.initState();
    _replyController = TextEditingController();

    final user = FirebaseAuth.instance.currentUser;
    _currentUserId = user?.uid;

    // 返信一覧ストリーム
    _repliesStream = FirebaseFirestore.instance
        .collection('Timeline')
        .doc(widget.post['post_id'])
        .collection('replies')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList());

    // 投稿の初期データ
    _isLiked   = widget.post['is_liked'] ?? false;
    _likeCount = widget.post['like_count'] ?? 0;

    // 投稿者をフォロー中かどうか確認
    _checkIfFollowed(widget.post['auth_uid']);
  }

  @override
  void dispose() {
    _replyController.dispose();
    _replyListController.dispose(); // ScrollController を破棄
    super.dispose();
  }

  //--------------------------------------------------------------------------
  // Firestore からユーザードキュメントを取得してキャッシュする
  //--------------------------------------------------------------------------
  Future<Map<String, dynamic>?> _fetchUserDoc(String authUid) async {
    if (_userCache.containsKey(authUid)) {
      return _userCache[authUid]; // キャッシュがあればそれを返す
    }
    final docSnap = await FirebaseFirestore.instance
        .collection('Users')
        .doc(authUid)
        .get();
    if (!docSnap.exists) {
      _userCache[authUid] = null;
      return null;
    }
    final data = docSnap.data();
    _userCache[authUid] = data;
    return data;
  }

  //--------------------------------------------------------------------------
  // フォロー状態
  //--------------------------------------------------------------------------
  Future<void> _checkIfFollowed(String targetAuthUid) async {
    if (_currentUserId == null) return;
    try {
      final followSnap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(_currentUserId)
          .collection('follows')
          .where('auth_uid', isEqualTo: targetAuthUid)
          .get();
      setState(() {
        _isFollowed = followSnap.docs.isNotEmpty;
      });
    } catch (e) {
      print('フォロー状態確認エラー: $e');
    }
  }

  Future<void> _followUser(String targetAuthUid) async {
    if (_currentUserId == null) return;
    final currentUserDoc = FirebaseFirestore.instance
        .collection('Users')
        .doc(_currentUserId);
    final targetUserDoc  = FirebaseFirestore.instance
        .collection('Users')
        .doc(targetAuthUid);

    try {
      if (!_isFollowed) {
        // 自分の follows サブコレクションに追加
        await currentUserDoc.collection('follows').doc(targetAuthUid).set({
          'auth_uid': targetAuthUid,
          'timestamp': FieldValue.serverTimestamp(),
          'is_followed': true,
        });
        // 自分の follow_count +1
        await currentUserDoc.update({
          'follow_count': FieldValue.increment(1),
        });
        // 相手の follower_count +1
        await targetUserDoc.update({
          'follower_count': FieldValue.increment(1),
        });
        // 相手の followers サブコレクションに自分を追加
        await targetUserDoc.collection('followers').doc(_currentUserId).set({
          'auth_uid': _currentUserId,
          'timestamp': FieldValue.serverTimestamp(),
          'is_isfollowed': true,
        });
        setState(() {
          _isFollowed = true;
        });
      }
    } catch (e) {
      print('フォローに失敗しました: $e');
    }
  }

  Future<void> _unfollowUser(String targetAuthUid) async {
    if (_currentUserId == null) return;
    final currentUserDoc = FirebaseFirestore.instance
        .collection('Users')
        .doc(_currentUserId);
    final targetUserDoc  = FirebaseFirestore.instance
        .collection('Users')
        .doc(targetAuthUid);

    try {
      if (_isFollowed) {
        await currentUserDoc
            .collection('follows')
            .doc(targetAuthUid)
            .set({'is_followed': false}, SetOptions(merge: true));
        // 自分の follow_count -1
        await currentUserDoc.update({
          'follow_count': FieldValue.increment(-1),
        });
        // 相手の follower_count -1
        await targetUserDoc.update({
          'follower_count': FieldValue.increment(-1),
        });
        // 相手の followers サブコレクションを更新
        await targetUserDoc
            .collection('followers')
            .doc(_currentUserId)
            .set({'is_isfollowed': false}, SetOptions(merge: true));
        setState(() {
          _isFollowed = false;
        });
      }
    } catch (e) {
      print('フォロー解除に失敗しました: $e');
    }
  }

  //--------------------------------------------------------------------------
  // いいね
  //--------------------------------------------------------------------------
  Future<void> _toggleLike() async {
    if (_currentUserId == null) return;
    final postId   = widget.post['post_id'];
    final isLiked  = _isLiked;
    final likeCnt  = _likeCount;

    final postRef = FirebaseFirestore.instance.collection('Timeline').doc(postId);
    final postSnap = await postRef.get();
    if (!postSnap.exists) {
      print('投稿が見つかりません');
      return;
    }
    final userLikeRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(_currentUserId)
        .collection('post_timeline_ids')
        .doc(postId);

    final postData    = postSnap.data();
    final authUid     = postData?['auth_uid'];
    final userPostRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(authUid)
        .collection('posts')
        .doc(postId);

    if (isLiked) {
      // いいね解除
      await postRef.update({'like_count': likeCnt - 1});
      await userPostRef.update({'like_count': FieldValue.increment(-1)});
      await userLikeRef.set({'is_liked': false}, SetOptions(merge: true));
      setState(() {
        _isLiked = false;
        _likeCount = likeCnt - 1;
      });
    } else {
      // いいね追加
      await postRef.update({'like_count': likeCnt + 1});
      await userPostRef.update({'like_count': FieldValue.increment(1)});
      await userLikeRef.set({'is_liked': true}, SetOptions(merge: true));
      setState(() {
        _isLiked = true;
        _likeCount = likeCnt + 1;
      });
    }
  }

  //--------------------------------------------------------------------------
  // 返信を送信
  //--------------------------------------------------------------------------
  Future<void> _sendReply(String replyContent) async {
    if (_currentUserId == null) return;
    final postId = widget.post['post_id'];

    try {
      final postDoc = FirebaseFirestore.instance.collection('Timeline').doc(postId);
      final postSnapshot = await postDoc.get();
      if (!postSnapshot.exists) {
        print('指定された投稿が存在しません');
        return;
      }

      final postData = postSnapshot.data()!;
      final userDoc  = FirebaseFirestore.instance.collection('Users').doc(_currentUserId);
      final userSnap = await userDoc.get();
      final userData = userSnap.data() ?? {};

      final newUserReplyRef = userDoc.collection('replies').doc();
      final newPostReplyRef = postDoc.collection('replies').doc();

      final replyDataForUser = {
        'description': replyContent,
        'post_id': newUserReplyRef.id,
        'reply_id': postId,
        'createdAt': FieldValue.serverTimestamp(),
        'like_count': 0,
        'auth_uid': userData['auth_uid'],
        'category': postData['category'],
      };

      final replyDataForPost = {
        'description': replyContent,
        'post_id': newPostReplyRef.id,
        'createdAt': FieldValue.serverTimestamp(),
        'like_count': 0,
        'auth_uid': userData['auth_uid'],
        'category': postData['category'],
      };

      await newUserReplyRef.set(replyDataForUser);
      await newPostReplyRef.set(replyDataForPost);

      // リプライしたというフラグ
      await userDoc
          .collection('post_timeline_ids')
          .doc(postId)
          .set({'is_reply': true}, SetOptions(merge: true));

      _replyController.clear();
      print('返信を送信しました');
    } catch (e) {
      print('返信の送信に失敗しました: $e');
    }
  }

  //--------------------------------------------------------------------------
  // UI
  //--------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    // ★ ScrollControllerを個別に用意 + Scrollbar
    final ScrollController _replyScrollController = ScrollController();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(30.0),
        child: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: Column(
        children: [
          // 元の投稿の表示
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: FutureBuilder<Map<String, dynamic>?>(
              future: _fetchUserDoc(post['auth_uid']),
              builder: (context, snapshot) {
                final userData = snapshot.data;
                final userName = userData?['user_name'] ?? post['user_name'] ?? 'Unknown';
                final userId   = userData?['user_id']   ?? post['user_id']   ?? 'user_id';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 上部: Avatar + userName + @userId + フォローボタン
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar
                        GestureDetector(
                          onTap: () => widget.onUserProfileRequested(post['auth_uid']),
                          child: CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.grey[300],
                            child: Text(
                              userName.isNotEmpty ? userName[0] : '?',
                              style: const TextStyle(fontSize: 24, color: Colors.black),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // ユーザー名 + ID
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () => widget.onUserProfileRequested(post['auth_uid']),
                                child: Text(
                                  userName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => widget.onUserProfileRequested(post['auth_uid']),
                                child: Text(
                                  '@$userId',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // フォローボタン（自分自身でなければ）
                        if (_currentUserId != null && _currentUserId != post['auth_uid'])
                          ElevatedButton(
                            onPressed: _isFollowed
                                ? () => _unfollowUser(post['auth_uid'])
                                : () => _followUser(post['auth_uid']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isFollowed ? Colors.grey : const Color(0xFF0ABAB5),
                            ),
                            child: Text(
                              _isFollowed ? 'フォロー解除' : 'フォロー',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // 投稿の文章
                    Text(
                      post['description'] ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                    // いいねボタン & いいね数
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(
                            _isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                            color: _isLiked ? Colors.blue : Colors.grey,
                          ),
                          onPressed: _toggleLike,
                        ),
                        Text('$_likeCount'),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),

          const Divider(thickness: 1),

          // ★ Scrollbar + ListView
          Expanded(
            child: Scrollbar(
              controller: _replyScrollController,
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _repliesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final replies = snapshot.data ?? [];
                  return ListView.separated(
                    controller: _replyScrollController, // 同じScrollControllerを使う
                    itemCount: replies.length,
                    separatorBuilder: (context, index) => Divider(
                      color: Colors.grey[300],
                      thickness: 1,
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      return _buildReplyItem(replies[index]);
                    },
                  );
                },
              ),
            ),
          ),

          // 返信入力フォーム
          _buildReplyInput(context),
        ],
      ),
    );
  }

  //--------------------------------------------------------------------------
  // 返信アイテムのUI
  //--------------------------------------------------------------------------
  Widget _buildReplyItem(Map<String, dynamic> reply) {
    final createdAt = reply['createdAt'] as Timestamp?;
    final authUid   = reply['auth_uid'] ?? '';

    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchUserDoc(authUid),
      builder: (context, snapshot) {
        final userData = snapshot.data;
        final userName = userData?['user_name'] ?? 'Unknown';
        final userId   = userData?['user_id']   ?? 'user_id';
        final description = reply['description'] ?? '';

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              GestureDetector(
                onTap: () => widget.onUserProfileRequested(reply['auth_uid']),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[200],
                  child: Text(
                    userName.isNotEmpty ? userName[0] : '?',
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // ユーザー名 + ID + 本文
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ユーザー名 + userId + 投稿日時（右寄せ）
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => widget.onUserProfileRequested(reply['auth_uid']),
                              child: Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => widget.onUserProfileRequested(reply['auth_uid']),
                              child: Text(
                                '@${userId.length > 10 ? userId.substring(0, 10) + '...' : userId}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        if (createdAt != null)
                          Text(
                            _timeAgo(createdAt),
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // 本文
                    Text(description, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  //--------------------------------------------------------------------------
  // 返信入力部分
  //--------------------------------------------------------------------------
  Widget _buildReplyInput(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // キーボード分の余白を確保
        ),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              // 入力欄
              Expanded(
                child: TextField(
                  controller: _replyController,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: '返信を入力...',
                    hintStyle: const TextStyle(fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 返信ボタン
              ElevatedButton(
                onPressed: () {
                  final replyContent = _replyController.text.trim();
                  if (replyContent.isNotEmpty) {
                    _sendReply(replyContent);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0ABAB5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                child: const Text(
                  '返信',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //--------------------------------------------------------------------------
  // 日時フォーマット
  //--------------------------------------------------------------------------
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
