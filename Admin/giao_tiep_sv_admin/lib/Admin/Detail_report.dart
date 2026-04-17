import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_admin/FirebaseFirestore/admin_action_service.dart';
import 'package:giao_tiep_sv_admin/data/violation_report.dart';
import 'duyet_nhom_admin/widget/post_card.dart';
import 'package:intl/intl.dart';

/// Màn hình chi tiết báo cáo vi phạm: hiển thị thông tin người bị báo cáo, bài viết và các hành động xử lý
class DetailScreen extends StatelessWidget {
  final ViolationReport report;
  final AdminActionService _service = AdminActionService();

  DetailScreen({super.key, required this.report});

  // Chuyển đổi Timestamp sang chuỗi format
  String _formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      DateTime date = timestamp.toDate();
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    }
    return 'Không rõ thời gian';
  }

  /// Lấy thông tin chi tiết bài viết bị báo cáo từ Firestore
  Future<Map<String, dynamic>?> _fetchPostDetails() async {
    if (report.postId == null || report.postId!.isEmpty) return null;
    try {
      final postDoc = await FirebaseFirestore.instance
          .collection('Post')
          .doc(report.postId!)
          .get();

      if (postDoc.exists) return postDoc.data();
    } catch (e) {
      print('Lỗi tải bài viết: $e');
    }
    return null;
  }

  /// Lấy thông tin người dùng bị báo cáo từ Firestore theo userId
  Future<Map<String, dynamic>?> _fetchUserDetails(String userId) async {
    if (userId.isEmpty) return null;
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (userDoc.exists) return userDoc.data();
    } catch (e) {
      print('Lỗi tải thông tin người dùng: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final String recipientId = report.recipientId ?? '232xxxxxxx';
    final String senderId = report.senderId ?? 'Không rõ';
    final String createdAt = _formatDate(report.createdAt);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chi Tiết',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        // 🚀 Lấy thông tin người dùng trước
        future: _fetchUserDetails(recipientId),
        builder: (context, userSnapshot) {
          // Xử lý trạng thái loading/error cho thông tin người dùng
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (userSnapshot.hasError || !userSnapshot.hasData) {
            // Dùng dữ liệu mặc định nếu không tải được user
            final defaultUser = {
              'fullname': 'Người dùng bị báo cáo',
              'avt': report.avatarUrl,
            };
            return _buildContent(
              context,
              defaultUser,
              recipientId,
              senderId,
              createdAt,
            );
          }

          final userData = userSnapshot.data!;
          final reportedUserName =
              userData['fullname'] ?? 'Người dùng bị báo cáo';

          // Khi có dữ liệu người dùng, xây dựng nội dung chính
          return _buildContent(
            context,
            userData,
            recipientId,
            senderId,
            createdAt,
          );
        },
      ),
    );
  }

  // 🆕 Widget xây dựng nội dung chính sau khi có dữ liệu người dùng
  Widget _buildContent(
    BuildContext context,
    Map<String, dynamic> userData,
    String recipientId,
    String senderId,
    String createdAt,
  ) {
    final reportedUserName = userData['fullname'] ?? 'Người dùng bị báo cáo';
    final avatarUrl = userData['avt'] ?? report.avatarUrl;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // 1. Avatar
          CircleAvatar(
            radius: 60,
            // Sử dụng avatar từ Firestore nếu có
            backgroundImage: NetworkImage(avatarUrl),
            backgroundColor: Colors.grey.shade200,
          ),
          const SizedBox(height: 15),

          // 2. Info người bị báo cáo
          Text(
            reportedUserName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            recipientId,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          _buildInfoRow('Người gửi:', senderId),

          const SizedBox(height: 20),

          // 3. Khung thông tin báo cáo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bị báo cáo lúc: $createdAt',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Title : ${report.title}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  'Lý do : ${report.content}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),

                // Truyền userData vào đây
                _buildViolatingPostWidget(context, userData),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // 4. Nút hành động (Giữ nguyên)
          Row(
            children: <Widget>[
              Expanded(
                child: _buildActionButton(
                  text: 'Cảnh báo',
                  icon: Icons.warning_amber_rounded,
                  color: Colors.amber,
                  onPressed: () {
                    _showActionDialog(
                      context,
                      'Cảnh báo',
                      reportedUserName,
                      recipientId: recipientId,
                      reportDocId: report.docId,
                    );
                  },
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildActionButton(
                  text: 'Khóa tài khoản',
                  icon: Icons.close,
                  color: Colors.red.shade400,
                  onPressed: () {
                    _showActionDialog(
                      context,
                      'Khóa tài khoản',
                      reportedUserName,
                      recipientId: recipientId,
                      reportDocId: report.docId,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------- Widget hiển thị bài viết (Đã chỉnh sửa để nhận User Data) -------
  Widget _buildViolatingPostWidget(
    BuildContext context,
    Map<String, dynamic> userData,
  ) {
    if (report.postId == null || report.postId!.isEmpty) {
      return const Text(
        "Không có ID bài viết vi phạm.",
        style: TextStyle(color: Colors.grey),
      );
    }

    // 1. Dữ liệu người dùng lấy được
    final String userFullName = userData['fullname'] ?? 'Người đăng bài';
    final String userAvatarUrl =
        userData['avt'] ?? 'https://default-avatar-url.jpg';

    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchPostDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Text('Không thể tải bài viết (ID: ${report.postId})');
        }

        final postData = snapshot.data!;
        dynamic fileData = postData['file_url'];

        List<Map<String, String>> filesList = [];
        if (fileData is List) {
          filesList = fileData
              .map((item) => Map<String, String>.from(item))
              .toList();
        } else if (fileData is String && fileData.isNotEmpty) {
          filesList = [
            {'name': 'Tệp đính kèm', 'path': fileData},
          ];
        }

        // 2. Chèn thông tin người dùng vào adaptedPostData
        final adaptedPostData = {
          'id': report.postId,
          'title': postData['content'],
          'content': postData['content'],
          'images': postData['image_urls'] is List
              ? postData['image_urls']
              : (postData['image_urls'] is String
                    ? [postData['image_urls']]
                    : []),
          'files': filesList,
          'date': postData['date_created'] is Timestamp
              ? (postData['date_created'] as Timestamp)
                    .toDate()
                    .toIso8601String()
              : postData['date_created']?.toString(),
          'user_id': postData['user_id'],
          'group_id': postData['group_id'],
          'fullname': userFullName,
          'avatar': userAvatarUrl,
          'group_name': 'Không rõ nhóm',
          'likes': postData['likes'] ?? 0,
          'comments': postData['comments'] ?? 0,
          'isLiked': false,
        };

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 20, thickness: 1, color: Colors.black26),
            const Text(
              "Bài viết bị báo cáo:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            PostCard(
              post: adaptedPostData,
              onCommentPressed: () {},
              onLikePressed: () {},
              onMenuSelected: (value) {},
            ),

            _buildInfoRow('ID Bài viết:', report.postId!),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
      ),
    );
  }

  /// Hiển thị hộp thoại xác nhận trước khi thực hiện hành động (cảnh báo / khóa tài khoản)
  void _showActionDialog(
    BuildContext context,
    String action,
    String userName, {
    String? recipientId,
    String? reportDocId,
  }) {
    final AdminActionService service = AdminActionService();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('$action người dùng'),
          content: Text(
            'Bạn có chắc chắn muốn $action tài khoản $userName không?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text(
                action,
                style: TextStyle(
                  color: action == 'Khóa tài khoản' ? Colors.red : Colors.amber,
                ),
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                bool success = false;
                String message = 'Đã thực hiện hành động.';

                if (action == 'Cảnh báo' &&
                    recipientId != null &&
                    reportDocId != null) {
                  success = await service.sendWarningAndMarkResolved(
                    context,
                    recipientId,
                    reportDocId,
                  );
                  message = success
                      ? '✅ Đã gửi cảnh báo và đánh dấu báo cáo.'
                      : '❌ Lỗi khi gửi cảnh báo.';
                } else if (action == 'Khóa tài khoản' && recipientId != null) {
                  // Cần sửa lại chỗ này nếu bạn đã sửa AdminActionService
                  // để lockUserAccount nhận reportDocId
                  success = await service.lockUserAccount(
                    recipientId,
                    reportDocId ?? '',
                  );
                  message = success
                      ? '✅ Đã khóa tài khoản thành công.'
                      : '❌ Lỗi khi khóa tài khoản.';

                  if (success && reportDocId != null) {}
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
