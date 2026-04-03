// profile_header_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final String avatarUrl;
  final File? avatarFile;
  final String name;
  final String major; // ← Truyền từ ngoài vào
  final String schoolYear; // ← Truyền từ ngoài vào
  final int postCount;

  const ProfileHeaderWidget({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.major,
    required this.schoolYear,
    required this.postCount,
    this.avatarFile,
  });

  Widget _buildAvatar() {
    if (avatarFile != null) {
      return CircleAvatar(radius: 35, backgroundImage: FileImage(avatarFile!));
    } else if (avatarUrl.isNotEmpty) {
      return CircleAvatar(radius: 30, backgroundImage: NetworkImage(avatarUrl));
    } else {
      return const CircleAvatar(
        radius: 30,
        child: Icon(Icons.person, size: 30),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          softWrap: false,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Ưu tiên giữ nguyên số bài viết, chỉ thu nhỏ font nếu cần
                    ],
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: "Hiện có: ",
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                        TextSpan(
                          text: "$postCount bài viết",
                          style: const TextStyle(
                            color: Colors.green, // chỉ đoạn này màu xanh lá
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildInfoItem("Ngành học: ", major),
                  _buildInfoItem("Niên khóa: ", schoolYear),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: label,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
