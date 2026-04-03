import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

class SavedPostsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> streamSavedPosts(
    String studentId, {
    bool sortDescending = true,
  }) {
    if (studentId.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('Post_save')
        .where('user_id', isEqualTo: studentId)
        .orderBy('create_at', descending: sortDescending)
        .snapshots()
        .asyncMap((saveSnapshot) async {
          final postIds = saveSnapshot.docs
              .map((d) => d['post_id'] as String)
              .toList();

          if (postIds.isEmpty) return [];

          final List<Map<String, dynamic>> results = [];

          await Future.wait(
            postIds.map((postId) async {
              try {
                final postDoc = await _firestore
                    .collection('Post')
                    .doc(postId)
                    .get();

                // Nếu bài viết đã bị xóa → xóa luôn bản ghi lưu
                if (!postDoc.exists) {
                  print("Post đã bị xóa: $postId → Xóa bản ghi lưu");

                  final saveDocToDelete = saveSnapshot.docs.firstWhereOrNull(
                    (d) => d['post_id'] == postId,
                  );
                  if (saveDocToDelete != null) {
                    await saveDocToDelete.reference.delete();
                  }
                  return; // Không thêm vào danh sách
                }

                final data = postDoc.data()!;
                data['id'] = postDoc.id;

                // Thời gian lưu bài
                final saveDoc = saveSnapshot.docs.firstWhereOrNull(
                  (d) => d['post_id'] == postId,
                );
                data['saved_at'] = (saveDoc?['create_at'] as Timestamp?)
                    ?.toDate();

                // === LẤY TÊN NGƯỜI ĐĂNG ===
                final String? postUserId = data['user_id'] as String?;
                if (postUserId != null) {
                  final userDoc = await _firestore
                      .collection('Users')
                      .doc(postUserId)
                      .get();
                  if (userDoc.exists) {
                    final userData = userDoc.data()!;
                    data['user_name'] =
                        userData['fullname'] as String? ?? 'Ẩn danh';
                  } else {
                    data['user_name'] = 'Ẩn danh';
                  }
                } else {
                  data['user_name'] = 'Ẩn danh';
                }

                // === LẤY TÊN NHÓM (field 'name' trong collection Groups) ===
                final String? groupId = data['group_id'] as String?;
                if (groupId != null && groupId.isNotEmpty) {
                  try {
                    final groupDoc = await _firestore
                        .collection('Groups')
                        .doc(groupId)
                        .get();

                    if (groupDoc.exists) {
                      final groupData = groupDoc.data()!;
                      data['group_name'] =
                          groupData['name'] as String? ?? 'Nhóm không tên';
                    } else {
                      data['group_name'] = 'Nhóm đã bị xóa';
                    }
                  } catch (e) {
                    data['group_name'] = 'Lỗi tải nhóm';
                  }
                } else {
                  data['group_name'] = 'Không có nhóm';
                }

                results.add(data);
              } catch (e) {
                print("LỖI khi xử lý post $postId: $e");
              }
            }),
          );

          return results;
        });
  }

  /// Xóa bài đã lưu
  Future<void> unsavePost(String studentId, String postId) async {
    if (studentId.isEmpty) return;

    final snapshot = await _firestore
        .collection('Post_save')
        .where('user_id', isEqualTo: studentId)
        .where('post_id', isEqualTo: postId)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Lưu bài viết
  Future<void> savePost(String studentId, String postId) async {
    if (studentId.isEmpty) return;

    final exists = await _firestore
        .collection('Post_save')
        .where('user_id', isEqualTo: studentId)
        .where('post_id', isEqualTo: postId)
        .limit(1)
        .get();

    if (exists.docs.isNotEmpty) return;

    await _firestore.collection('Post_save').add({
      'user_id': studentId,
      'post_id': postId,
      'create_at': FieldValue.serverTimestamp(),
    });
  }
}
