import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

// あなたのプロジェクト構成に合わせて import を調整してください
import '../../utils/progress_utils.dart';
import '../../utils/fetchGroup.dart';
import 'reply_screen.dart';

class TimelineScreen extends StatefulWidget {
  final String selectedTab;
  final String selectedCategory;
  final Function(String userId) onUserProfileTap; // コールバック関数を追加
  final Function(Map<String, dynamic> post) onReplyRequested;

  const TimelineScreen({
    Key? key,
    required this.selectedTab,
    required this.selectedCategory,
    required this.onUserProfileTap,
    required this.onReplyRequested,
  }) : super(key: key);

  @override
  _TimelineScreenState createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  final FetchGroup fetchGroup = FetchGroup();
  final List<Map<String, dynamic>> _timelinePosts = []; // タイムラインの投稿リスト

  // ローディングとページネーション関連
  bool _isLoading = true;
  bool _isFetchingMore = false;
  DocumentSnapshot? _lastDocument;
  final int _fetchLimit = 10; // 一度に読み取る投稿数

  // ユーザー情報
  String? _currentUserId; // 現在のユーザーID
  List<String> _followingUserIds = []; // フォロー中のユーザーIDリスト

  // グループ情報
  bool? _isGrouped;     // グループに所属しているかどうか
  String? _myGroup;     // グループ名
  List<String> _groupMemberIds = []; // グループのユーザーIDリスト
  int? _progressCount;  // グループメンバーの進捗数

  // 個別の ScrollController を用意
  final ScrollController _timelineScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // 初期化フロー
    _fetchCurrentUser().then((_) async {
      await _fetchFollowingUsers();
      await _initializeGroupData().then((_) {
        if (_isGrouped == true) {
          _fetchGroupMemberProgress();
        }
        _fetchTimelinePosts(); // タイムライン投稿を取得
      });
    });
  }

  @override
  void dispose() {
    // 画面破棄時に ScrollController を解放
    _timelineScrollController.dispose();
    super.dispose();
  }

  /// 現在のユーザー情報を取得
  Future<void> _fetchCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });
    }
  }

  /// フォロー中のユーザーIDリストを取得
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
            .map((doc) => doc.id) // ドキュメントIDをフォロー中ユーザーIDとして取得
            .toList();
      });
    } catch (e) {
      print('フォロー中のユーザー取得中にエラーが発生しました: $e');
    }
  }

  /// グループ名とメンバーIDを取得
  Future<void> _initializeGroupData() async {
    _myGroup = await fetchGroup.fetchMyGroup();
    if (_myGroup != null) {
      _isGrouped = true;
      _groupMemberIds = await fetchGroup.fetchGroupMemberIds();
      print('Group Name: $_myGroup');
      print('Member IDs: $_groupMemberIds');
    }
  }

  /// グループメンバーの今日の目標進捗を取得
  Future<void> _fetchGroupMemberProgress() async {
    try {
      int count = 0;
      for (var userId in _groupMemberIds) {
        final progressData = await fetchTierProgress(userId, '全体');
        final normalizedTierProgress = progressData['normalizedTierProgress'];
        if (normalizedTierProgress != null && normalizedTierProgress >= 1) {
          count++;
        }
      }

      setState(() {
        _progressCount = count;
      });

      // 全員100%達成なら、ポイント加算などの処理を行う
      if (_progressCount == _groupMemberIds.length) {
        print('グループメンバー全員の進捗が100%です');
        // TODO: グループポイントを加算する処理など
      }
    } catch (e) {
      print('グループメンバーの進捗取得エラー: $e');
    }
  }

  /// タイムライン投稿を取得
  Future<void> _fetchTimelinePosts({bool isFetchingMore = false}) async {
    if (_isFetchingMore) return; // 多重リクエストを防止

    setState(() {
      _isFetchingMore = true;
      if (!isFetchingMore) _isLoading = true;
    });

    try {
      // `Timeline`コレクションから投稿を日付降順でクエリ
      Query query = FirebaseFirestore.instance
          .collection('Timeline')
          .orderBy('createdAt', descending: true);

      // タブごとのクエリ設定
      if (widget.selectedTab == 'フォロー中' && _followingUserIds.isNotEmpty) {
        query = query.where('auth_uid', whereIn: _followingUserIds);
      } else if (widget.selectedTab == 'グループ' && _groupMemberIds.isNotEmpty) {
        query = query.where('auth_uid', whereIn: _groupMemberIds);
      }

      // カテゴリごとのクエリ設定
      if (widget.selectedCategory != '全体') {
        query = query.where('category', isEqualTo: widget.selectedCategory);
      }

      // ページネーション
      query = query.limit(_fetchLimit);

      if (_lastDocument != null && isFetchingMore) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final timelineSnapshot = await query.get();

      // 取得結果が空でない場合
      if (timelineSnapshot.docs.isNotEmpty) {
        final List<Map<String, dynamic>> newPosts = [];

        // ユーザー情報を一括取得するためのIDリスト
        final List<String> userIds = timelineSnapshot.docs
            .map((doc) => (doc.data() as Map<String, dynamic>)['auth_uid'] as String)
            .toList();

        // ユーザー情報を一括取得
        final usersSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('auth_uid', whereIn: userIds)
            .get();

        // auth_uid => ユーザーデータ の Map を生成
        final Map<String, Map<String, dynamic>> usersMap = {
          for (var userDoc in usersSnapshot.docs)
            userDoc.data()['auth_uid']: userDoc.data()
        };

        for (var postDoc in timelineSnapshot.docs) {
          final postData = postDoc.data() as Map<String, dynamic>;

          // タブによるフォロー中・グループの場合、該当しない投稿を除外
          if (widget.selectedTab == 'フォロー中' &&
              !_followingUserIds.contains(postData['auth_uid'])) {
            continue;
          } else if (widget.selectedTab == 'グループ' &&
              !_groupMemberIds.contains(postData['auth_uid'])) {
            continue;
          }

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
          _lastDocument = timelineSnapshot.docs.last;
          _isFetchingMore = false;
          if (!isFetchingMore) _isLoading = false;
        });
      } else {
        // これ以上データがない場合
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

  /// 投稿がいいねされているかどうか確認
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

  /// いいねボタンが押されたときの処理
  Future<void> _toggleLike(String postId, bool isLiked, int currentLikeCount) async {
    if (_currentUserId == null) return;

    try {
      final postRef = FirebaseFirestore.instance.collection('Timeline').doc(postId);
      final userLikeRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(_currentUserId)
          .collection('post_timeline_ids')
          .doc(postId);

      // Timeline ドキュメントを取得
      final postSnapshot = await postRef.get();
      if (!postSnapshot.exists) {
        print('postSnapshot does not exist for postId: $postId');
        return;
      }

      final postData = postSnapshot.data();
      final userIdInTimeline = postData?['auth_uid'];

      // ユーザーのpostsサブコレクションにも同様に反映
      final userPostRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(userIdInTimeline)
          .collection('posts')
          .doc(postId);

      if (isLiked) {
        // いいね解除
        await postRef.update({'like_count': currentLikeCount - 1});
        await userPostRef.update({'like_count': FieldValue.increment(-1)});
        await userLikeRef.set({'is_liked': false});
      } else {
        // いいね付与
        await postRef.update({'like_count': currentLikeCount + 1});
        await userPostRef.update({'like_count': FieldValue.increment(1)});
        await userLikeRef.set({'is_liked': true});
      }

      // ローカルのリストにも反映
      setState(() {
        final post = _timelinePosts.firstWhere((element) => element['post_id'] == postId);
        post['is_liked'] = !isLiked;
        post['like_count'] = isLiked ? currentLikeCount - 1 : currentLikeCount + 1;
      });
    } catch (e) {
      print('いいね処理中にエラーが発生しました: $e');
    }
  }

  /// 日時を「〇分前」などの形式に変換
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

  /// タブ or カテゴリが変化した際に呼び出される
  @override
  void didUpdateWidget(TimelineScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // タブやカテゴリが切り替わったら投稿を再取得
    if (widget.selectedTab != oldWidget.selectedTab ||
        widget.selectedCategory != oldWidget.selectedCategory) {
      setState(() {
        _timelinePosts.clear();
        _lastDocument = null;
      });
      _fetchTimelinePosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0ABAB5)),
              ),
            )
          : NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                // スクロールが一番下に達したら追加読み込み
                if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
                    !_isFetchingMore) {
                  _fetchTimelinePosts(isFetchingMore: true);
                }
                return false;
              },
              child: Column(
                children: [
                  // グループタブの場合、グループ情報を表示
                  if (widget.selectedTab == 'グループ' && _isGrouped == true) ...[
                    ListTile(
                      leading: const Icon(Icons.star, color: Color(0xFF0ABAB5)),
                      title: Text(
                        _myGroup ?? '',
                        style: GoogleFonts.roboto(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0ABAB5),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('グループメンバーの進捗: $_progressCount / ${_groupMemberIds.length}'),
                          LinearProgressIndicator(
                            value: (_progressCount ?? 0) /
                                (_groupMemberIds.isNotEmpty ? _groupMemberIds.length : 1),
                            backgroundColor: Colors.grey[300],
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0ABAB5)),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // タイムライン投稿リスト
                  Expanded(
                    child: _timelinePosts.isEmpty
                        ? Center(
                            child: Text(
                              widget.selectedTab == '最新'
                                  ? '投稿がありません'
                                  : (_isGrouped != true
                                      ? (widget.selectedTab == 'フォロー中'
                                          ? 'フォロー中のユーザーがいません'
                                          : 'グループに所属していません')
                                      : '投稿がありません'),
                            ),
                          )
                        : Scrollbar(
                            controller: _timelineScrollController,
                            thumbVisibility: true,
                            child: ListView.separated(
                              controller: _timelineScrollController,
                              itemCount: _timelinePosts.length,
                              separatorBuilder: (context, index) => Divider(
                                color: Colors.grey[300], // 仕切り線の色
                                thickness: 1,           // 仕切り線の太さ
                                height: 1,              // 仕切り線の高さ
                              ),
                              itemBuilder: (context, index) {
                                final post = _timelinePosts[index];
                                return GestureDetector(
                                  onTap: () {
                                    // 投稿をタップしたら返信画面へ遷移
                                    widget.onReplyRequested(post);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 6.0),
                                    padding: const EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          blurRadius: 4.0,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // ユーザー情報 + 投稿日時
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // ユーザーアバター + 名前 + ID
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    // プロフィールを表示するためのコールバック
                                                    widget.onUserProfileTap(post['auth_uid']);
                                                  },
                                                  child: CircleAvatar(
                                                    radius: 27,
                                                    backgroundColor: Colors.grey[200],
                                                    child: Text(
                                                      post['user_name'] != null
                                                          ? post['user_name'][0]
                                                          : '?',
                                                      style: const TextStyle(
                                                        fontSize: 23,
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
                                                            fontSize: 15,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        Text(
                                                          '@${post['user_id'].length > 10 ? post['user_id'].substring(0, 10) + '...' : post['user_id']}',
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

                                        // 投稿内容
                                        Padding(
                                          padding: const EdgeInsets.only(left: 64.0),
                                          child: Text(
                                            post['description'] ?? '',
                                            style: const TextStyle(fontSize: 15),
                                          ),
                                        ),

                                        // いいねボタン + いいね数
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
                                                _toggleLike(
                                                  post['post_id'],
                                                  post['is_liked'],
                                                  post['like_count'],
                                                );
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
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
