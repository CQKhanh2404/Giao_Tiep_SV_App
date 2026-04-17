import 'package:cloud_firestore/cloud_firestore.dart';

// Service xử lý các tương tác với bài viết: like, bình luận, đếm số liệu
class PostInteractionService {
  final String userId;
  final String userFullname;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  PostInteractionService({required this.userId, required this.userFullname});

  // ---------------- HÀM HỖ TRỢ NỘI BỘ ----------------
  Future<Map<String, dynamic>> _fetchUserDetail(String userId) async {
    try {
      final userDoc = await _firestore.collection('Users').doc(userId).get();
      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data()!;
        return {
          "fullname": userData["fullName"] ?? userData["fullname"] ?? "Ẩn danh",
          "avatar": userData["avt"] ?? "https://picsum.photos/seed/user/50",
        };
      }
    } catch (e) {
      print("Lỗi tra cứu thông tin người dùng cho comment: $e");
    }
    return {
      "fullname": "Ẩn danh",
      "avatar": "https://picsum.photos/seed/default/50",
    };
  }

  // Toggle Like cho bài viết
  Future<bool> toggleLike(String postId, bool isLiked) async {
    final likeQuery = _firestore
        .collection('Post_like')
        .where('id_post', isEqualTo: postId)
        .where('id_user', isEqualTo: userId);

    if (isLiked) {
      final snapshot = await likeQuery.get();
      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.delete();
      }
    } else {
      await _firestore.collection('Post_like').add({
        'id_post': postId,
        'id_user': userId,
        'create_at': FieldValue.serverTimestamp(),
      });
    }
    return true;
  }

  // Thêm bình luận
  Future<bool> addComment({
    required String postId,
    required String content,
  }) async {
    try {
      await _firestore.collection('Post_comment').add({
        'id_post': postId,
        'id_user': userId,
        'user_name': userFullname,
        'content': content,
        'create_at': FieldValue.serverTimestamp(),
      });
      print('✅ Comment added to post: $postId');
      return true;
    } catch (e) {
      print('❌ Error adding comment: $e');
      return false;
    }
  }

  // Lấy danh sách bình luận với avatar và tên
  Future<List<Map<String, dynamic>>> fetchComments(String postId) async {
    try {
      final snapshot = await _firestore
          .collection('Post_comment')
          .where('id_post', isEqualTo: postId)
          .orderBy('create_at', descending: false)
          .get();

      final commentsFutures = snapshot.docs.map((doc) async {
        final data = doc.data();
        final String commenterId = data['id_user'] as String? ?? "";

        final userDetail = await _fetchUserDetail(commenterId);

        return {
          "name": data['user_name'] ?? userDetail['fullname'],
          "text": data['content'] ?? "",
          "id": doc.id,
          "create_at": data['create_at'],
          "avatar": userDetail['avatar'],
        };
      }).toList();

      return await Future.wait(commentsFutures);
    } catch (e) {
      print('❌ Error fetching comments: $e');
      return [];
    }
  }

  // Lấy số lượng Likes và Comments
  Future<Map<String, int>> getPostInteractionCounts(String postId) async {
    try {
      // Đếm Likes
      final likesSnapshot = await _firestore
          .collection('Post_like')
          .where('id_post', isEqualTo: postId)
          .count()
          .get();

      // Đếm Comments
      final commentsSnapshot = await _firestore
          .collection('Post_comment')
          .where('id_post', isEqualTo: postId)
          .count()
          .get();

      return {
        "likes": likesSnapshot.count ?? 0,
        "comments": commentsSnapshot.count ?? 0,
      };
    } catch (e) {
      print("Lỗi lấy số liệu tương tác: $e");
      return {"likes": 0, "comments": 0};
    }
  }

  // Kiểm tra xem người dùng hiện tại đã like bài viết chưa
  Future<bool> isPostLikedByUser(String postId, String currentUserId) async {
    try {
      final snapshot = await _firestore
          .collection('Post_like')
          .where('id_post', isEqualTo: postId)
          .where('id_user', isEqualTo: currentUserId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty; // Trả về true nếu tìm thấy like của user
    } catch (e) {
      print("Lỗi kiểm tra trạng thái like: $e");
      return false;
    }
  }
}
