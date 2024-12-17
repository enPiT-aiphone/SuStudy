import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FollowFollowerListScreen extends StatefulWidget {
  final String targetUserId;
  final int initialTabIndex;

  FollowFollowerListScreen({
    required this.targetUserId,
    this.initialTabIndex = 0,
  });

  @override
  _FollowFollowerListScreenState createState() =>
      _FollowFollowerListScreenState();
}

class _FollowFollowerListScreenState extends State<FollowFollowerListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ユーザーリスト表示UI (共通)
  Widget _buildUserList(String collectionName) {
    return FutureBuilder<QuerySnapshot>(
      // targetUserIdとuser_idが一致するドキュメントを検索
      future: FirebaseFirestore.instance
          .collection('Users')
          .where('user_id', isEqualTo: widget.targetUserId)
          .limit(1)
          .get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
          return Center(child: Text('対象のユーザーが見つかりません'));
        }

        final userDocId = userSnapshot.data!.docs.first.id;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .doc(userDocId)
              .collection(collectionName) // follows または followers
              .where('user_id', isNotEqualTo: 'init') // initドキュメントを除外
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                  child: Text(collectionName == 'follows'
                      ? 'フォロー中のユーザーはいません'
                      : 'フォロワーはいません'));
            }

            final userList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: userList.length,
              itemBuilder: (context, index) {
                final followData = userList[index].data() as Map<String, dynamic>;
                final userId = followData['user_id'];

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('Users')
                      .where('user_id', isEqualTo: userId)
                      .limit(1)
                      .get()
                      .then((query) => query.docs.first),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) {
                      return SizedBox.shrink();
                    }

                    final user = userSnapshot.data!;
                    final userName = user['user_name'] ?? '不明';
                    final userId = user['user_id'] ?? '';

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        child: Text(
                          userName.isNotEmpty ? userName[0] : '?',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      title: Text(userName),
                      subtitle: Text('@$userId'),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Color(0xFF0ABAB5), // インジケーターの色を変更
          labelColor: Color(0xFF0ABAB5), // 選択されたタブのテキスト色
          unselectedLabelColor: Colors.grey, // 選択されていないタブのテキスト色
          tabs: [
            Tab(text: 'フォロワー'), // 左にフォロワータブ
            Tab(text: 'フォロー中'), // 右にフォロー中タブ
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUserList('followers'), // フォロワーリスト
          _buildUserList('follows'), // フォロー中リスト
        ],
      ),
    );
  }
}
