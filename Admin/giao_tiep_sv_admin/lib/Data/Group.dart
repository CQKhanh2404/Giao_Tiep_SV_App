import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Model dữ liệu nhóm (cộng đồng hoặc nhóm do sinh viên tạo)
class Group {
  final String id;
  final String name;
  final String description;
  final Map<String, String> created_by;
  final Map<String, dynamic> faculty_id;
  final String avt;
  final int type_group;
  final int status_id;

  Group(
     {
    required this.id,
    required this.name,
    required this.description,
    required this.created_by,
    required this.faculty_id,
    required this.avt,
    required this.type_group,
    required this.status_id
  });


  /// Chuyển đối tượng sang Map để lưu lên Firestore
  Map<String, dynamic> tomap() {
    return {
      'id': id,
      "name": name,
      "description": description,
      'created_by': created_by,
      "faculty_id": faculty_id,
      'avt': avt,
      'type_group': type_group,
      "id_status": status_id
    };
  }

  /// Tạo đối tượng Group từ Map đọc được từ Firestore
  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      created_by: Map<String, String>.from(map['created_by'] ?? {}),
      faculty_id: Map<String, String>.from(map['faculty_id'] ?? {}),
      avt: map['avt'] ?? '',
      type_group: map['type_group'] ?? 0,
      status_id: map['id_status'] ?? 1
    );
  }
}
