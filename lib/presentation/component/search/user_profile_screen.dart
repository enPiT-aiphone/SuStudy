import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_user_profile.dart';
import 'follow_follower_list.dart';
import '../user_view_model.dart';
import 'package:provider/provider.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final VoidCallback? onBack; // 戻るボタンが押された時の処理

  const UserProfileScreen({
    super.key,
    required this.userId,
    this.onBack,
  });

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  // -----------------------------
  // 状態管理
  // -----------------------------
  String? _currentUserId;             // 現在のユーザーID
  List<Map<String, dynamic>> _posts = []; // 投稿データ
  bool _isFollowed = false;           // フォロー状態
  String _userName = '';
  String _bio = '';
  String _occupation = '';
  String _subOccupation = '';

  // ScrollController を追加
  final ScrollController _userProfileScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
    _loadUserPosts();
    _checkIfFollowed();
  }

  @override
  void dispose() {
    // ScrollController を解放
    _userProfileScrollController.dispose();
    super.dispose();
  }

  // -----------------------------
  // データ取得系
  // -----------------------------
  Future<void> _fetchCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() => _currentUserId = user.uid);
    }
  }

  Future<void> _checkIfFollowed() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    final followSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserId)
        .collection('follows')
        .where('auth_uid', isEqualTo: widget.userId)
        .get();

    setState(() {
      _isFollowed = followSnapshot.docs.isNotEmpty;
    });
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        // following_subjects が null の場合は空リストに置き換え
        return {
          ...userData,
          'following_subjects': userData['following_subjects'] ?? [],
        };
      } else {
        print('ユーザードキュメントが見つかりません: ${widget.userId}');
        return {};
      }
    } catch (e) {
      print('ユーザーデータ取得エラー: $e');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> _fetchUserPosts() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return [];

    try {
      final postsSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .get();

      // 各投稿に対し、いいね状態も含めてまとめる
      final futures = postsSnapshot.docs.map((postDoc) async {
        final data = postDoc.data();
        final isLiked = await _checkIfLiked(postDoc.id);

        return {
          'id': postDoc.id,
          'description': data['description'] ?? '内容なし',
          'like_count': data['like_count'] ?? 0,
          'createdAt': data['createdAt'],
          'is_liked': isLiked,
        };
      }).toList();

      final results = await Future.wait(futures);
      return results.cast<Map<String, dynamic>>();
    } catch (e) {
      print('投稿データ取得中にエラー: $e');
      return [];
    }
  }

  Future<void> _loadUserPosts() async {
    final posts = await _fetchUserPosts();
    setState(() {
      _posts = posts;
    });
  }

  Future<bool> _checkIfLiked(String postId) async {
    if (_currentUserId == null) return false;
    try {
      final likeDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(_currentUserId)
          .collection('post_timeline_ids')
          .doc(postId)
          .get();

      return likeDoc.exists && (likeDoc.data()?['is_liked'] ?? false);
    } catch (e) {
      print('いいね確認エラー: $e');
      return false;
    }
  }

  // -----------------------------
  // アクション系
  // -----------------------------
  Future<void> _followUser() async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return;

    try {
      final currentUserDoc = FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUserId);
      final targetUserDoc = FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId);

      if (!_isFollowed) {
        // 自分の follows に追加
        await currentUserDoc.collection('follows').doc(widget.userId).set({
          'timestamp': FieldValue.serverTimestamp(),
          'auth_uid': widget.userId,
          'is_followed': true,
        });
        // follow_count++
        await currentUserDoc.update({
          'follow_count': FieldValue.increment(1),
        });
        // 相手の follower_count++
        await targetUserDoc.update({
          'follower_count': FieldValue.increment(1),
        });
        // 相手の followers に追加
        await targetUserDoc.collection('followers').doc(currentUserId).set({
          'timestamp': FieldValue.serverTimestamp(),
          'auth_uid': currentUserId,
          'is_isfollowed': true,
        });

        setState(() {
          _isFollowed = true;
        });
      }
    } catch (e) {
      print('フォロー中にエラー: $e');
    }
  }

  Future<void> _unfollowUser() async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return;

    try {
      final currentUserDoc = FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUserId);
      final targetUserDoc = FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId);

      if (_isFollowed) {
        // 自分の follows を更新
        await currentUserDoc.collection('follows').doc(widget.userId).set({
          'is_followed': false,
        }, SetOptions(merge: true));
        // follow_count--
        await currentUserDoc.update({
          'follow_count': FieldValue.increment(-1),
        });
        // 相手の follower_count--
        await targetUserDoc.update({
          'follower_count': FieldValue.increment(-1),
        });
        // 相手の followers を更新
        await targetUserDoc.collection('followers').doc(currentUserId).set({
          'is_isfollowed': false,
        }, SetOptions(merge: true));

        setState(() {
          _isFollowed = false;
        });
      }
    } catch (e) {
      print('フォロー解除中にエラー: $e');
    }
  }

  Future<void> _toggleLike(String postId, bool isLiked, int currentLikeCount) async {
    if (_currentUserId == null) return;
    try {
      final postRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .collection('posts')
          .doc(postId);

      final timelinePostRef = FirebaseFirestore.instance
          .collection('Timeline')
          .doc(postId);

      final userLikeRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(_currentUserId)
          .collection('post_timeline_ids')
          .doc(postId);

      if (isLiked) {
        // いいね解除
        await postRef.update({'like_count': currentLikeCount - 1});
        await timelinePostRef.update({'like_count': FieldValue.increment(-1)});
        await userLikeRef.set({'is_liked': false}, SetOptions(merge: true));
      } else {
        // いいね付与
        await postRef.update({'like_count': currentLikeCount + 1});
        await timelinePostRef.update({'like_count': FieldValue.increment(1)});
        await userLikeRef.set({'is_liked': true}, SetOptions(merge: true));
      }

      setState(() {});
    } catch (e) {
      print('いいねの切り替えエラー: $e');
    }
  }

  Future<void> _loadUserData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        setState(() {
          _userName = data?['user_name'] ?? '';
          _bio = data?['bio'] ?? '';
          _occupation = data?['occupation'] ?? '';
          _subOccupation = data?['sub_occupation'] ?? '';
        });
      }
    } catch (e) {
      print('ユーザーデータの再読み込み中にエラーが発生しました: $e');
    }
  }

  // -----------------------------
  // UI
  // -----------------------------
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

  void _showFollowFollowerList(BuildContext context, String targetUserId, int initialTabIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: FollowFollowerListScreen(
            targetUserId: targetUserId,
            initialTabIndex: initialTabIndex,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = context.watch<UserViewModel>();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(30.0),
        child: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBack ?? () {},
          ),
        ),
      ),

      // ▼ Scrollbar + SingleChildScrollView + controller
      body: Scrollbar(
        controller: _userProfileScrollController,
        thumbVisibility: true, // スクロールバーを常に見せたい場合
        interactive: false,    // もしドラッグ操作を無効化したい場合に設定
        child: SingleChildScrollView(
          controller: _userProfileScrollController,
          child: FutureBuilder(
            future: Future.wait([
              _fetchUserData(),
              _fetchUserPosts(),
            ]),
            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0ABAB5)),
                    ),
                  ),
                );
              }

              final userData = snapshot.data![0] as Map<String, dynamic>;
              final userPosts = snapshot.data![1] as List<Map<String, dynamic>>;

              if (userData.isEmpty) {
                return const Center(child: Text('ユーザーが見つかりませんでした。'));
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ------------------------
                  // ヘッダー (ユーザー情報)
                  // ------------------------
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // アバター
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF0ABAB5), width: 1.0),
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            child: Text(
                              userData['user_name'] != null &&
                                      userData['user_name'].isNotEmpty
                                  ? userData['user_name'][0]
                                  : '?',
                              style: const TextStyle(
                                fontSize: 30,
                                color: Color(0xFF0ABAB5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // ユーザー名 + プロフィール操作
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userData['user_name'] ?? '不明',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                children: [
                                  Text(
                                    '@${userData['user_id']}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color.fromARGB(179, 160, 160, 160),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (_currentUserId != null)
                                if (userData['auth_uid'] == _currentUserId)
                                  OutlinedButton(
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditProfileScreen(),
                                        ),
                                      );
                                      if (result == true) {
                                        _loadUserData();
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.grey),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 20),
                                    ),
                                    child: const Text(
                                      'プロフィール編集',
                                      style: TextStyle(color: Colors.black, fontSize: 14),
                                    ),
                                  )
                                else
                                  ElevatedButton(
                                    onPressed: _isFollowed
                                        ? _unfollowUser
                                        : _followUser,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isFollowed
                                          ? Colors.grey
                                          : Color(0xFF0ABAB5),
                                    ),
                                    child: Text(
                                      _isFollowed ? 'フォロー解除' : 'フォローする',
                                      style: const TextStyle(color: Colors.white, fontSize: 14),
                                    ),
                                  ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ------------------------
                  // プロフィール詳細
                  // ------------------------
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (userData['bio'] != null && userData['bio'].isNotEmpty) ...[
                          Text(
                            userData['bio'],
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 5),
                        ],
                        // フォロワー/フォロー中
                        Row(
                          children: [
                            const Text(
                              'フォロワー: ',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color.fromARGB(179, 100, 100, 100),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _showFollowFollowerList(context, widget.userId, 0);
                              },
                              child: Text(
                                '${userData['follower_count'] ?? 0}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            const Text(
                              'フォロー中: ',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color.fromARGB(179, 100, 100, 100),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _showFollowFollowerList(context, widget.userId, 1);
                              },
                              child: Text(
                                '${userData['follow_count'] ?? 0}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        // フォロー中の教科
                        if (userData['following_subjects'] != null &&
                            (userData['following_subjects'] as List).isNotEmpty) ...[
                          const Text(
                            'フォロー中の教科: ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color.fromARGB(179, 100, 100, 100),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: (userData['following_subjects'] as List)
                                .map<Widget>((subject) => Text(
                                      subject,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // ------------------------
                  // 投稿一覧
                  // ------------------------
                  const Divider(thickness: 1),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      '投稿',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (userPosts.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'まだ投稿がありません',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: userPosts.length,
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.grey[300],
                        thickness: 1,
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final post = userPosts[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ユーザー情報表示部分
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
                                          userData['user_name'] != null
                                              ? userData['user_name'][0]
                                              : '?',
                                          style: const TextStyle(
                                            fontSize: 23,
                                            color: Colors.black,
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
                                                userData['user_name'],
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '@${userData['user_id']}',
                                                style: const TextStyle(
                                                  fontSize: 11,
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
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              // 投稿の内容
                              Padding(
                                padding: const EdgeInsets.only(left: 64.0),
                                child: Text(
                                  post['description'] ?? '内容なし',
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                              // いいねボタンといいね数
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      (post['is_liked'] ?? false)
                                          ? Icons.thumb_up_alt
                                          : Icons.thumb_up_alt_outlined,
                                      color: (post['is_liked'] ?? false)
                                          ? Colors.blue
                                          : Colors.grey,
                                    ),
                                    onPressed: () {
                                      _toggleLike(
                                        post['id'],
                                        post['is_liked'] ?? false,
                                        post['like_count'] ?? 0,
                                      ).then((_) {
                                        setState(() {
                                          post['is_liked'] = !(post['is_liked'] ?? false);
                                          post['like_count'] = post['is_liked']
                                              ? (post['like_count'] ?? 0) + 1
                                              : (post['like_count'] ?? 0) - 1;
                                        });
                                      });
                                    },
                                  ),
                                  Text('${post['like_count'] ?? 0}'),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
