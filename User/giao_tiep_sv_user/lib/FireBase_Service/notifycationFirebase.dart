import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_user/Data/Notifycation.dart';

class Notifycationfirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔥 Lấy danh sách thông báo (realtime)
  Stream<List<Notifycation>> getAllNotifycation() {
    return _firestore
        .collection('Notifycations')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Notifycation.fromFirestore(doc);
      }).toList();
    });
  }
}