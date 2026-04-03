import 'package:giao_tiep_sv_user/Data/faculty.dart';

class ProfileModel {
  String name;
  String email;
  String address;
  String phone;
  String avatarUrl;
  Faculty faculty;
  String roleId;

  ProfileModel({
    required this.name,
    required this.email,
    required this.address,
    required this.phone,
    required this.avatarUrl,
    required this.faculty,
    required this.roleId,
  });

  // Copy để dễ cập nhật
  ProfileModel copyWith({
    String? name,
    String? email,
    String? address,
    String? phone,
    String? avatarUrl,
    Faculty? faculty,
    String? roleId,
  }) {
    return ProfileModel(
      name: name ?? this.name,
      email: email ?? this.email,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      faculty: faculty ?? this.faculty,
      roleId: roleId ?? this.roleId,
    );
  }
}
