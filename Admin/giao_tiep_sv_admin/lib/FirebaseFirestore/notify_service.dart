import 'package:cloud_firestore/cloud_firestore.dart';

/// Service hỗ trợ tải thông báo theo loại (type_notify)
class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Tải danh sách thông báo loại 0 (báo cáo vi phạm từ người dùng)
  Future<List<Map<String, dynamic>>> loadTypeZeroNotifications() async {
    try {
      final notificationsSnapshot = await _firestore
          .collection('Notifycations')
          .where('type_notify', isEqualTo: 0)
          .get();

      final loadedNotifications = notificationsSnapshot.docs.map((doc) {
        final data = doc.data();

        return {
          'id': doc.id,
          'content': data['content'] ?? 'Không có nội dung',
          'title': data['title'] ?? 'Thông báo mới',
          'created_at': data['created_at'],
          'type_notify': data['type_notify'] ?? 0,
          'id_post': data['id_post'],
          'id_user': data['id_user'],
          'user_recipient_id': data['user_recipient_id'],
        };
      }).toList();

      print('Đã tải ${loadedNotifications.length} thông báo loại 0');
      return loadedNotifications;
    } catch (e, stacktrace) {
      print('🔥 Lỗi tải thông báo loại 0: $e');
      print(stacktrace);
      return [];
    }
  }
}
