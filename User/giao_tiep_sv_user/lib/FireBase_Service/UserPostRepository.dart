import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_user/Data/posts.dart';
import 'package:giao_tiep_sv_user/Profile/personalPost/models/personal_post_model.dart';

class PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Map<String, String> _userCache = {};
  final Map<String, String> _groupCache = {};

  // Lấy fullname
  Future<String> _getUserName(String userId) async {
    if (_userCache.containsKey(userId)) return _userCache[userId]!;
    final doc = await _firestore.collection('Users').doc(userId).get();
    final name = doc.exists
        ? doc['fullname'] as String? ?? 'Ẩn danh'
        : 'Ẩn danh';
    _userCache[userId] = name;
    return name;
  }

  // Lấy group name
  Future<String> _getGroupName(String groupId) async {
    if (_groupCache.containsKey(groupId)) return _groupCache[groupId]!;
    final doc = await _firestore.collection('Groups').doc(groupId).get();
    final name = doc.exists ? doc['name'] as String? ?? 'Không rõ' : 'Không rõ';
    _groupCache[groupId] = name;
    return name;
  }

  // Thay .asyncMap bằng .map + Future.wait để xử lý song song
  Stream<List<PersonalPostModel>> personalPostsStream(String currentUserId) {
    return _firestore
        .collection('Post')
        .where('user_id', isEqualTo: currentUserId)
        .orderBy('date_created', descending: true)
        .snapshots()
        .map((snapshot) async {
          final futures = snapshot.docs.map((doc) async {
            final data = doc.data();
            final post = Posts.fromFirestore(doc);

            final userName = await _getUserName(post.user_id);
            final groupName = await _getGroupName(post.group_id);

            final imageUrls = _ImageUrls(data);

            return PersonalPostModel(
              id: doc.id,
              userId: post.user_id,
              groupId: post.group_id,
              title: post.content,
              imageUrls: imageUrls,
              createdAt: post.date_created,
              userName: userName,
              groupName: groupName,
            );
          });

          return await Future.wait(futures);
        })
        .asyncMap((future) => future);
  }

  // lấy ảnh từ stoage
  List<String> _ImageUrls(Map<String, dynamic> data) {
    final raw = data['image_urls'];
    if (raw == null) {
      // Hỗ trợ dữ liệu cũ: file_url
      final fileUrl = data['file_url'];
      if (fileUrl is String && fileUrl.isNotEmpty) {
        return [fileUrl];
      }
      return [];
    }
    if (raw is List) {
      return raw
          .cast<String>()
          .where((url) => url.toString().trim().isNotEmpty)
          .toList();
    }
    return [];
  }
}
