// comment_section_widget.dart
import 'package:flutter/material.dart';

class CommentSectionWidget extends StatefulWidget {
  final Map<String, dynamic> post;
  final Function(String) onCommentSubmitted;
  final String currentUserName;
  final String? currentUserAvatar;

  const CommentSectionWidget({
    super.key,
    required this.post,
    required this.onCommentSubmitted,
    required this.currentUserName,
    this.currentUserAvatar,
  });

  @override
  State<CommentSectionWidget> createState() => _CommentSectionWidgetState();
}

class _CommentSectionWidgetState extends State<CommentSectionWidget> {
  final TextEditingController _commentController = TextEditingController();

  // ẢNH MẶC ĐỊNH CHO TẤT CẢ USER
  final String _defaultAvatar =
      "https://i.pinimg.com/736x/d4/38/25/d43825dd483d634e59838d919c3cf393.jpg";

  // Lấy avatar - hiện tại dùng chung 1 ảnh cho tất cả user
  String _getAvatarForUser({bool isCurrentUser = false}) {
    // Ưu tiên dùng avatar của user hiện tại nếu có
    if (isCurrentUser && widget.currentUserAvatar != null) {
      return widget.currentUserAvatar!;
    }
    // Dùng ảnh mặc định cho tất cả user
    return _defaultAvatar;
  }

  // Kiểm tra xem comment có phải của user hiện tại không
  bool _isCurrentUserComment(String commentUserName) {
    return commentUserName == widget.currentUserName;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Thanh kéo và Tiêu đề
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Bình luận",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Bài đăng tóm tắt
        ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
              widget.post["avatar"] ?? _defaultAvatar,
            ),
          ),
          title: Text(
            widget.post["user"],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            widget.post["title"],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14),
          ),
          trailing: Text(
            "trong ${widget.post["group"]}",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        const Divider(height: 1),

        // Danh sách Bình luận
        Expanded(
          child: ListView.builder(
            itemCount: widget.post["comments"].length,
            itemBuilder: (context, index) {
              final comment = widget.post["comments"][index];
              final isCurrentUser = _isCurrentUserComment(comment["name"]);

              // Tất cả user dùng chung 1 avatar, chỉ phân biệt bằng tên và màu sắc
              final avatarUrl = _getAvatarForUser(isCurrentUser: isCurrentUser);

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundImage: NetworkImage(avatarUrl),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isCurrentUser
                              ? Colors
                                    .blue[50] // Màu nền khác cho user hiện tại
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                          border: isCurrentUser
                              ? Border.all(color: Colors.blue[200]!)
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  comment["name"],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isCurrentUser
                                        ? Colors.blue[800]
                                        : Colors.black,
                                  ),
                                ),
                                if (isCurrentUser) ...[
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      "Bạn",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              comment["text"],
                              style: TextStyle(
                                fontSize: 14,
                                color: isCurrentUser
                                    ? Colors.blue[900]
                                    : Colors.black87,
                              ),
                            ),
                            if (comment["time"] != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                _formatTime(comment["time"]),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isCurrentUser
                                      ? Colors.blue[600]
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Ô nhập liệu Bình luận
        Padding(
          padding: EdgeInsets.only(
            left: 10,
            right: 10,
            top: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom + 8,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: "Viết bình luận...",
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 15,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send, color: Colors.blue),
                      onPressed: _submitComment,
                    ),
                  ),
                  onSubmitted: (value) => _submitComment(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _submitComment() {
    String commentText = _commentController.text.trim();
    if (commentText.isNotEmpty) {
      widget.onCommentSubmitted(commentText);
      _commentController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
