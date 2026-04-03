import 'dart:io';

import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Profile/Widget/avatarWidget.dart';
import 'package:giao_tiep_sv_user/Widget/post_image_gallery.dart';
import '../models/personal_post_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class PersonalPostItemWidget extends StatefulWidget {
  final PersonalPostModel post;
  final void Function(String postId, List<String> imageUrls) onDelete;
  final String avatarUrl;
  final File? avatarFile;
  final String currentUserName;
  final String groupId;

  const PersonalPostItemWidget({
    super.key,
    required this.post,
    required this.onDelete,
    required this.avatarUrl,
    this.avatarFile,
    required this.currentUserName,
    required this.groupId,
  });

  @override
  State<PersonalPostItemWidget> createState() => _PersonalPostItemWidgetState();
}

class _PersonalPostItemWidgetState extends State<PersonalPostItemWidget> {
  @override
  void initState() {
    super.initState();
  }

  void _showDeleteConfirmation(BuildContext itemContext) {
    print('MỞ DIALOG TỪ ITEM - postId: ${widget.post.id}');

    showDialog(
      context: itemContext,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        // context này là của dialog
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Xóa bài viết'),
          ],
        ),
        content: const Text('Bài viết sẽ bị xóa vĩnh viễn. Bạn có chắc chắn?'),
        actions: [
          TextButton(
            onPressed: () {
              print('DIALOG: NHẤN HỦY');
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              print('DIALOG: NHẤN XÓA → GỌI onDelete');
              widget.onDelete(widget.post.id, widget.post.imageUrls);
              Navigator.pop(dialogContext, true); // Đóng dialog
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Colors.grey, // màu viền
          width: 0.3,
        ),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với thông tin người đăng và menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    AvatarWidget(
                      avatarUrl: widget.avatarUrl,
                      avatarFile: widget.avatarFile,
                      radius: 25,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.userName ?? "Ẩn danh",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Nhóm: ${widget.post.groupName}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          _formatDate(widget.post.createdAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      print('MENU: CHỌN XÓA → MỞ DIALOG');
                      _showDeleteConfirmation(context);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text('Xóa', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            // Tiêu đề bài viết
            Text(
              widget.post.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 12),
            if (widget.post.imageUrls.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: PostImageGallery(imageUrls: widget.post.imageUrls),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
