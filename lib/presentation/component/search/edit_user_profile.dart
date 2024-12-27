import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _userIdController = TextEditingController();
  final _bioController = TextEditingController();

  Map<String, String> _initialData = {};
  String _occupation = '';
  String _subOccupation = '';

  bool _isLoading = false;
  bool _isButtonEnabled = false;
  String? _userIdError;

  // 職業とサブ職業の選択肢
  final List<String> _occupations = [
    '中学生',
    '高校生',
    '浪人生',
    '大学生',
    '大学院生',
    '社会人'
  ];
  final List<String> _juniorHighGrades = ['1年生', '2年生', '3年生'];
  final List<String> _universityGrades = ['1年生', '2年生', '3年生', '4年生', '5年生', '6年生'];
  final List<String> _graduateCourses = ['修士課程', '博士課程'];
  final List<String> _jobIndustries = [
    'IT・通信・インターネット',
    'メーカー',
    '商社',
    'サービス・レジャー',
    '流通・小売・フード',
    'マスコミ・広告・デザイン',
    '金融・保険',
    'コンサルティング',
    '不動産・建設・設備',
    '運輸・交通・物流・倉庫',
    '環境・エネルギー',
    '公的機関'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Firestoreからデータを取得
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    final userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .get();

    if (userDoc.exists) {
      final data = userDoc.data();
      setState(() {
        _nameController.text = data?['user_name'] ?? '';
        _userIdController.text = data?['user_id'] ?? '';
        _bioController.text = data?['bio'] ?? '';
        _occupation = data?['occupation'] ?? '';
        _subOccupation = data?['sub_occupation'] ?? '';

        _initialData = {
          'user_name': _nameController.text,
          'user_id': _userIdController.text,
          'bio': _bioController.text,
          'occupation': _occupation,
          'sub_occupation': _subOccupation,
        };
      });
    }

    setState(() => _isLoading = false);
  }

  // ボタン状態更新
  void _setButtonState() {
    setState(() {
      _isButtonEnabled = _nameController.text != _initialData['user_name'] ||
          _userIdController.text != _initialData['user_id'] ||
          _bioController.text != _initialData['bio'] ||
          _occupation != _initialData['occupation'] ||
          _subOccupation != _initialData['sub_occupation'];
    });
  }

  // ユーザーIDのバリデーション
  Future<String?> _validateUserIdAsync(String? value) async {
    if (value == null || value.isEmpty) {
      return 'ユーザーIDを入力してください';
    }

    if (!RegExp(r'^[A-Za-z0-9_]+$').hasMatch(value)) {
      return 'ユーザーIDはローマ字(A, a)、アンダーバー(_)、数字(1, 2)のみを使用してください';
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('user_id', isEqualTo: value)
        .get();

    if (snapshot.docs.isNotEmpty && snapshot.docs.first.id != user.uid) {
      return 'このユーザーIDはすでに使われています';
    }

    return null;
  }

  String? _validateUserId(String? value) {
    if (value == null || value.isEmpty) {
      return 'ユーザーIDを入力してください';
    }

    if (!RegExp(r'^[A-Za-z0-9_]+$').hasMatch(value)) {
      return 'ユーザーIDはローマ字(A, a)、アンダーバー(_)、数字(1, 2)のみを使用してください';
    }

    return null;
  }

  Future<void> _checkUserIdAsync(String? value) async {
    final userIdError = await _validateUserIdAsync(value);
    setState(() {
      _userIdError = userIdError;
    });
  }

  // Firestoreに保存
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    await FirebaseFirestore.instance.collection('Users').doc(user.uid).update({
      'user_name': _nameController.text.trim(),
      'user_id': _userIdController.text.trim(),
      'bio': _bioController.text.trim(),
      'occupation': _occupation,
      'sub_occupation': _subOccupation,
    });

    setState(() => _isLoading = false);
    Navigator.pop(context, true);
  }

  // 職業の選択UI
  Widget _buildOccupationSelection() {
    return Card(
      child: ExpansionTile(
        title: Text(_occupation.isNotEmpty ? '職業: $_occupation' : '職業を選択'),
        children: _occupations.map((occupation) {
          return ListTile(
            title: Text(occupation),
            onTap: () {
              setState(() {
                _occupation = occupation;
                _subOccupation = ''; // サブ職業リセット
                _setButtonState();
              });
            },
          );
        }).toList(),
      ),
    );
  }

  // サブ職業の選択UI
  Widget _buildSubOccupationSelection() {
    List<String> options = [];
    if (_occupation == '中学生' || _occupation == '高校生') {
      options = _juniorHighGrades;
    } else if (_occupation == '大学生') {
      options = _universityGrades;
    } else if (_occupation == '大学院生') {
      options = _graduateCourses;
    } else if (_occupation == '社会人') {
      options = _jobIndustries;
    }

    if (options.isEmpty) return const SizedBox.shrink();

    return Card(
      child: ExpansionTile(
        title: Text(
          _subOccupation.isNotEmpty ? '詳細: $_subOccupation' : '詳細情報を選択',
        ),
        children: options.map((sub) {
          return ListTile(
            title: Text(sub),
            onTap: () {
              setState(() {
                _subOccupation = sub;
                _setButtonState();
              });
            },
          );
        }).toList(),
      ),
    );
  }

  // 保存ボタン
  Widget _buildSaveButton() {
    return InkWell(
      onTap: _isButtonEnabled ? _saveProfile : null,
      child: Container(
        height: 35,
        width: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _isButtonEnabled ? const Color(0xFF0ABAB5) : Colors.white,
          border: Border.all(
            color: _isButtonEnabled ? const Color(0xFF0ABAB5) : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          '保存',
          style: TextStyle(
            color: _isButtonEnabled ? Colors.white : Colors.black54,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール編集'),
        actions: [_buildSaveButton()],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(valueColor:  AlwaysStoppedAnimation<Color>(Color(0xFF0ABAB5)),))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                onChanged: _setButtonState,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      child: Text(
                        _nameController.text.isNotEmpty
                            ? _nameController.text[0]
                            : '?',
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      '名前',
                      _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'ユーザー名を入力してください';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      'ユーザーID',
                      _userIdController,
                      validator: (value) => _validateUserId(value),
                      onChanged: (value) async => await _checkUserIdAsync(value),
                    ),
                    _buildTextField('自己紹介', _bioController, maxLines: 3),
                    _buildOccupationSelection(),
                    _buildSubOccupationSelection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1, String? Function(String?)? validator, void Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          errorText: label == 'ユーザーID' ? _userIdError : null,
        ),
      ),
    );
  }
}
