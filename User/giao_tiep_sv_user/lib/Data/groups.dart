import 'package:cloud_firestore/cloud_firestore.dart';

class Groups {
  final String id_group;
  final String name;
  final String? description;
  final String created_by;
  final bool approval_mode;
  final int faculty_id;
  final int member_quantity;
  final String? avt;
  final int type_id;

  Groups({
    required this.id_group,
    required this.name,
    this.description,
    required this.created_by,
    required this.approval_mode,
    required this.faculty_id,
    required this.member_quantity,
    this.avt,
    required this.type_id,
  });

  factory Groups.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Groups(
      id_group: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      created_by: data['created_by'] ?? '',
      approval_mode: data['approval_mode'] ?? false,
      faculty_id: data['faculty_id'] ?? 0,
      member_quantity: data['member_quantity'] ?? 0,
      avt: data['avt'],
      type_id: data['type_id'] ?? 0,
    );
  }
}
