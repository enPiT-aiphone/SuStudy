import '/import.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class SubjectDetailsScreen extends StatefulWidget {
  final String subjectName;

  const SubjectDetailsScreen({required this.subjectName, super.key});

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
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userDoc);

      if (!userSnapshot.exists) {
        print('ユーザー情報が見つかりません');
        return;
      }

      // 現在の following_subjects を取得し、教科名を追加
      final currentSubjects = List<String>.from(
          userSnapshot.data()?['following_subjects'] ?? []);
      if (!currentSubjects.contains(widget.subjectName)) {
        currentSubjects.add(widget.subjectName);
        transaction.update(userDoc, {'following_subjects': currentSubjects});
      }
    });

    // Recordサブコレクションの現在の日付のドキュメントにアクセス
    final today = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(today);
    final recordDocRef = userDoc.collection('record').doc(formattedDate);

    // 現在の日付のドキュメントが存在するか確認し、存在しない場合は作成
    final recordDocSnapshot = await recordDocRef.get();
    if (!recordDocSnapshot.exists) {
      await recordDocRef.set({
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    // 教科サブコレクションにドキュメントを作成
    final subjectDocRef = recordDocRef.collection(widget.subjectName).doc('Word');

    final subjectDocSnapshot = await subjectDocRef.get();
    if (!subjectDocSnapshot.exists) {
      await subjectDocRef.set({
        'timestamp': FieldValue.serverTimestamp(),
        'tierProgress_today': 0, // 初期化
      });
    }

    // `t_solved_count_教科名` フィールドを作成または更新
    await recordDocRef.set({
      't_solved_count_${widget.subjectName}': 0, // 初期値として 0 を設定
    }, SetOptions(merge: true));

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
          ? const Center(child: CircularProgressIndicator(valueColor:  AlwaysStoppedAnimation<Color>(Color(0xFF0ABAB5)),))
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
                      : const Color(0xFF0ABAB5),
                    ),
                    child: Text(_isFollowed ? 'フォロー済み' : 'フォローする'),
                  ),
                ],
              ),
            ),
    );
  }
}
