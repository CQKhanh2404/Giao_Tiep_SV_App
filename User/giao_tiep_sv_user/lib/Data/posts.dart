import 'package:cloud_firestore/cloud_firestore.dart';

class Posts {
  final String id_post;
  final String user_id;
  final String group_id;
  final String content;
  final String? file_url;
  final DateTime date_created;
  final int status_id;

  Posts({
    required this.id_post,
    required this.user_id,
    required this.group_id,
    required this.content,
    this.file_url,
    required this.date_created,
    required this.status_id,
  });

  // Factory constructor từ Firestore Document
  factory Posts.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?; // Có thể null
    if (data == null) {
      throw Exception("Document data is null");
    }

    return Posts(
      id_post: doc.id, // Dùng Document ID làm id_post
      user_id: data['user_id'] as String? ?? '',
      group_id: data['group_id'] as String? ?? '',
      content: data['content'] as String? ?? '',
      file_url: data['file_url'] as String?,
      date_created:
          (data['date_created'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status_id: data['status_id'] as int? ?? 1,
    );
  }
}
