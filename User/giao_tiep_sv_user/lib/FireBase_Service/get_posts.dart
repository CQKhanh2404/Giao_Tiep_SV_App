// File: get_posts.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// Service lấy danh sách bài viết đã được duyệt kèm thông tin người đăng và số liệu tương tác
class GetPosts {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Biến final để lưu userId được truyền vào
  final String currentUserId;

  // Constructor chỉ cần nhận currentUserId
  GetPosts({required this.currentUserId});

  /// Hỗ trợ tra cứu thông tin người dùng từ Collection 'Users'
  Future<Map<String, dynamic>> _fetchUserDetail(String userId) async {
    try {
      final userDoc = await _firestore.collection('Users').doc(userId).get();
      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data()!;
        return {
          "fullname": userData["fullname"] ?? "Ẩn danh",
          "avatar":
              userData["avt"] ??
              "https://cellphones.com.vn/sforum/wp-content/uploads/2023/10/avatar-trang-4.jpg",
        };
      }
    } catch (e) {
      print("Lỗi tra cứu thông tin người dùng: $e");
    }
    return {
      "fullname": "Ẩn danh",
      "avatar":
          "https://cellphones.com.vn/sforum/wp-content/uploads/2023/10/avatar-trang-4.jpg",
    };
  }

  /// Tra cứu tương tác (Like, Comment count) cho từng bài viết
  Future<Map<String, dynamic>> _fetchInteractions(String postId) async {
    final likesSnapshot = await _firestore
        .collection('Post_like')
        .where('id_post', isEqualTo: postId)
        .get();
    final int totalLikes = likesSnapshot.docs.length;

    final commentsSnapshot = await _firestore
        .collection('Post_comment')
        .where('id_post', isEqualTo: postId)
        .get();
    final int totalComments = commentsSnapshot.docs.length;

    final isLikedSnapshot = await _firestore
        .collection('Post_like')
        .where('id_post', isEqualTo: postId)
        .where('id_user', isEqualTo: currentUserId)
        .limit(1)
        .get();
    final bool isLikedByUser = isLikedSnapshot.docs.isNotEmpty;

    return {
      "likes": totalLikes,
      "comments": totalComments,
      "isLiked": isLikedByUser,
    };
  }

  /// Lấy tất cả bài viết từ Firestore với status_id = 1
  Future<List<Map<String, dynamic>>> fetchPosts() async {
    try {
      final snapshot = await _firestore
          .collection('Post')
          .where('status_id', isEqualTo: 1)
          .orderBy('date_created', descending: true)
          .get();

      final postsWithDetails = await Future.wait(
        snapshot.docs.map((doc) async {
          final data = doc.data();
          final postId = doc.id;
          final posterId = data["user_id"] as String?;

          Map<String, dynamic> userDetails = {};
          Map<String, dynamic> interactions = {};

          if (posterId != null && posterId.isNotEmpty) {
            userDetails = await _fetchUserDetail(posterId);
          }

          interactions = await _fetchInteractions(postId);

          return {
            "id": postId,
            "user_id": posterId ?? "Ẩn danh",
            "fullname": userDetails["fullname"] ?? "Ẩn danh",
            "avatar": userDetails["avatar"],
            "group_id": data["group_id"] ?? "Không rõ",
            "title": data["content"] ?? "Không có nội dung",
            "date": (data["date_created"] is Timestamp)
                ? (data["date_created"] as Timestamp).toDate().toString()
                : null,
            "images": data["image_urls"] is List ? data["image_urls"] : [],
            "likes": interactions["likes"],
            "comments": interactions["comments"],
            "isLiked": interactions["isLiked"],
          };
        }).toList(),
      );

      return postsWithDetails;
    } catch (e) {
      print("🔥 Lỗi tải bài viết từ PostService: $e");
      return [];
    }
  }
}
