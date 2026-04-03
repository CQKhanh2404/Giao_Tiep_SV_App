import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalPostModel {
  final String id;
  final String userId;
  final String groupId;
  final String title;
  final List<String> imageUrls;
  final DateTime createdAt;

  String? userName;
  String? groupName;

  PersonalPostModel({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.title,
    required this.imageUrls,
    required this.createdAt,
    this.userName,
    this.groupName,
  });

  PersonalPostModel copyWith({
    String? id,
    String? userId,
    String? groupId,
    String? title,
    List<String>? imageUrls,
    DateTime? createdAt,
    String? userName,
    String? groupName,
  }) {
    return PersonalPostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      groupId: groupId ?? this.groupId,
      title: title ?? this.title,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      userName: userName ?? this.userName,
      groupName: groupName ?? this.groupName,
    );
  }

  factory PersonalPostModel.fromMap(Map<String, dynamic> map, String id) {
    final rawImages = map['image_urls'] ?? [];
    final List<String> imageUrls = rawImages is List
        ? rawImages.cast<String>()
        : (rawImages is String && rawImages.isNotEmpty)
        ? [rawImages]
        : <String>[];

    return PersonalPostModel(
      id: id,
      userId: map['userId'] ?? '',
      groupId: map['group_id'] ?? '',
      title: map['content'] ?? '',
      imageUrls: imageUrls,
      createdAt:
          (map['date_created'] as Timestamp?)?.toDate() ?? DateTime.now(),
      // BỎ HOÀN TOÀN likes, comments, isLiked ở đây
    );
  }

  // Optional: toMap nếu cần update
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'group_id': groupId,
      'content': title,
      'image_urls': imageUrls,
      'date_created': Timestamp.fromDate(createdAt),
    };
  }
}
