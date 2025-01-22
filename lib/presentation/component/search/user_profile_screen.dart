import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_user_profile.dart';
import 'follow_follower_list.dart';
import '../user_view_model.dart'; //
import 'package:provider/provider.dart';


class UserProfileScreen extends StatefulWidget {
  final String userId;
   final VoidCallback? onBack; // 戻るボタンが押された時の処理

  const UserProfileScreen({super.key, required this.userId, this.onBack});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String? _currentUserId; // 現在のユーザーID
  List<Map<String, dynamic>> _posts = []; // 投稿データを管理するリスト
  bool _isFollowed = false; // フォロー状態を管理
  String _userName = '';
  String _bio = '';
  String _occupation = '';
  String _subOccupation = '';

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
    _loadUserPosts(); // 投稿データの取得
    _checkIfFollowed(); // フォロー状態を確認
  }


void _showFollowFollowerList(BuildContext context, String targetUserId, int initialTabIndex) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // 高さを調整可能にする
    backgroundColor: Colors.transparent, // 背景色を透明にする
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.8, // 画面の高さの80%
      decoration: const BoxDecoration(
        color: Colors.white, // 背景色を白に設定
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),  // 左上の角を丸く
          topRight: Radius.circular(20.0), // 右上の角を丸く
        ),
      ),
      child: ClipRRect( // 角丸をしっかり適用するために追加
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        child: FollowFollowerListScreen(
          targetUserId: targetUserId,
          initialTabIndex: initialTabIndex,
        ),
      ),
    ),
  );
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

  Future<void> _followUser() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    try {
      final currentUserDoc =
          FirebaseFirestore.instance.collection('Users').doc(currentUserId);

      final targetUserDoc =
        FirebaseFirestore.instance.collection('Users').doc(widget.userId);

      if (!_isFollowed) {
        // 自分のfollowsサブコレクションに追加
        await currentUserDoc.collection('follows').doc(widget.userId).set({
          'timestamp': FieldValue.serverTimestamp(),
          'auth_uid': widget.userId,
          'is_followed': true,
        });

        // 自分のfollow_countを+1
        await currentUserDoc.update({
          'follow_count': FieldValue.increment(1),
        });

        // 対象ユーザーのfollower_countを+1
        await targetUserDoc.update({
          'follower_count': FieldValue.increment(1),
        });

        // フォローされる側のfollowersサブコレクションに自分のuser_idを追加
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
      print('フォロー中にエラーが発生しました: $e');
    }
  }

  // フォロー解除処理
  Future<void> _unfollowUser() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    try {
      final currentUserDoc =
          FirebaseFirestore.instance.collection('Users').doc(currentUserId);

      final targetUserDoc =
        FirebaseFirestore.instance.collection('Users').doc(widget.userId);

      if (_isFollowed) {

        await currentUserDoc.collection('follows').doc(widget.userId).set({
          'is_followed': false,
        });
    
        // 自分のfollow_countを-1
        await currentUserDoc.update({
          'follow_count': FieldValue.increment(-1),
        });

        // 対象ユーザーのfollower_countを-1
        await targetUserDoc.update({
          'follower_count': FieldValue.increment(-1),
        });

        await targetUserDoc.collection('followers').doc(currentUserId).set({
          'is_isfollowed': false,
        });

        setState(() {
          _isFollowed = false;
        });

      }
    } catch (e) {
      print('フォロー解除中にエラーが発生しました: $e');
    }
  }

  Future<void> _fetchCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });
    }
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    try {
      // FirestoreのUsersコレクションからwidget.userIdのドキュメントを直接取得
      final userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId) // ドキュメントIDがwidget.userId
          .get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;

        // following_subjectsがnullの場合は空のリストを設定
        return {
          ...userData,
          'following_subjects': userData['following_subjects'] ?? [],
        };
      } else {
        print('ユーザードキュメントが見つかりません: ${widget.userId}');
        return {};
      }
    } catch (e) {
      print('エラー: $e');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> _fetchUserPosts() async {
    if (_currentUserId == null) return []; // ユーザーIDが取得できない場合は空リスト

    try {
      // postsサブコレクションから投稿データを取得
      final postsSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .get();

      // いいねの状態も含めて投稿データをリストにまとめる
      final List<Future<Map<String, dynamic>?>> postFutures =
          postsSnapshot.docs.map((postDoc) async {
        final postData = postDoc.data();

        // いいねの状態を取得
        final isLiked = await _checkIfLiked(postDoc.id);

        return {
          'id': postDoc.id,
          'description': postData['description'] ?? '内容なし',
          'like_count': postData['like_count'] ?? 0,
          'createdAt': postData['createdAt'],
          'is_liked': isLiked,
        };
      }).toList();

      final posts = await Future.wait(postFutures);
      return posts.where((post) => post != null).cast<Map<String, dynamic>>().toList();
    } catch (e) {
      print('投稿データ取得中にエラーが発生しました: $e');
      return [];
    }
  }

  Future<void> _loadUserPosts() async {
    final posts = await _fetchUserPosts();
    setState(() {
      _posts = posts; // 投稿データを更新
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

  // いいねの切り替え
Future<void> _toggleLike(String postId, bool isLiked, int currentLikeCount) async {
  if (_currentUserId == null) return;

  try {
    // Usersコレクションのpostsサブコレクション内の投稿参照
    final postRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.userId)
        .collection('posts')
        .doc(postId);

    // Timelineコレクション内の投稿参照
    final timelinePostRef = FirebaseFirestore.instance
        .collection('Timeline')
        .doc(postId);

    // いいねの情報を保存するサブコレクション
    final userLikeRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(_currentUserId)
        .collection('post_timeline_ids')
        .doc(postId);

    // いいねの処理
    if (isLiked) {
      // いいねを解除
      await postRef.update({'like_count': currentLikeCount - 1});
      await timelinePostRef.update({'like_count': FieldValue.increment(-1)});
      await userLikeRef.set({'is_liked': false});
    } else {
      // いいねを追加
      await postRef.update({'like_count': currentLikeCount + 1});
      await timelinePostRef.update({'like_count': FieldValue.increment(1)});
      await userLikeRef.set({'is_liked': true});
    }

    // UIを更新
    setState(() {
    });
  } catch (e) {
    print('いいねの処理中にエラー: $e');
  }
}

Future<void> _loadUserData() async {
  if (_currentUserId == null) return;

  try {
    final userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(_currentUserId)
        .get();

    if (userDoc.exists) {
      setState(() {
        // 取得したデータを画面の状態に反映
        final data = userDoc.data();
        _userName = data?['user_name'] ?? '';
        _bio = data?['bio'] ?? '';
        _occupation = data?['occupation'] ?? '';
        _subOccupation = data?['sub_occupation'] ?? '';
      });
    }
  } catch (e) {
    print('ユーザーデータの読み込み中にエラーが発生しました: $e');
  }
}


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
  Widget build(BuildContext context) {
    final userViewModel = context.watch<UserViewModel>();
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40.0), // AppBarの高さを設定
        child: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back), // 戻る矢印
            onPressed: widget.onBack ?? () {}, // onBackコールバックが設定されていれば実行
          ),
        ),
      ),
      body: FutureBuilder(
        future: Future.wait([
          _fetchUserData(),
          _fetchUserPosts(),
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(valueColor:  AlwaysStoppedAnimation<Color>(Color(0xFF0ABAB5)),));
          }

          final userData = snapshot.data![0] as Map<String, dynamic>;
          final userPosts = snapshot.data![1] as List<Map<String, dynamic>>;

          if (userData.isEmpty) {
            return const Center(child: Text('ユーザーが見つかりませんでした。'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ヘッダー
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // 上揃えにする
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF0ABAB5), width: 1.0),
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Text(
                          userData['user_name'] != null && userData['user_name'].isNotEmpty
                              ? userData['user_name'][0]
                              : '?',
                          style: const TextStyle(fontSize: 30, color: Color(0xFF0ABAB5)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userData['user_name'] ?? '不明',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          // user_idをWrapで折り返しさせずに表示
                          Wrap(
                            children: [
                              Text(
                                '@${userData['user_id']}',
                                style: const TextStyle(
                                  fontSize: 16,
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
                                      builder: (context) => EditProfileScreen(), // プロフィール編集画面
                                    ),
                                  );

                                  // 戻ってきた時にデータを再読み込みする
                                  if (result == true) {
                                    _loadUserData(); // Firestoreから最新データを再読み込みする関数を呼び出す
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.grey),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                ),
                                child: const Text(
                                  'プロフィール編集',
                                  style: TextStyle(color: Colors.black, fontSize: 16),
                                ),
                              )
                            else
                              ElevatedButton(
                                onPressed: _isFollowed ? _unfollowUser : _followUser,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      _isFollowed ? Colors.grey : const Color(0xFF0ABAB5),
                                ),
                                child: Text(
                                  _isFollowed ? 'フォロー解除' : 'フォローする',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
                // プロフィール情報
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (userData['bio'] != null && userData['bio'].isNotEmpty) ...[
                        Text(
                          userData['bio'],
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 5),
                      ],
                      // フォロワーとフォロー中の情報を表示
                      Row(
                        children: [
                          const Text(
                            'フォロワー: ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(179, 100, 100, 100),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _showFollowFollowerList(context, widget.userId, 0); // フォロワーリストを表示
                            },
                            child: Text(
                              '${userData['follower_count'] ?? 0}',
                              style: const TextStyle(
                                fontSize: 16,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20), // スペースを追加
                          const Text(
                            'フォロー中: ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(179, 100, 100, 100),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _showFollowFollowerList(context, widget.userId, 1); // フォロー中リストを表示
                            },
                            child: Text(
                              '${userData['follow_count'] ?? 0}',
                              style: const TextStyle(
                                fontSize: 16,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5), // スペース追加
                      // フォロー中の教科
                      if (userData['following_subjects'] != null &&
                          (userData['following_subjects'] as List).isNotEmpty) ...[
                        const Text(
                          'フォロー中の教科: ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(179, 100, 100, 100),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8.0, // 教科間の横のスペース
                          runSpacing: 8.0, // 教科間の縦のスペース
                          children: (userData['following_subjects'] as List)
                              .map<Widget>((subject) => Text(
                                    subject,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black, // テキストカラー
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),

                // 投稿リスト
                const Divider(thickness: 1),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    '投稿',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                userPosts.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('まだ投稿がありません'),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: userPosts.length,
                        separatorBuilder: (context, index) => Divider(
                          color: Colors.grey[300], // 線の色
                          thickness: 1, // 線の太さ
                          height: 1, // 線の高さ
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
                                              fontSize: 25,
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
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  '@${userData['user_id']}',
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
                                // 投稿の内容
                                Padding(
                                  padding: const EdgeInsets.only(left: 64.0),
                                  child: Text(
                                    post['description'] ?? '内容なし',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // いいねボタンといいね数
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        (post['is_liked'] ?? false) // nullの場合はfalse
                                            ? Icons.thumb_up_alt
                                            : Icons.thumb_up_alt_outlined,
                                        color: (post['is_liked'] ?? false) ? Colors.blue : Colors.grey,
                                      ),
                                      onPressed: () {
                                        _toggleLike(
                                          post['id'],
                                          post['is_liked'] ?? false, // nullならfalseを渡す
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
                                    Text('${post['like_count'] ?? 0}'), // nullの場合に0を表示
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      )
              ],
            ),
          );
        },
      ),
    );
  }
}


