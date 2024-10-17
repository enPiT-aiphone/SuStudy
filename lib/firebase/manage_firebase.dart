import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // データをFirestoreに追加する関数
  Future<void> addData(String collectionName, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collectionName).add(data);
      print("データが正常に追加されました");
    } catch (e) {
      print("エラーが発生しました: $e");
    }
  }
}
