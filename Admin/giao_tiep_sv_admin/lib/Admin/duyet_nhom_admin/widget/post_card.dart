import 'package:flutter/material.dart';
import 'dart:io';

class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback onCommentPressed;
  final VoidCallback onLikePressed;
  final void Function(String value)? onMenuSelected;

  const PostCard({
    super.key,
    required this.post,
    required this.onCommentPressed,
    required this.onLikePressed,
    this.onMenuSelected,
  });

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "Không rõ";
    try {
      final DateTime date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return "Không rõ";
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = _extractImages(post);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //  Thông tin người đăng
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(
                      post["avatar"] ??
                          "https://cellphones.com.vn/sforum/wp-content/uploads/2023/10/avatar-trang-4.jpg",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post["fullname"] ?? "Ẩn danh",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatDate(post["date"]),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          //  Tiêu đề
          Text(
            post["title"] ?? "Không có tiêu đề",
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),

          //  Hiển thị ảnh
          if (images.isNotEmpty) _buildImageSection(images),
          if (post["files"] != null && post["files"].isNotEmpty)
            _buildFileSection(List<Map<String, String>>.from(post["files"])),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  ///  Chuẩn hóa danh sách ảnh
  List<String> _extractImages(Map<String, dynamic> post) {
    if (post["images"] is List && (post["images"] as List).isNotEmpty) {
      return (post["images"] as List).cast<String>();
    }

    if (post["image"] != null && post["image"].toString().isNotEmpty) {
      return [post["image"].toString()];
    }

    return [];
  }

  ///  Vẽ phần ảnh — 1 hoặc nhiều
  Widget _buildImageSection(List<String> images) {
    if (images.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _buildImage(images.first),
      );
    } else {
      return SizedBox(
        height: ((images.length / 2).ceil() * 160).toDouble(),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildImage(images[index]),
            );
          },
        ),
      );
    }
  }

  /// Hiển thị file đính kèm
  Widget _buildFileSection(List<Map<String, String>> files) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: files.map((file) {
        final fileName = file["name"] ?? "Tệp không rõ";
        final path = file["path"] ?? "";

        IconData icon;
        if (fileName.endsWith(".pdf")) {
          icon = Icons.picture_as_pdf;
        } else if (fileName.endsWith(".doc") || fileName.endsWith(".docx")) {
          icon = Icons.description;
        } else if (fileName.endsWith(".zip")) {
          icon = Icons.archive;
        } else if (fileName.endsWith(".mp4")) {
          icon = Icons.video_file;
        } else {
          icon = Icons.insert_drive_file;
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.blueAccent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  fileName,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.open_in_new, color: Colors.blueAccent),
                onPressed: () {
                  debugPrint("Mở file: $path");
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  //  Xử lý ảnh — URL hoặc local
  Widget _buildImage(String path) {
    if (path.startsWith("http")) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => _errorImage(),
      );
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => _errorImage(),
      );
    }
  }

  Widget _errorImage() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }
}
