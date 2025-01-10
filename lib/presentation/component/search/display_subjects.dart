import '/import.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

/// 教科の説明を表示するダイアログ
Future<void> _showSubjectDescriptionDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('教科説明'),
        content: const Text('教科説明文予定'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      );
    },
  );
}

// 目標スコア／級をまとめた定義。TOEIC/TOEFL/英検のみマルチレベル
Map<String, List<String>> levelMap = {
  'TOEIC': [
    'TOEIC300点',
    'TOEIC500点',
    'TOEIC700点',
    'TOEIC900点',
    'TOEIC990点',
  ],
  'TOEFL': [
    'TOEFL40点',
    'TOEFL60点',
    'TOEFL80点',
    'TOEFL100点',
    'TOEFL120点',
  ],
  '英検': [
    '英検5級',
    '英検4級',
    '英検3級',
    '英検準2級',
    '英検2級',
    '英検準1級',
    '英検1級',
  ],
};

// 学習目標の選択肢
const List<String> dailyGoals = ['5分/日', '10分/日', '15分/日', '30分/日'];

// 解除確認ダイアログ
Future<bool> _showUnfollowConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('フォローを解除しますか？'),
        content: const Text('再度フォローしてもこれまでの学習データを引き継ぐことはできません。本当にフォローを解除しますか？'),
        actions: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
            ),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('解除する'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
            ),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('解除しない'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false); 
}

/// 各レベル（例: "TOEIC300点"）をフォロー中かどうかを判定する
bool _isLevelFollowed(List<String> followingSubjects, String levelName) {
  return followingSubjects.contains(levelName);
}

/// 学習目標を選択させるダイアログ
/// 選択した数値文字列 ("5" / "10" / "15" / "30") を返す。キャンセルなら null。
Future<String?> _showDailyGoalDialog(BuildContext context) async {
  String? selectedGoal;
  bool canFollow = false; // フォローボタンの有効/無効を管理

  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('学習目標を選択'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final goalText in dailyGoals)
                  RadioListTile<String>(
                    title: Text(goalText),
                    value: goalText,
                    groupValue: selectedGoal,
                    onChanged: (value) {
                      selectedGoal = value;
                      canFollow = true;
                      setState(() {});
                    },
                  ),
              ],
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
                child: const Text('フォローしない'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: canFollow ? const Color(0xFF0ABAB5) : Colors.grey,
                ),
                onPressed: canFollow
                    ? () {
                        // "5分/日" -> "5" のみ取り出す
                        final numericValue = selectedGoal?.replaceAll(RegExp(r'[^0-9]'), '');
                        Navigator.of(context).pop(numericValue);
                      }
                    : null,
                child: const Text('フォローする'),
              ),
            ],
          );
        },
      );
    },
  );
}

class SubjectDetailsScreen extends StatefulWidget {
  final String subjectName;

  const SubjectDetailsScreen({required this.subjectName, Key? key})
      : super(key: key);

  @override
  _SubjectDetailsScreenState createState() => _SubjectDetailsScreenState();
}

class _SubjectDetailsScreenState extends State<SubjectDetailsScreen> {
  bool _isLoading = true;             // 初期読み込み中
  late List<String> _following;       // 自分がフォロー中のすべての教科(またはレベル)
  bool _isNormalSubject = false;      // TOEIC/TOEFL/英検 以外かどうか

  @override
  void initState() {
    super.initState();
    _checkFollowStatus();
  }

  // ======== Firestoreから現在のフォロー状況を読み込む処理 ========
  Future<void> _checkFollowStatus() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('ログイン中のユーザーがいません');
      setState(() {
        _isLoading = false;
        _following = [];
      });
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        _following = List<String>.from(
          userDoc.data()?['following_subjects'] ?? [],
        );
      } else {
        _following = [];
      }
    } catch (e) {
      print('フォロー状態の確認中にエラーが発生しました: $e');
      _following = [];
    } finally {
      // TOEIC/TOEFL/英検 以外であれば _isNormalSubject = true
      _isNormalSubject = !levelMap.keys.contains(widget.subjectName);
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ======== 単純な教科（TOEIC/TOEFL/英検 以外）のフォロー状況 ========
  bool get _isFollowedForNormal {
    return _following.contains(widget.subjectName);
  }

  // ======== ボタンタップでフォロー/解除する（単純教科用） ========
  Future<void> _toggleNormalSubjectFollow() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('ログイン中のユーザーがいません');
      return;
    }

    final userDoc = FirebaseFirestore.instance.collection('Users').doc(userId);

    // すでにフォロー中 → 解除
    if (_isFollowedForNormal) {
      final shouldUnfollow = await _showUnfollowConfirmationDialog(context);
      if (!shouldUnfollow) return;

      // 解除
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        if (!snapshot.exists) return;

        final currentSubjects =
            List<String>.from(snapshot.data()?['following_subjects'] ?? []);
        if (currentSubjects.contains(widget.subjectName)) {
          currentSubjects.remove(widget.subjectName);
          transaction.update(userDoc, {'following_subjects': currentSubjects});
        }
      });

      print('${widget.subjectName} をフォロー解除しました');
    } 
    else {
      // フォロー時、学習目標ダイアログを表示
      final selectedGoal = await _showDailyGoalDialog(context);
      if (selectedGoal == null || selectedGoal.isEmpty) {
        // キャンセルの場合
        return;
      }

      // 新規フォロー
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        if (!snapshot.exists) return;

        final currentSubjects =
            List<String>.from(snapshot.data()?['following_subjects'] ?? []);
        if (!currentSubjects.contains(widget.subjectName)) {
          currentSubjects.add(widget.subjectName);
          transaction.update(userDoc, {'following_subjects': currentSubjects});
        }
      });

      // Recordサブコレクション
      final today = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd').format(today);
      final recordDocRef = userDoc.collection('record').doc(formattedDate);

      final recordDocSnapshot = await recordDocRef.get();
      if (!recordDocSnapshot.exists) {
        await recordDocRef.set({'timestamp': FieldValue.serverTimestamp()});
      }

      // subcollection名は subjectName
      final subCollectionRef =
          recordDocRef.collection(widget.subjectName).doc('Word');
      final scSnapshot = await subCollectionRef.get();
      if (!scSnapshot.exists) {
        await subCollectionRef.set({
          'timestamp': FieldValue.serverTimestamp(),
          'tierProgress_today': 0,
        });
      }
      // 新たに Grammar サブコレクションを作成
      final subCollectionRefGrammar = 
          recordDocRef.collection(widget.subjectName).doc('Short_Sentence');
      final scSnapshotGrammar = await subCollectionRefGrammar.get();
      if (!scSnapshotGrammar.exists) {
        await subCollectionRefGrammar.set({
          'timestamp': FieldValue.serverTimestamp(),
          'tierProgress_today': 0,
        });
      }
      // t_solved_count_教科名
      await recordDocRef.set(
        {'t_solved_count_${widget.subjectName}': 0},
        SetOptions(merge: true),
      );

      // ここで目標のフィールドを追加 (例: "数学_goal": 5)
      final goalInt = int.tryParse(selectedGoal) ?? 0;
      await recordDocRef.set(
        {'${widget.subjectName}_goal': goalInt},
        SetOptions(merge: true),
      );

      print('${widget.subjectName} をフォローしました (目標: $goalInt 分/日)');
    }

    // 状態更新
    await _checkFollowStatus();
    setState(() {});
  }

  // ======== レベルごとのフォロー/解除（TOEIC, TOEFL, 英検用） ========
  Future<void> _toggleLevelFollow(String levelName) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('ログイン中のユーザーがいません');
      return;
    }

    final userDoc = FirebaseFirestore.instance.collection('Users').doc(userId);

    final alreadyFollowed = _isLevelFollowed(_following, levelName);

    if (alreadyFollowed) {
      // 解除確認ダイアログ
      final shouldUnfollow = await _showUnfollowConfirmationDialog(context);
      if (!shouldUnfollow) return;

      // 解除処理
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        if (!snapshot.exists) return;

        final currentSubjects =
            List<String>.from(snapshot.data()?['following_subjects'] ?? []);
        if (currentSubjects.contains(levelName)) {
          currentSubjects.remove(levelName);
          transaction.update(userDoc, {'following_subjects': currentSubjects});
        }
      });

      print('$levelName をフォロー解除しました');
    } 
    else {
      // フォローする → 学習目標ダイアログ
      final selectedGoal = await _showDailyGoalDialog(context);
      if (selectedGoal == null || selectedGoal.isEmpty) {
        return;
      }

      // 新規フォロー
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        if (!snapshot.exists) return;

        final currentSubjects =
            List<String>.from(snapshot.data()?['following_subjects'] ?? []);
        if (!currentSubjects.contains(levelName)) {
          currentSubjects.add(levelName);
          transaction.update(userDoc, {'following_subjects': currentSubjects});
        }
      });

      // Recordサブコレクション
      final today = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd').format(today);
      final recordDocRef = userDoc.collection('record').doc(formattedDate);

      final recordDocSnapshot = await recordDocRef.get();
      if (!recordDocSnapshot.exists) {
        await recordDocRef.set({'timestamp': FieldValue.serverTimestamp()});
      }

      // subcollection名は levelName (例: "TOEIC300点")
      final subCollectionRef = recordDocRef.collection(levelName).doc('Word');
      final scSnapshot = await subCollectionRef.get();
      if (!scSnapshot.exists) {
        await subCollectionRef.set({
          'timestamp': FieldValue.serverTimestamp(),
          'tierProgress_today': 0,
          'tierProgress_all': 0,
        });
      }
      // 新たに Grammar サブコレクションを作成
      final subCollectionRefGrammar = recordDocRef.collection(levelName).doc('Short_Sentence');
      final scSnapshotGrammar = await subCollectionRefGrammar.get();
      if (!scSnapshotGrammar.exists) {
        await subCollectionRefGrammar.set({
          'timestamp': FieldValue.serverTimestamp(),
          'tierProgress_today': 0,
        });
      }

      // t_solved_count_教科名 だったのを t_solved_count_レベル名 にする場合は下記変更
      // ここでは t_solved_count_${levelName} に書きます
      await recordDocRef.set({
        't_solved_count_${levelName}': 0,
        
        },
        SetOptions(merge: true),
      );

      // 目標フィールドを追加 (例: "TOEIC300点_goal": 5)
      final goalInt = int.tryParse(selectedGoal) ?? 0;
      await recordDocRef.set(
        {'${levelName}_goal': goalInt},
        SetOptions(merge: true),
      );

      print('$levelName をフォローしました (目標: $goalInt 分/日)');
    }

    // 状態更新
    await _checkFollowStatus();
    setState(() {});
  }

  // ======== 上部の「教科名」ボタン。押したら「教科説明文予定」ダイアログを表示 ========
  Widget _buildSubjectNameButton(BuildContext context) {
    final double buttonWidth = MediaQuery.of(context).size.width * 0.75;
    return InkWell(
      onTap: () => _showSubjectDescriptionDialog(context),
      child: Container(
        width: buttonWidth,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF0ABAB5)),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          widget.subjectName,
          style: const TextStyle(
            color: Color(0xFF0ABAB5),
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  // ======== TOEIC/TOEFL/英検 用：レベルごとのフォローボタンを並べる ========
  Widget _buildMultiLevelFollowList() {
    final levels = levelMap[widget.subjectName] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          '目標',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 10),
        for (final level in levels) _buildLevelRow(level),
      ],
    );
  }

  Widget _buildLevelRow(String level) {
    final followed = _isLevelFollowed(_following, level);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              level,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () => _toggleLevelFollow(level),
            style: ElevatedButton.styleFrom(
              backgroundColor: followed ? Colors.grey : const Color(0xFF0ABAB5),
            ),
            child: Text(followed ? 'フォロー中' : 'フォロー'),
          ),
        ],
      ),
    );
  }

  // ======== 通常教科用のフォローボタン（教科名ボタンの「すぐ右下」に配置） ========
  Widget _buildNormalSubjectFollowButton() {
    final isFollowed = _isFollowedForNormal;
    final label = isFollowed ? 'フォロー中' : 'フォロー';
    final color = isFollowed ? Colors.grey : const Color(0xFF0ABAB5);

    return InkWell(
      onTap: _toggleNormalSubjectFollow,  // ここがクリック時のイベント
      child: Container(
        width: 120,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body全体を大きめのColumn/SingleChildScrollView等で包む
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0ABAB5)),
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                // ここで十分に高さを確保、あるいは余白を入れてボタンが画面に収まるようにする
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8, 
                  // ↑ 必要なら調整。画面の8割ぐらいにしておく例

                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // =====================
                      // メインのスクロール内容
                      // =====================
                      Positioned.fill(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.topCenter,
                              child: _buildSubjectNameButton(context),
                            ),
                            const SizedBox(height: 40),

                            // TOEIC/TOEFL/英検 はレベルごとのフォローボタン一覧を表示
                            if (!_isNormalSubject)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: _buildMultiLevelFollowList(),
                              ),
                          ],
                        ),
                      ),

                      // =====================
                      // 通常教科のフォローボタン
                      // =====================
                      if (_isNormalSubject)
                        Positioned(
                          // 教科名ボタンの「少し下・右寄せ」に配置
                          top: 60, // 調整値
                          right: 30,
                          child: _buildNormalSubjectFollowButton(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
