import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Widget/post_image_gallery.dart';
import '../models/User_post_approval_model.dart';

class UserPostApproval extends StatelessWidget {
  final UserPostApprovalModel post;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback? onDelete; // THÊM: callback xóa bài

  const UserPostApproval({
    Key? key,
    required this.post,
    required this.onApprove,
    required this.onReject,
    this.onDelete, // NHẬN CALLBACK XÓA
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isPending = post.status == 'pending';
    final bool isRejected = post.status == 'rejected';

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar + Tên + Trạng thái + Nút 3 chấm (nếu không pending)
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.transparent,
                  backgroundImage: post.avatar.isNotEmpty
                      ? NetworkImage(post.avatar)
                      : NetworkImage(
                          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(post.authorName)}&background=random&color=fff&bold=true',
                        ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Ngày ${_formatDate(post.date)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // Trạng thái
                _buildStatusBadge(post.status),

                // Nút 3 chấm: chỉ hiện khi KHÔNG còn chờ duyệt
                if (!isPending && !isRejected)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Xóa bài viết',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete?.call(); // Gọi hàm xóa
                      }
                    },
                  ),
              ],
            ),

            SizedBox(height: 12),

            // Nội dung bài viết
            Text(post.content, style: TextStyle(fontSize: 14, height: 1.5)),

            SizedBox(height: 12),

            // Ảnh (nếu có)
            if (post.imageUrls.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: PostImageGallery(imageUrls: post.imageUrls),
              ),
            SizedBox(height: 12),

            // Nút Duyệt / Từ chối: chỉ hiện khi đang chờ duyệt
            if (isPending)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton('Từ chối', Colors.red, onReject),
                  SizedBox(width: 32),
                  _buildActionButton('Duyệt', Colors.green, onApprove),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case 'approved':
        color = Colors.green;
        text = 'Đã duyệt';
        icon = Icons.check_circle_outline;
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Bị từ chối';
        icon = Icons.cancel_outlined;
        break;
      default:
        color = Colors.orange;
        text = 'Chờ duyệt';
        icon = Icons.hourglass_empty;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final postDate = DateTime(date.year, date.month, date.day);

    if (postDate == today) {
      return 'Hôm nay';
    } else if (postDate == yesterday) {
      return 'Hôm qua';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
