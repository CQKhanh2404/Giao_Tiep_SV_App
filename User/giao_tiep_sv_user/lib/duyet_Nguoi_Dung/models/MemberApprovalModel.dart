// MemberApprovalModel.dart
class MemberApprovalModel {
  final String id;
  final String userId;
  final String fullName;
  final String avatar;
  final String groupId;
  final String role;
  String status;
  final DateTime joinedAt;

  // THÊM MỚI
  final String? faculty;
  final String? facultyId;
  final String? academicYear;

  MemberApprovalModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.avatar,
    required this.groupId,
    required this.role,
    required this.status,
    required this.joinedAt,
    this.faculty,
    this.facultyId,
    this.academicYear,
  });

  // Cập nhật copyWith
  MemberApprovalModel copyWith({
    String? status,
    String? faculty,
    String? facultyId,
    String? academicYear,
  }) {
    return MemberApprovalModel(
      id: id,
      userId: userId,
      fullName: fullName,
      avatar: avatar,
      groupId: groupId,
      role: role,
      status: status ?? this.status,
      joinedAt: joinedAt,
      faculty: faculty ?? this.faculty,
      facultyId: facultyId ?? this.facultyId,
      academicYear: academicYear ?? this.academicYear,
    );
  }

  // Map int → String
  static String mapStatus(int status) {
    switch (status) {
      case 0:
        return 'pending';
      case 1:
        return 'approved';
      case 2:
        return 'rejected';
      default:
        return 'pending';
    }
  }
}
