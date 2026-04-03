import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/post_interaction_service.dart';

class CommentSheetContent extends StatefulWidget {
  final String postId;
  final Map<String, dynamic> post;
  final PostInteractionService interactionService;
  final String Function(String) getGroupNameFromId;
  final void Function(int) onCommentsCountUpdate;

  const CommentSheetContent({
    super.key,
    required this.postId,
    required this.post,
    required this.interactionService,
    required this.getGroupNameFromId,
    required this.onCommentsCountUpdate,
  });

  @override
  State<CommentSheetContent> createState() => _CommentSheetContentState();
}

class _CommentSheetContentState extends State<CommentSheetContent> {
  final TextEditingController commentCtrl = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  bool _isLoadingComments = true;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  @override
  void dispose() {
    commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchComments() async {
    final fetched = await widget.interactionService.fetchComments(
      widget.postId,
    );
    if (mounted) {
      setState(() {
        _comments = fetched;
        _isLoadingComments = false;
      });
    }
  }

  Future<void> _handleSendComment() async {
    String val = commentCtrl.text.trim();
    if (val.isEmpty) return;

    final newComment = {
      "name": widget.interactionService.userFullname,
      "text": val,
      "isNew": true,
      "avatar": "https://picsum.photos/seed/user/50",
    };

    setState(() {
      _comments.add(newComment);
    });

    commentCtrl.clear();
    FocusScope.of(context).unfocus();

    final success = await widget.interactionService.addComment(
      postId: widget.postId,
      content: val,
    );

    if (!mounted) return;

    if (!success) {
      setState(() {
        _comments.removeLast();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lỗi: Không gửi được bình luận!"),
          backgroundColor: Colors.red,
        ),
      );
    }

    widget.onCommentsCountUpdate(_comments.length);
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double sheetHeight = screenHeight * 0.85;

    return Container(
      height: sheetHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
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
          // BẮT ĐẦU CẤU TRÚC THÔNG TIN BÀI VIẾT MỚI (THAY THẾ LISTTILE)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                    widget.post["avatar"] ??
                        "https://cellphones.com.vn/sforum/wp-content/uploads/2023/10/avatar-trang-4.jpg",
                  ),
                ),
                const SizedBox(width: 10),
                // 2. Khu vực nội dung bài viết
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hàng 1: Tên người đăng
                      Text(
                        widget.post["fullname"] ?? "Ẩn danh",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1, // Giới hạn 1 dòng
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Hàng 2: Tiêu đề bài viết
                      Text(
                        "Tiêu đề: ${widget.post["title"] ?? "Không có tiêu đề"}",
                        maxLines: 1, // Giới hạn 1 dòng
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      // Hàng 3: Tên nhóm
                      Text(
                        "Nhóm: ${widget.getGroupNameFromId(widget.post["group_id"] as String? ?? 'UNKNOWN')}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        maxLines: 1, // Giới hạn 1 dòng
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),
          Expanded(
            child: _isLoadingComments
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
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
                              backgroundImage: NetworkImage(
                                comment["avatar"] ??
                                    "https://picsum.photos/seed/default/50",
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      comment["name"] ?? "Ẩn danh",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      comment["text"] ??
                                          comment["content"] ??
                                          "",
                                      style: const TextStyle(fontSize: 14),
                                    ),
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
          Padding(
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 8,
            ),
            child: TextField(
              controller: commentCtrl,
              decoration: InputDecoration(
                hintText: "Viết bình luận...",
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _handleSendComment,
                ),
              ),
              onSubmitted: (val) => _handleSendComment(),
            ),
          ),
        ],
      ),
    );
  }
}
