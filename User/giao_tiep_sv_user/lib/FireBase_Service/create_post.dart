import 'package:cloud_firestore/cloud_firestore.dart';

class CreatePostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> uploadPost({
    required String currentUserId,
    required String content,
    required String groupId,
    List<String>? imageUrls,
    String? fileUrl,
  }) async {
    try {
      final postData = {
        "user_id": currentUserId,
        "content": content,
        "group_id": groupId,
        "date_created": FieldValue.serverTimestamp(),
        "image_urls": imageUrls ?? [],
        "status_id": 0, // ✅ BÀI VIẾT MỚI ĐƯỢC ĐẶT LÀ CHỜ DUYỆT (0)
        "likes": 0,
        "comments": 0,
      };

      await _firestore.collection('Post').add(postData);
      print("Đăng bài thành công! Có ${imageUrls?.length ?? 0} ảnh.");
      return true;
    } catch (e) {
      print("LỖI KHI ĐĂNG BÀI: $e");
      return false;
    }
  }
}
