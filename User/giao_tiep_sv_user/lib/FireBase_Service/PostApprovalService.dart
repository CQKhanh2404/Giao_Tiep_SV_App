// services/post_approval_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_user/duyet_Nguoi_Dung/models/User_post_approval_model.dart';

class PostApprovalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getPostsByStatus({
    required String groupId,
    int limit = 20,
    DocumentSnapshot? startAfter,
    int statusId = -1,
    bool orderDescending = true,
  }) {
    Query query = _firestore
        .collection('Post')
        .where('group_id', isEqualTo: groupId)
        .orderBy('date_created', descending: orderDescending)
        .limit(limit);

    if (statusId >= 0) {
      query = query.where('status_id', isEqualTo: statusId);
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.snapshots();
  }

  //Lấy nhiều user cùng lúc
  Future<Map<String, Map<String, String>>> _getUsersInfo(
    List<String> userIds,
  ) async {
    if (userIds.isEmpty) return {};

    try {
      final snapshots = await _firestore
          .collection('Users')
          .where(FieldPath.documentId, whereIn: userIds)
          .get();

      final Map<String, Map<String, String>> result = {};
      for (var doc in snapshots.docs) {
        result[doc.id] = {
          'fullname': doc['fullname'] ?? 'Ẩn danh',
          'avatar':
              doc['avt'] ??
              'https://cellphones.com.vn/sforum/wp-content/uploads/2023/10/avatar-trang-4.jpg',
        };
      }
      return result;
    } catch (e) {
      print('Lỗi batch user: $e');
      return {};
    }
  }

  Future<List<UserPostApprovalModel>> docsToPostModels(
    List<QueryDocumentSnapshot> docs,
  ) async {
    if (docs.isEmpty) return [];

    // Lấy tất cả user_id
    final userIds = docs
        .map((doc) => doc['user_id'] as String?)
        .where((id) => id != null && id.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();

    // Lấy info user 1 lần
    final usersMap = await _getUsersInfo(userIds);

    final List<UserPostApprovalModel> posts = [];
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final userId = data['user_id'] as String?;
      final userInfo =
          usersMap[userId] ??
          {
            'fullname': 'Ẩn danh',
            'avatar':
                'https://cellphones.com.vn/sforum/wp-content/uploads/2023/10/avatar-trang-4.jpg',
          };

      List<String> images = [];
      if (data['image_urls'] is List) {
        images = List<String>.from(data['image_urls']);
      } else if (data['file_url'] is String &&
          data['file_url'].toString().isNotEmpty) {
        images = [data['file_url']];
      }

      // Lấy status_id từ Firestore
      final int statusId = (data['status_id'] as num?)?.toInt() ?? 0;
      final String status = _statusIdToString(statusId);

      posts.add(
        UserPostApprovalModel(
          id: doc.id,
          authorName: userInfo['fullname']!,
          content: data['content'] ?? '',
          imageUrls: images,
          date: (data['date_created'] as Timestamp).toDate(),
          status: status, // Dùng status thực tế
          reviewType: 'post',
          avatar:
              userInfo['avatar'] ??
              'https://cellphones.com.vn/sforum/wp-content/uploads/2023/10/avatar-trang-4.jpg',
        ),
      );
    }
    return posts;
  }

  String _statusIdToString(int id) {
    switch (id) {
      case 0:
        return 'pending';
      case 1:
        return 'approved';
      case 2:
        return 'rejected';
      default:
        return 'pending';
    }
  }

  Future<void> approvePost(String postId) async {
    await _firestore.collection('Post').doc(postId).update({'status_id': 1});
  }

  Future<void> rejectPost(String postId) async {
    await _firestore.collection('Post').doc(postId).update({'status_id': 2});
  }

  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('Post').doc(postId).delete();
      print('Đã xóa bài viết $postId');
    } catch (e) {
      print('Lỗi xóa bài viết: $e');
      rethrow;
    }
  }
}
