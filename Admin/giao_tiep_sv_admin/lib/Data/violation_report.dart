import 'package:cloud_firestore/cloud_firestore.dart';

/// Model dữ liệu báo cáo vi phạm của người dùng
class ViolationReport {
  final String docId;
  final String title;
  final String content;
  final int typeNotify;
  final String? postId;
  final String? senderId;
  final String? recipientId;
  final Timestamp? createdAt;
  final String avatarUrl =
      'https://cdn-icons-png.flaticon.com/512/147/147142.png';

  ViolationReport({
    required this.docId,
    required this.title,
    required this.content,
    required this.typeNotify,
    this.postId,
    this.senderId,
    this.recipientId,
    this.createdAt,
  });

  /// Tạo đối tượng ViolationReport từ DocumentSnapshot đọc từ Firestore.
  /// Xử lý các trường hợp dữ liệu null và định dạng recipientId khác nhau
  factory ViolationReport.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    if (data == null) {
      return ViolationReport(
        docId: doc.id,
        title: 'Dữ liệu trống',
        content: '',
        typeNotify: 0,
        senderId: null,
        recipientId: null,
        createdAt: null,
      );
    }

    String? finalRecipientId;
    final recipientData = data['user_recipient_id'];

    if (recipientData is Map<String, dynamic>) {
      finalRecipientId = recipientData.keys.first;
    } else if (recipientData is String) {
      finalRecipientId = recipientData;
    }

    final String? finalSenderId = data['id_user']?.toString();

    return ViolationReport(
      docId: doc.id,
      title: data['title']?.toString() ?? 'Không có tiêu đề',
      content: data['content']?.toString() ?? 'Không có nội dung',
      typeNotify: (data['type_notify'] is int) ? data['type_notify'] as int : 0,
      postId: data['id_post']?.toString(),
      senderId: finalSenderId,
      recipientId: finalRecipientId,
      createdAt: data['created_at'] as Timestamp?,
    );
  }
}
