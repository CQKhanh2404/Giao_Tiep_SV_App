class UserPostApprovalModel {
  final String id;
  final String authorName;
  final String avatar;
  final String content;
  final List<String> imageUrls;
  final DateTime date;
  String status;
  final String reviewType;

  UserPostApprovalModel({
    required this.id,
    required this.authorName,
    required this.avatar,
    required this.content,
    required this.imageUrls,
    required this.date,
    required this.status,
    required this.reviewType,
  });

  UserPostApprovalModel copyWith({
    String? id,
    String? authorName,
    String? avatar,
    String? content,
    List<String>? imageUrls,
    DateTime? date,
    String? status,
    String? reviewType,
  }) {
    return UserPostApprovalModel(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      avatar: avatar ?? this.avatar,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      date: date ?? this.date,
      status: status ?? this.status,
      reviewType: reviewType ?? this.reviewType,
    );
  }
}
