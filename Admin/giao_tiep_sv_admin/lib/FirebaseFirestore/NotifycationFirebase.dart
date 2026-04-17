import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_admin/Data/Notifycation.dart';

/// Service tương tác với Firestore collection "Notifycations"
class Notifycationfirebase {
  final FirebaseFirestore notiDb = FirebaseFirestore.instance;
  final String collectionName = "Notifycations";

  /// Tạo một thông báo mới trong Firestore
  Future<void> createNotifycation(Notifycation notify) async {
    try {
      // Sử dụng toMap() đã được cập nhật với FieldValue.serverTimestamp()
      await notiDb.collection(collectionName).doc(notify.id).set(notify.toMap());
      print("Gửi thông báo thành công. ID: ${notify.id}");
    } catch (e) {
      print("Lỗi khi tạo thông báo: $e");
      rethrow;
    }
  }

  /// Lấy toàn bộ danh sách thông báo, sắp xếp từ mới nhất
  Stream<List<Notifycation>> getAllNotifycation() {
    return notiDb
        .collection(collectionName)
        .orderBy('created_at', descending: true) 
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
       
        return Notifycation.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Lấy thông báo theo ID người nhận cụ thể
  Stream<List<Notifycation>> getNotificationsForRecipient(String recipientId) {
    return notiDb
        .collection(collectionName)
        .where('user_recipient_id.$recipientId', isGreaterThan: '')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Notifycation.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}