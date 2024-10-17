import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'view_word_deteil_toefl.dart';  // 詳細ページのインポート
import 'add_word_toefl.dart';  // データ追加用のフォーム

class ViewToeflWord extends StatelessWidget {
  final String level;  // レベルを動的に渡す

  ViewToeflWord({required this.level});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View TOEFL Words ($level)'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('English_Skills')
            .doc('TOEFL')
            .collection(level)
            .doc('Words')
            .collection('Word')
            .orderBy('Word_id')  // Word_idでソート
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          var documents = snapshot.data!.docs;

          if (documents.isEmpty) {
            return Center(
              child: Text('No words available'),
            );
          }

          return ListView.separated(  // ListView.builder を ListView.separated に変更
            itemCount: documents.length,
            itemBuilder: (context, index) {
              var wordData = documents[index];
              var docId = wordData.id;  // ドキュメントIDの取得

              return Dismissible(
                key: Key(docId),
                direction: DismissDirection.endToStart,  // 右から左へのスワイプ
                background: Container(
                  color: Colors.red,
                  padding: EdgeInsets.only(right: 20),
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Confirm Deletion"),
                        content: Text("Are you sure you want to delete '${wordData['Word']}'?"),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text("Delete"),
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
                      .doc('TOEFL')
                      .collection(level)
                      .doc('Words')
                      .collection('Word')
                      .doc(docId)
                      .delete();

                  // スナックバーで削除を通知
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${wordData['Word']} deleted"),
                    ),
                  );
                },
                child: ListTile(
                  title: Text(wordData['Word'] ?? 'No Word'),
                  subtitle: Text('ID: ${wordData['Word_id'] ?? 'No ID'}'),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WordDetailToeflPage(
                          wordData: wordData, 
                          level: level,  // 渡されたlevelを詳細ページにも渡す
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            separatorBuilder: (context, index) => Divider(),  // 各項目の間に線を追加
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddWordToefl(level: level), // データ追加ページへ遷移
            ),
          );
        },
        child: Icon(Icons.add),  // プラスアイコン
        tooltip: 'Add Word',
      ),
    );
  }
}
