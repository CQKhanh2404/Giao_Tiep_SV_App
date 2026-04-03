// more_options_button_widget.dart
import 'package:flutter/material.dart';

class MoreOptionsButtonWidget extends StatelessWidget {
  final String itemTitle;
  final String postId; // THÊM: postId
  final Function(String) onDelete; // THAY ĐỔI: nhận String

  const MoreOptionsButtonWidget({
    super.key,
    required this.itemTitle,
    required this.postId,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text('Xóa khỏi mục đã lưu', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'delete') {
          _showDeleteConfirmationDialog(context);
        }
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa "$itemTitle" khỏi mục đã lưu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete(postId); // TRUYỀN postId VÀO
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
