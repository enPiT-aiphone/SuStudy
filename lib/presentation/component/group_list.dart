import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserGroupsScreen extends StatelessWidget {
  const UserGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('参加しているグループ'),
        ),
        body: const Center(
          child: Text('ログインが必要です'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('参加しているグループ'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .collection('groups')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(valueColor:  AlwaysStoppedAnimation<Color>(Color(0xFF0ABAB5)),));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('参加しているグループはありません'),
            );
          }

          final groups = snapshot.data!.docs;

          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              final groupName = group['groupName'] ?? 'グループ名なし';
              final groupId = group['groupId'];

              return ListTile(
                title: Text(groupName),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupMembersScreen(groupId: groupId, groupName: groupName),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class GroupMembersScreen extends StatelessWidget {
  final String groupId;
  final String groupName;

  const GroupMembersScreen({super.key, required this.groupId, required this.groupName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$groupName のメンバー'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Groups')
            .doc(groupId)
            .collection('members_id')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(valueColor:  AlwaysStoppedAnimation<Color>(Color(0xFF0ABAB5)),));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('このグループにはメンバーがいません'),
            );
          }

          final members = snapshot.data!.docs;

          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              final memberName = member['userName'] ?? '名前なし';
              final memberId = member['auth_uid'] ?? 'IDなし';

              return ListTile(
                title: Text(memberName),
                subtitle: Text('ID: $memberId'),
              );
            },
          );
        },
      ),
    );
  }
}
