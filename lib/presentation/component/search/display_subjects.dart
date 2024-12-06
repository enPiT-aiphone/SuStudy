import '/import.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubjectDetailsScreen extends StatefulWidget {
  final String subjectName;

  const SubjectDetailsScreen({required this.subjectName, Key? key})
      : super(key: key);

  @override
  _SubjectDetailsScreenState createState() => _SubjectDetailsScreenState();
}

class _SubjectDetailsScreenState extends State<SubjectDetailsScreen> {
  bool _isFollowed = false; // フォロー状態を管理
  bool _isLoading = true; // 初期読み込み状態を管理

  @override
  void initState() {
    super.initState();
    _checkFollowStatus();
  }

  // フォロー状態を確認
  Future<void> _checkFollowStatus() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      print('ログイン中のユーザーがいません');
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final followingSubjects =
            List<String>.from(userDoc.data()?['following_subjects'] ?? []);
        setState(() {
          _isFollowed = followingSubjects.contains(widget.subjectName);
        });
      }
    } catch (e) {
      print('フォロー状態の確認中にエラーが発生しました: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // フォロー処理
  Future<void> _followSubject() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      print('ログイン中のユーザーがいません');
      return;
    }

    try {
      final userDoc = FirebaseFirestore.instance.collection('Users').doc(userId);

      // following_subjects フィールドに教科名を追加
      await userDoc.update({
        'following_subjects': FieldValue.arrayUnion([widget.subjectName]),
      });

      // following_subjects サブコレクションに教科ドキュメントを作成
      final subCollectionDoc =
          userDoc.collection('following_subjects').doc(widget.subjectName);
      final docSnapshot = await subCollectionDoc.get();
      if (!docSnapshot.exists) {
        await subCollectionDoc.set({'timestamp': FieldValue.serverTimestamp()});
      }

      setState(() {
        _isFollowed = true; // フォロー状態を更新
      });

      print('${widget.subjectName} をフォローしました');
    } catch (e) {
      print('フォロー処理中にエラーが発生しました: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subjectName),
        backgroundColor: const Color(0xFF0ABAB5),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.subjectName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isFollowed
                        ? null // すでにフォロー済みの場合はボタンを無効化
                        : _followSubject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFollowed 
                      ? Colors.grey 
                      : Color(0xFF0ABAB5),
                    ),
                    child: Text(_isFollowed ? 'フォロー済み' : 'フォローする'),
                  ),
                ],
              ),
            ),
    );
  }
}
