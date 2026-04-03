import 'package:cloud_firestore/cloud_firestore.dart';

class SavedItemModel {
  final String id;
  final String title;
  final List<String> images; // ← ĐỔI THÀNH LIST
  final String userId;
  final String userName;
  final String groupName;
  final DateTime? savedAt;
  final String type;

  SavedItemModel({
    required this.id,
    required this.title,
    required this.images, // ← required list
    required this.userId,
    required this.userName,
    required this.groupName,
    this.savedAt,
    this.type = 'post',
  });

  factory SavedItemModel.fromMap(Map<String, dynamic> map) {
    // Xử lý ảnh: lấy hết image_urls, fallback về ['image'] nếu có
    List<String> imageList = [];

    final imageUrls = map['image_urls'] as List<dynamic>?;
    if (imageUrls != null && imageUrls.isNotEmpty) {
      imageList = imageUrls
          .cast<String>()
          .where((url) => url.isNotEmpty)
          .toList();
    } else if (map['image'] != null && (map['image'] as String).isNotEmpty) {
      imageList = [map['image'] as String];
    }

    return SavedItemModel(
      id: map['id'] as String? ?? '',
      title:
          map['content'] as String? ??
          map['title'] as String? ??
          'Không có nội dung',
      images: imageList, // ← truyền hết ảnh
      userId: map['user_id'] as String? ?? 'unknown',
      userName: map['user_name'] as String? ?? 'Ẩn danh',
      groupName: map['group_name'] as String? ?? 'Không rõ nhóm',
      savedAt: map['saved_at'] is Timestamp
          ? (map['saved_at'] as Timestamp).toDate()
          : map['saved_at'] as DateTime?,
      type: map['type'] as String? ?? 'post',
    );
  }
}
