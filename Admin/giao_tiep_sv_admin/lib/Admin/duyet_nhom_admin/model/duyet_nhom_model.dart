import 'package:cloud_firestore/cloud_firestore.dart';

class DuyetNhomAdminModel {
  final String id;
  final String name;
  final String description;
  final String avt;
  final Map<String, dynamic> createdBy;
  final Map<String, dynamic> facultyId;
  final int statusId;
  final int typeGroup;
  final bool approvalMode;
  final DateTime? createdAt;

  DuyetNhomAdminModel({
    required this.id,
    required this.name,
    required this.description,
    required this.avt,
    required this.createdBy,
    required this.facultyId,
    required this.statusId,
    required this.typeGroup,
    required this.approvalMode,
    this.createdAt,
  });

  factory DuyetNhomAdminModel.fromMap(Map<String, dynamic> map) {
    return DuyetNhomAdminModel(
      id: _parseString(map['id']),
      name: _parseString(map['name']),
      description: _parseString(map['description']),
      avt: _parseString(map['avt']),
      createdBy: _parseMap(map['created_by']),
      facultyId: _parseMap(map['faculty_id']),
      statusId: _parseInt(map['id_status']),
      typeGroup: _parseInt(map['type_group']),
      approvalMode: _parseBool(map['approval_mode']),
      createdAt: _parseCreatedAt(map['created_at']),
    );
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static DateTime? _parseCreatedAt(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) return value.toDate();

    if (value is String) return DateTime.tryParse(value);

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    return null;
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value == 1;
    return false;
  }

  static Map<String, dynamic> _parseMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.cast<String, dynamic>();
    return {};
  }

  String get facultyName {
    if (facultyId.isEmpty) return 'Không xác định';

    final value = facultyId.values.first;

    if (value == null) return 'Không xác định';

    return value.toString();
  }

  GroupStatus get status {
    switch (statusId) {
      case 1:
        return GroupStatus.approved;
      case 2:
        return GroupStatus.rejected;
      default:
        return GroupStatus.pending;
    }
  }

  // Lấy tên người tạo
  String get creator {
    if (createdBy.isNotEmpty) {
      // Lấy giá trị đầu tiên trong map
      final firstValue = createdBy.values.first;
      return firstValue is String ? firstValue : firstValue.toString();
    }
    return 'Không xác định';
  }

  // Format ngày dd/MM/yyyy
  String get createdAtFormatted {
    if (createdAt == null) return '';
    final d = createdAt!;
    String day = d.day.toString().padLeft(2, '0');
    String month = d.month.toString().padLeft(2, '0');
    String year = d.year.toString();
    return '$day/$month/$year';
  }
}

enum GroupStatus { pending, approved, rejected }
