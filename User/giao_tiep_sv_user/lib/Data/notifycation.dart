import 'package:cloud_firestore/cloud_firestore.dart';

class Notifycation {
  final String id;
  final String title;
  final String content;
  final int type_notify;
  final Map<String, String> user_recipient_ID;
  final Timestamp? created_at; // ✅ phải có dòng này

  Notifycation({
    required this.id,
    required this.title,
    required this.content,
    required this.type_notify,
    required this.user_recipient_ID,
    this.created_at,
  });

  factory Notifycation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Notifycation(
      id: doc.id,
      title: data['title']?.toString() ?? '',
      content: data['content']?.toString() ?? '',
      type_notify: data['type_notify'] is int
          ? data['type_notify']
          : int.tryParse('${data['type_notify']}') ?? 0,
      user_recipient_ID: _parseRecipientMap(data['user_recipient_id']),
      created_at: data['created_at'] as Timestamp?, //  lấy từ Firestore
    );
  }

  static Map<String, String> _parseRecipientMap(dynamic input) {
    if (input is Map) {
      return input.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }
    return {};
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'type_notify': type_notify,
      'user_recipient_id': user_recipient_ID,
      'created_at': created_at,
    };
  }
}