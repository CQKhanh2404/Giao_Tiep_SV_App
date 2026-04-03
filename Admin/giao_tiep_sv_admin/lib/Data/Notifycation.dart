import 'package:cloud_firestore/cloud_firestore.dart';

class Notifycation {
  final String id;
  final int type_notify;
  final String title;
  final String content;
  final Map<String, dynamic> user_recipient_ID;
  //  1. Thêm trường created_at kiểu Timestamp (có thể null nếu chưa được tạo)
  final Timestamp? created_at;

  Notifycation(
    this.title, {
    required this.id,
    required this.type_notify,
    required this.content,
    required this.user_recipient_ID,
    // 2. Thêm tham số created_at vào constructor
    this.created_at, 
  });

  // FACTORY CONSTRUCTOR: Chuyển Map từ Firestore sang đối tượng Notifycation
  factory Notifycation.fromMap(Map<String, dynamic> map, String documentId) {
    // Xử lý giá trị null và đảm bảo kiểu dữ liệu
    return Notifycation(
      map['title'] as String? ?? 'No Title',
      id: documentId, // Sử dụng Document ID làm ID đối tượng
      type_notify: map['type_notify'] as int? ?? 1,
      content: map['content'] as String? ?? 'No Content',
      user_recipient_ID: map['user_recipient_id'] as Map<String, dynamic>? ?? {},
      created_at: map['created_at'] as Timestamp?, // Lấy timestamp
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'id': id, 
      "type_notify": type_notify,
      "title": title,
      'content': content,
      "user_recipient_id": user_recipient_ID,
      'created_at': created_at ?? FieldValue.serverTimestamp(), 
    };
  }
}