import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WordDetailPage extends StatefulWidget {
  final DocumentSnapshot wordData;
  final String level;  // 渡されたレベル

  WordDetailPage({required this.wordData, required this.level});

  @override
  _WordDetailPageState createState() => _WordDetailPageState();
}

class _WordDetailPageState extends State<WordDetailPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController wordController;
  late TextEditingController wordIdController;  // Word_idのためのコントローラー
  late TextEditingController engToJpnAnswerController;
  late TextEditingController engToJpnAnswerAController;
  late TextEditingController engToJpnAnswerBController;
  late TextEditingController engToJpnAnswerCController;
  late TextEditingController engToJpnAnswerDController;
  late TextEditingController explanationController;
  late TextEditingController jpnToEngAnswerController;
  late TextEditingController jpnToEngQuestionEngController;
  late TextEditingController jpnToEngQuestionJpnController;
  late TextEditingController meaningNounController;
  late TextEditingController meaningVerbController;
  late TextEditingController meaningPrepositionController;
  late TextEditingController meaningAdverbController;
  late TextEditingController meaningAdjectiveController;
  late TextEditingController phoneticSymbolsController;
  late TextEditingController wordSynonymsController;
  late TextEditingController wordAntonymController;
  late TextEditingController wordRelatedController;
  late TextEditingController wordNounController;
  late TextEditingController wordVerbController;
  late TextEditingController wordPrepositionController;
  late TextEditingController wordAdverbController;
  late TextEditingController wordAdjectiveController;

  @override
  void initState() {
    super.initState();

    // フィールドの初期値を設定
    wordController = TextEditingController(text: widget.wordData['Word']);
    wordIdController = TextEditingController(text: widget.wordData['Word_id'].toString());  // Word_idの初期値を設定
    engToJpnAnswerController = TextEditingController(text: widget.wordData['ENG_to_JPN_Answer']);
    engToJpnAnswerAController = TextEditingController(text: widget.wordData['ENG_to_JPN_Answer_A']);
    engToJpnAnswerBController = TextEditingController(text: widget.wordData['ENG_to_JPN_Answer_B']);
    engToJpnAnswerCController = TextEditingController(text: widget.wordData['ENG_to_JPN_Answer_C']);
    engToJpnAnswerDController = TextEditingController(text: widget.wordData['ENG_to_JPN_Answer_D']);
    explanationController = TextEditingController(text: widget.wordData['Explanation']);
    jpnToEngAnswerController = TextEditingController(text: widget.wordData['JPN_to_ENG_Answer']);
    jpnToEngQuestionEngController = TextEditingController(text: widget.wordData['JPN_to_ENG_Question_ENG']);
    jpnToEngQuestionJpnController = TextEditingController(text: widget.wordData['JPN_to_ENG_Question_JPN']);
    meaningNounController = TextEditingController(text: widget.wordData['Meaning_Noun']);
    meaningVerbController = TextEditingController(text: widget.wordData['Meaning_Verb']);
    meaningPrepositionController = TextEditingController(text: widget.wordData['Meaning_Preposition']);
    meaningAdverbController = TextEditingController(text: widget.wordData['Meaning_Adverb']);
    meaningAdjectiveController = TextEditingController(text: widget.wordData['Meaning_Adjective']);
    phoneticSymbolsController = TextEditingController(text: widget.wordData['Phonetic_Symbols']);
    wordSynonymsController = TextEditingController(text: widget.wordData['Word_Synonyms']);
    wordAntonymController = TextEditingController(text: widget.wordData['Word_Antonym']);
    wordRelatedController = TextEditingController(text: widget.wordData['Word_Related']);
    wordNounController = TextEditingController(text: widget.wordData['Word_Noun']);
    wordVerbController = TextEditingController(text: widget.wordData['Word_Verb']);
    wordPrepositionController = TextEditingController(text: widget.wordData['Word_Preposition']);
    wordAdverbController = TextEditingController(text: widget.wordData['Word_Adverb']);
    wordAdjectiveController = TextEditingController(text: widget.wordData['Word_Adjective']);
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      // Word_idを整数に変換して保存
      int? wordId;
      try {
        wordId = int.parse(wordIdController.text);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Word ID must be a valid number')),
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection('English_Skills')
          .doc('TOEIC')
          .collection(widget.level)  // 渡されたlevelを使用
          .doc('Words')
          .collection('Word')
          .doc(widget.wordData.id)
          .update({
        'Word': wordController.text,
        'Word_id': wordId,  // 更新されたWord_idを保存
        'ENG_to_JPN_Answer': engToJpnAnswerController.text,
        'ENG_to_JPN_Answer_A': engToJpnAnswerAController.text,
        'ENG_to_JPN_Answer_B': engToJpnAnswerBController.text,
        'ENG_to_JPN_Answer_C': engToJpnAnswerCController.text,
        'ENG_to_JPN_Answer_D': engToJpnAnswerDController.text,
        'Explanation': explanationController.text,
        'JPN_to_ENG_Answer': jpnToEngAnswerController.text,
        'JPN_to_ENG_Question_ENG': jpnToEngQuestionEngController.text,
        'JPN_to_ENG_Question_JPN': jpnToEngQuestionJpnController.text,
        'Meaning_Noun': meaningNounController.text,
        'Meaning_Verb': meaningVerbController.text,
        'Meaning_Preposition': meaningPrepositionController.text,
        'Meaning_Adverb': meaningAdverbController.text,
        'Meaning_Adjective': meaningAdjectiveController.text,
        'Phonetic_Symbols': phoneticSymbolsController.text,
        'Word_Synonyms': wordSynonymsController.text,
        'Word_Antonym': wordAntonymController.text,
        'Word_Related': wordRelatedController.text,
        'Word_Noun': wordNounController.text,
        'Word_Verb': wordVerbController.text,
        'Word_Preposition': wordPrepositionController.text,
        'Word_Adverb': wordAdverbController.text,
        'Word_Adjective': wordAdjectiveController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Changes saved successfully')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Word Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextFormField('Word', wordController),
              _buildTextFormField('Word ID (Number)', wordIdController), // Word IDフィールドを追加
              _buildTextFormField('ENG to JPN Answer', engToJpnAnswerController),
              _buildTextFormField('ENG to JPN Answer A', engToJpnAnswerAController),
              _buildTextFormField('ENG to JPN Answer B', engToJpnAnswerBController),
              _buildTextFormField('ENG to JPN Answer C', engToJpnAnswerCController),
              _buildTextFormField('ENG to JPN Answer D', engToJpnAnswerDController),
              _buildTextFormField('Explanation', explanationController),
              _buildTextFormField('JPN to ENG Answer', jpnToEngAnswerController),
              _buildTextFormField('JPN to ENG Question (ENG)', jpnToEngQuestionEngController),
              _buildTextFormField('JPN to ENG Question (JPN)', jpnToEngQuestionJpnController),
              _buildTextFormField('Meaning (Noun)', meaningNounController),
              _buildTextFormField('Meaning (Verb)', meaningVerbController),
              _buildTextFormField('Meaning (Preposition)', meaningPrepositionController),
              _buildTextFormField('Meaning (Adverb)', meaningAdverbController),
              _buildTextFormField('Meaning (Adjective)', meaningAdjectiveController),
              _buildTextFormField('Phonetic Symbols', phoneticSymbolsController),
              _buildTextFormField('Word Synonyms', wordSynonymsController),
              _buildTextFormField('Word Antonym', wordAntonymController),
              _buildTextFormField('Word Related', wordRelatedController),
              _buildTextFormField('Word Noun', wordNounController),
              _buildTextFormField('Word Verb', wordVerbController),
              _buildTextFormField('Word Preposition', wordPrepositionController),
              _buildTextFormField('Word Adverb', wordAdverbController),
              _buildTextFormField('Word Adjective', wordAdjectiveController),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text('Save Changes'),
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
