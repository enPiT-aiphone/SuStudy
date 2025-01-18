import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FetchGroup with ChangeNotifier {
  bool isGrouped = false;// グループに所属しているかどうか
  String _myGroup = ''; // グループ名
  List<String> _groupMemberIds = [];// グループのユーザーIDリスト

  // 自分が所属しているグループ名を取得
  Future<String?> fetchMyGroup() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        print('ログインしているユーザーがいません');
        return null;
      }

      final groupsSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('groups')
          .get();

      if (groupsSnapshot.docs.isEmpty) {
        isGrouped = false;
        notifyListeners();
        return null;
      } else {
        isGrouped = true;
        _myGroup = groupsSnapshot.docs.first['groupName'];
        notifyListeners();
        return _myGroup;
      }
    } catch (e) {
      print('グループ名の取得エラー: $e');
      return null;
    }
  }

  // グループメンバーIDを取得
  Future<List<String>> fetchGroupMemberIds() async {
    try {
      final groupSnapshot = await FirebaseFirestore.instance
          .collection('Groups')
          .where('groupName', isEqualTo: _myGroup)
          .get();

      if (groupSnapshot.docs.isNotEmpty) {
        final groupDoc = groupSnapshot.docs.first;
        final membersSnapshot =
            await groupDoc.reference.collection('members_id').get();

        _groupMemberIds = membersSnapshot.docs
            .map((doc) => doc['auth_uid'] as String)
            .toList();
        notifyListeners();
        return _groupMemberIds;
      } else {
        return [];
      }
    } catch (e) {
      print('グループメンバーの取得エラー: $e');
      return [];
    }
  }
}