import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddWordToefl extends StatefulWidget {
  final String level;  // レベルを動的に渡す

  const AddWordToefl({super.key, required this.level});

  @override
  _AddWordToeflState createState() => _AddWordToeflState();
}

class _AddWordToeflState extends State<AddWordToefl> {
  final _formKey = GlobalKey<FormState>();

  // 各フィールドのコントローラー
  final TextEditingController wordController = TextEditingController();
  final TextEditingController engToJpnAnswerController = TextEditingController();
  final TextEditingController engToJpnAnswerAController = TextEditingController();
  final TextEditingController engToJpnAnswerBController = TextEditingController();
  final TextEditingController engToJpnAnswerCController = TextEditingController();
  final TextEditingController engToJpnAnswerDController = TextEditingController();
  final TextEditingController explanationController = TextEditingController();
  final TextEditingController jpnToEngAnswerController = TextEditingController();
  final TextEditingController jpnToEngQuestionEngController = TextEditingController();
  final TextEditingController jpnToEngQuestionJpnController = TextEditingController();
  final TextEditingController meaningNounController = TextEditingController();
  final TextEditingController meaningVerbController = TextEditingController();
  final TextEditingController meaningPrepositionController = TextEditingController();
  final TextEditingController meaningAdverbController = TextEditingController();
  final TextEditingController meaningAdjectiveController = TextEditingController();
  final TextEditingController phoneticSymbolsController = TextEditingController();
  final TextEditingController wordSynonymsController = TextEditingController();
  final TextEditingController wordAntonymController = TextEditingController();
  final TextEditingController wordRelatedController = TextEditingController();
  final TextEditingController wordNounController = TextEditingController();
  final TextEditingController wordVerbController = TextEditingController();
  final TextEditingController wordPrepositionController = TextEditingController();
  final TextEditingController wordAdverbController = TextEditingController();
  final TextEditingController wordAdjectiveController = TextEditingController();
  final TextEditingController wordIdController = TextEditingController();

  Future<void> addWordToFirestore() async {
    if (_formKey.currentState!.validate()) {
      int? wordId;
      try {
        wordId = int.parse(wordIdController.text);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Word ID must be a valid number')),
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection('English_Skills')
          .doc('TOEFL')
          .collection(widget.level)  // 渡されたレベルに基づいて追加
          .doc('Words')
          .collection('Word')
          .add({
        'Word': wordController.text,
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
        'Word_id': wordId,
      });

      // フォームをクリア
      wordController.clear();
      engToJpnAnswerController.clear();
      engToJpnAnswerAController.clear();
      engToJpnAnswerBController.clear();
      engToJpnAnswerCController.clear();
      engToJpnAnswerDController.clear();
      explanationController.clear();
      jpnToEngAnswerController.clear();
      jpnToEngQuestionEngController.clear();
      jpnToEngQuestionJpnController.clear();
      meaningNounController.clear();
      meaningVerbController.clear();
      meaningPrepositionController.clear();
      meaningAdverbController.clear();
      meaningAdjectiveController.clear();
      phoneticSymbolsController.clear();
      wordSynonymsController.clear();
      wordAntonymController.clear();
      wordRelatedController.clear();
      wordNounController.clear();
      wordVerbController.clear();
      wordPrepositionController.clear();
      wordAdverbController.clear();
      wordAdjectiveController.clear();
      wordIdController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Word added and form cleared')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Word for TOEFL ${widget.level}'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: wordController,
                decoration: const InputDecoration(labelText: 'Word'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a word';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: engToJpnAnswerController,
                decoration: const InputDecoration(labelText: '英和問題解答'),
              ),
              TextFormField(
                controller: engToJpnAnswerAController,
                decoration: const InputDecoration(labelText: '英和問題解答A'),
              ),
              TextFormField(
                controller: engToJpnAnswerBController,
                decoration: const InputDecoration(labelText: '英和問題解答B'),
              ),
              TextFormField(
                controller: engToJpnAnswerCController,
                decoration: const InputDecoration(labelText: '英和問題解答C'),
              ),
              TextFormField(
                controller: engToJpnAnswerDController,
                decoration: const InputDecoration(labelText: '英和問題解答D'),
              ),
              TextFormField(
                controller: explanationController,
                decoration: const InputDecoration(labelText: '解説'),
              ),
              TextFormField(
                controller: jpnToEngAnswerController,
                decoration: const InputDecoration(labelText: '和英問題解答'),
              ),
              TextFormField(
                controller: jpnToEngQuestionEngController,
                decoration: const InputDecoration(labelText: '和英問題ENG'),
              ),
              TextFormField(
                controller: jpnToEngQuestionJpnController,
                decoration: const InputDecoration(labelText: '和英問題JPN'),
              ),
              TextFormField(
                controller: meaningNounController,
                decoration: const InputDecoration(labelText: '名詞としての意味'),
              ),
              TextFormField(
                controller: meaningVerbController,
                decoration: const InputDecoration(labelText: '動詞としての意味'),
              ),
              TextFormField(
                controller: meaningPrepositionController,
                decoration: const InputDecoration(labelText: '前置詞としての意味'),
              ),
              TextFormField(
                controller: meaningAdverbController,
                decoration: const InputDecoration(labelText: '副詞としての意味'),
              ),
              TextFormField(
                controller: meaningAdjectiveController,
                decoration: const InputDecoration(labelText: '形容詞としての意味'),
              ),
              TextFormField(
                controller: phoneticSymbolsController,
                decoration: const InputDecoration(labelText: '発音記号'),
              ),
              TextFormField(
                controller: wordSynonymsController,
                decoration: const InputDecoration(labelText: '類義語'),
              ),
              TextFormField(
                controller: wordAntonymController,
                decoration: const InputDecoration(labelText: '対義語'),
              ),
              TextFormField(
                controller: wordRelatedController,
                decoration: const InputDecoration(labelText: '関連語'),
              ),
              TextFormField(
                controller: wordNounController,
                decoration: const InputDecoration(labelText: '名詞化単語'),
              ),
              TextFormField(
                controller: wordVerbController,
                decoration: const InputDecoration(labelText: '動詞化単語'),
              ),
              TextFormField(
                controller: wordPrepositionController,
                decoration: const InputDecoration(labelText: '前置詞化単語'),
              ),
              TextFormField(
                controller: wordAdverbController,
                decoration: const InputDecoration(labelText: '副詞化単語'),
              ),
              TextFormField(
                controller: wordAdjectiveController,
                decoration: const InputDecoration(labelText: '形容詞化単語'),
              ),
              TextFormField(
                controller: wordIdController,
                decoration: const InputDecoration(labelText: 'Word ID (Number)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Word ID';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: addWordToFirestore,
                child: const Text('Add Word'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
