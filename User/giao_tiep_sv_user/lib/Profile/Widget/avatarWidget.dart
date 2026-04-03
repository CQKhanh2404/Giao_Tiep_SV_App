import 'dart:io';
import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final String avatarUrl;
  final File? avatarFile;
  final double radius;

  const AvatarWidget({
    super.key,
    required this.avatarUrl,
    this.avatarFile,
    this.radius = 35,
  });

  @override
  Widget build(BuildContext context) {
    // Ưu tiên hiển thị ảnh local trước
    if (avatarFile != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: FileImage(avatarFile!),
      );
    } else if (avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(avatarUrl),
      );
    } else {
      // Fallback nếu không có avatar
      return CircleAvatar(
        radius: radius,
        child: Icon(Icons.person, size: radius * 0.8),
      );
    }
  }
}
