import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddGrammarShortSentenceToeic extends StatefulWidget {
  final String level;  // レベルを動的に渡す

  AddGrammarShortSentenceToeic({required this.level});

  @override
  _AddGrammarShortSentenceToeicState createState() => _AddGrammarShortSentenceToeicState();
}

class _AddGrammarShortSentenceToeicState extends State<AddGrammarShortSentenceToeic> {
  final _formKey = GlobalKey<FormState>();

  // 各フィールドのコントローラー
  final TextEditingController answerController = TextEditingController();
  final TextEditingController answerAController = TextEditingController();
  final TextEditingController answerBController = TextEditingController();
  final TextEditingController answerCController = TextEditingController();
  final TextEditingController answerDController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController explanation1Controller = TextEditingController();
  final TextEditingController explanation2Controller = TextEditingController();
  final TextEditingController explanation3Controller = TextEditingController();
  final TextEditingController explanation4Controller = TextEditingController();
  final TextEditingController explanation5Controller = TextEditingController();
  final TextEditingController jpnTranslationController = TextEditingController();
  final TextEditingController questionController = TextEditingController();
  final TextEditingController questionIdController = TextEditingController();
  final TextEditingController tipsController = TextEditingController();

  Future<void> addQuestionToFirestore() async {
    if (_formKey.currentState!.validate()) {
      int? questionId;
      try {
        questionId = int.parse(questionIdController.text);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Question ID must be a valid number')),
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection('English_Skills')
          .doc('TOEIC')
          .collection(widget.level)  // 渡されたレベルに基づいて追加
          .doc('Grammar')
          .collection('Short_Sentence')
          .add({
        'Answer': answerController.text,
        'Answer_A': answerAController.text,
        'Answer_B': answerBController.text,
        'Answer_C': answerCController.text,
        'Answer_D': answerDController.text,
        'Category': categoryController.text,
        'Explanation_1': explanation1Controller.text,
        'Explanation_2': explanation2Controller.text,
        'Explanation_3': explanation3Controller.text,
        'Explanation_4': explanation4Controller.text,
        'Explanation_5': explanation5Controller.text,
        'JPN_Translation': jpnTranslationController.text,
        'Question': questionController.text,
        'Question_id': questionId,
        'Tips': tipsController.text,
      });

      // フォームをクリア
      answerController.clear();
      answerAController.clear();
      answerBController.clear();
      answerCController.clear();
      answerDController.clear();
      categoryController.clear();
      explanation1Controller.clear();
      explanation2Controller.clear();
      explanation3Controller.clear();
      explanation4Controller.clear();
      explanation5Controller.clear();
      jpnTranslationController.clear();
      questionController.clear();
      questionIdController.clear();
      tipsController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Question added and form cleared')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Short Sentence for TOEIC ${widget.level}'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: answerController,
                decoration: InputDecoration(labelText: '解答'),
              ),
              TextFormField(
                controller: answerAController,
                decoration: InputDecoration(labelText: '回答A'),
              ),
              TextFormField(
                controller: answerBController,
                decoration: InputDecoration(labelText: '回答B'),
              ),
              TextFormField(
                controller: answerCController,
                decoration: InputDecoration(labelText: '回答C'),
              ),
              TextFormField(
                controller: answerDController,
                decoration: InputDecoration(labelText: '回答D'),
              ),
              TextFormField(
                controller: categoryController,
                decoration: InputDecoration(labelText: 'カテゴリー'),
              ),
              TextFormField(
                controller: explanation1Controller,
                decoration: InputDecoration(labelText: '解説1'),
              ),
              TextFormField(
                controller: explanation2Controller,
                decoration: InputDecoration(labelText: '解説2'),
              ),
              TextFormField(
                controller: explanation3Controller,
                decoration: InputDecoration(labelText: '解説3'),
              ),
              TextFormField(
                controller: explanation4Controller,
                decoration: InputDecoration(labelText: '解説4'),
              ),
              TextFormField(
                controller: explanation5Controller,
                decoration: InputDecoration(labelText: '解説5'),
              ),
              TextFormField(
                controller: jpnTranslationController,
                decoration: InputDecoration(labelText: '問題翻訳'),
              ),
              TextFormField(
                controller: questionController,
                decoration: InputDecoration(labelText: '問題'),
              ),
              TextFormField(
                controller: questionIdController,
                decoration: InputDecoration(labelText: 'Question ID (Number)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Question ID';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: tipsController,
                decoration: InputDecoration(labelText: 'Tips'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: addQuestionToFirestore,
                child: Text('Add Question'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
