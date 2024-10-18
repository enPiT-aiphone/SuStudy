import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_grammar_short_sentence_toiec.dart';  // 追加フォームのインポート
import 'view_grammar_short_sentence_detail_toeic.dart';  // 詳細ページのインポート

class ViewShortSentences extends StatelessWidget {
  final String level;  // レベルを動的に渡す

  const ViewShortSentences({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View TOEIC Short Sentences ($level)'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('English_Skills')
            .doc('TOEIC')
            .collection(level)
            .doc('Grammar')
            .collection('Short_Sentence')
            .orderBy('Question_id')  // Question_idで昇順に並べる
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          var documents = snapshot.data!.docs;

          if (documents.isEmpty) {
            return const Center(
              child: Text('No short sentences available'),
            );
          }

          return ListView.separated( // ListView.builder を ListView.separated に変更
            itemCount: documents.length,
            itemBuilder: (context, index) {
              var sentenceData = documents[index];
              var docId = sentenceData.id;  // ドキュメントIDの取得

              return Dismissible(
                key: Key(docId),
                direction: DismissDirection.endToStart,  // 右から左へのスワイプ
                background: Container(
                  color: Colors.red,
                  padding: const EdgeInsets.only(right: 20),
                  alignment: Alignment.centerRight,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Confirm Deletion"),
                        content: Text("Are you sure you want to delete '${sentenceData['Question']}'?"),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text("Delete"),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (direction) {
                  // ドキュメントの削除処理
                  FirebaseFirestore.instance
                      .collection('English_Skills')
                      .doc('TOEIC')
                      .collection(level)
                      .doc('Grammar')
                      .collection('Short_Sentence')
                      .doc(docId)
                      .delete();

                  // スナックバーで削除を通知
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${sentenceData['Question']} deleted"),
                    ),
                  );
                },
                child: ListTile(
                  title: Text('${sentenceData['Question_id']}, ${sentenceData['Question'] ?? 'No Question'}'),
                  subtitle: Text('      ${sentenceData['JPN_Translation'] ?? 'No Translation'}'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GrammarShortSentenceDetailPage(
                          sentenceData: sentenceData,
                          level: level,  // レベルも渡す
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            separatorBuilder: (context, index) => const Divider(),  // 各項目の間に区切り線を追加
          );
        },
      ),
      // FloatingActionButtonの追加
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 追加フォームへのナビゲーション
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddGrammarShortSentenceToeic(level: level),  // 追加フォームへ遷移
            ),
          );
        },  // プラスボタンアイコン
        tooltip: 'Add Short Sentence',
        child: Icon(Icons.add),  // ツールチップ
      ),
    );
  }
}
