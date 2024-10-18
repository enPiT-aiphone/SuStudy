import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GrammarShortSentenceDetailPage extends StatefulWidget {
  final DocumentSnapshot sentenceData;
  final String level;  // 渡されたレベル

  const GrammarShortSentenceDetailPage({super.key, required this.sentenceData, required this.level});

  @override
  _GrammarShortSentenceDetailPageState createState() => _GrammarShortSentenceDetailPageState();
}

class _GrammarShortSentenceDetailPageState extends State<GrammarShortSentenceDetailPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController questionIdController;
  late TextEditingController questionController;
  late TextEditingController answerController;
  late TextEditingController answerAController;
  late TextEditingController answerBController;
  late TextEditingController answerCController;
  late TextEditingController answerDController;
  late TextEditingController categoryController;
  late TextEditingController explanation1Controller;
  late TextEditingController explanation2Controller;
  late TextEditingController explanation3Controller;
  late TextEditingController explanation4Controller;
  late TextEditingController explanation5Controller;
  late TextEditingController jpnTranslationController;
  late TextEditingController tipsController;

  @override
  void initState() {
    super.initState();

    // 初期値を設定
    questionIdController = TextEditingController(text: widget.sentenceData['Question_id'].toString());
    questionController = TextEditingController(text: widget.sentenceData['Question']);
    answerController = TextEditingController(text: widget.sentenceData['Answer']);
    answerAController = TextEditingController(text: widget.sentenceData['Answer_A']);
    answerBController = TextEditingController(text: widget.sentenceData['Answer_B']);
    answerCController = TextEditingController(text: widget.sentenceData['Answer_C']);
    answerDController = TextEditingController(text: widget.sentenceData['Answer_D']);
    categoryController = TextEditingController(text: widget.sentenceData['Category']);
    explanation1Controller = TextEditingController(text: widget.sentenceData['Explanation_1']);
    explanation2Controller = TextEditingController(text: widget.sentenceData['Explanation_2']);
    explanation3Controller = TextEditingController(text: widget.sentenceData['Explanation_3']);
    explanation4Controller = TextEditingController(text: widget.sentenceData['Explanation_4']);
    explanation5Controller = TextEditingController(text: widget.sentenceData['Explanation_5']);
    jpnTranslationController = TextEditingController(text: widget.sentenceData['JPN_Translation']);
    tipsController = TextEditingController(text: widget.sentenceData['Tips']);
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      // Question_idを整数に変換して保存
      int? questionId;
      try {
        questionId = int.parse(questionIdController.text);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question ID must be a valid number')),
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection('English_Skills')
          .doc('TOEIC')
          .collection(widget.level)  // 渡されたlevelを使用
          .doc('Grammar')
          .collection('Short_Sentence')
          .doc(widget.sentenceData.id)
          .update({
        'Question_id': questionId,
        'Question': questionController.text,
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
        'Tips': tipsController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved successfully')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Short Sentence Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextFormField('Question ID (Number)', questionIdController),
              _buildTextFormField('Question', questionController),
              _buildTextFormField('Answer', answerController),
              _buildTextFormField('Answer A', answerAController),
              _buildTextFormField('Answer B', answerBController),
              _buildTextFormField('Answer C', answerCController),
              _buildTextFormField('Answer D', answerDController),
              _buildTextFormField('Category', categoryController),
              _buildTextFormField('Explanation 1', explanation1Controller),
              _buildTextFormField('Explanation 2', explanation2Controller),
              _buildTextFormField('Explanation 3', explanation3Controller),
              _buildTextFormField('Explanation 4', explanation4Controller),
              _buildTextFormField('Explanation 5', explanation5Controller),
              _buildTextFormField('JPN Translation', jpnTranslationController),
              _buildTextFormField('Tips', tipsController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
        ),
      ),
    );
  }
}
