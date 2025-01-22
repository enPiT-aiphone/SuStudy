import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserViewModel extends ChangeNotifier {
  String userName = '';
  String userId = '';
  int followers = 0;
  int following = 0;
  List<String> followingSubjects = [];
  bool isFollowed = false;
  bool isLoading = true;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentUserId;
  StreamSubscription<DocumentSnapshot>? _userStreamSubscription;

  UserViewModel() {
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (_currentUserId != null) {
      fetchUserData();
      startRealTimeUpdates();
    }
  }

  Future<void> fetchUserData() async {
    if (_currentUserId == null) return;

    try {
      isLoading = true;
      notifyListeners();

      final userSnapshot =
          await _firestore.collection('Users').doc(_currentUserId).get();

      if (userSnapshot.exists) {
        final data = userSnapshot.data()!;
        userName = data['user_name'] ?? '';
        userId = data['user_id'] ?? '';
        followers = data['follower_count'];
        following = data['follow_count'];
        followingSubjects = List<String>.from(data['following_subjects'] ?? []);
      }
    } catch (e) {
      print('Error fetching user data: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void startRealTimeUpdates() {
    if (_currentUserId == null) return;

    _userStreamSubscription = _firestore
        .collection('Users')
        .doc(_currentUserId)
        .snapshots()
        .listen(
      (snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data()!;
          userName = data['user_name'] ?? '';
          userId = data['user_id'] ?? '';
          followers = data['follower_count'];
          following = data['follow_count'];
          followingSubjects =
              List<String>.from(data['following_subjects'] ?? []);
          notifyListeners();
        }
      },
      onError: (error) {
        print('Error in real-time updates: $error');
      },
    );
  }

  Future<void> checkFollowStatus(String targetUserId) async {
    if (_currentUserId == null) return;

    try {
      final followSnapshot = await _firestore
          .collection('Users')
          .doc(_currentUserId)
          .collection('follows')
          .doc(targetUserId)
          .get();

      isFollowed =
          followSnapshot.exists && (followSnapshot.data()?['is_followed'] ?? false);
      notifyListeners();
    } catch (e) {
      print('Error checking follow status: $e');
    }
  }

  void updateFollowers(int newFollowers) {
    followers = newFollowers;
    notifyListeners();
  }

  void updateFollowing(int newFollowing) {
    following = newFollowing;
    notifyListeners();
  }

  @override
  void dispose() {
    _userStreamSubscription?.cancel();
    super.dispose();
  }
}
