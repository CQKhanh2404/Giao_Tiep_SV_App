import 'package:cloud_firestore/cloud_firestore.dart';

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy chi tiết người dùng
  Future<Map<String, dynamic>> _fetchUserDetail(String userId) async {
    try {
      final userDoc = await _firestore.collection('Users').doc(userId).get();
      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data()!;
        return {
          "fullname": userData["fullname"] ?? "Ẩn danh",
          "avatar":
              userData["avt"] ??
              "https://default-avatar-url.jpg", // Đổi URL mặc định
        };
      }
    } catch (e) {
      // Bỏ qua lỗi tra cứu thông tin người dùng
    }
    return {};
  }

  /// 🔎 Chức năng 1: Tìm kiếm Người dùng (theo 'fullname' HOẶC 'email')
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    const String endChar = '\uf8ff';
    final String queryUpper = query;
    final String queryLower = query.toLowerCase();

    // 1. Truy vấn theo 'fullname'
    final fullnameQuery = _firestore
        .collection('Users')
        .where('fullname', isGreaterThanOrEqualTo: queryUpper)
        .where('fullname', isLessThan: queryUpper + endChar)
        .limit(10);

    // 2. Truy vấn theo 'email'
    final emailQuery = _firestore
        .collection('Users')
        .where('email', isGreaterThanOrEqualTo: queryLower)
        .where('email', isLessThan: queryLower + endChar)
        .limit(10);

    try {
      final results = await Future.wait([
        fullnameQuery.get(),
        emailQuery.get(),
      ]);

      final fullnameSnapshot = results[0];
      final emailSnapshot = results[1];

      Set<String> processedIds = {};
      List<Map<String, dynamic>> finalResults = [];

      Map<String, dynamic> _mapUserDocumentToResult(DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          "id": doc.id,
          "fullname": data["fullname"] ?? "Ẩn danh",
          "email": data["email"] ?? "Không rõ",
          "avatar": data["avt"] ?? "https://default-avatar-url.jpg",
          "faculty_id": data["faculty_id"] ?? "Không rõ",
        };
      }

      // Hợp nhất kết quả từ fullname
      for (var doc in fullnameSnapshot.docs) {
        if (!processedIds.contains(doc.id)) {
          processedIds.add(doc.id);
          finalResults.add(_mapUserDocumentToResult(doc));
        }
      }

      // Hợp nhất kết quả từ email (chỉ thêm nếu chưa có)
      for (var doc in emailSnapshot.docs) {
        if (!processedIds.contains(doc.id)) {
          processedIds.add(doc.id);
          finalResults.add(_mapUserDocumentToResult(doc));
        }
      }

      return finalResults;
    } catch (e) {
      // Bỏ qua lỗi và trả về mảng rỗng
      return [];
    }
  }

  /// 🔎 Chức năng 2: Tìm kiếm Bài viết (trong nhóm đã tham gia)
  Future<List<Map<String, dynamic>>> searchPosts(
    String query,
    List<String> currentGroupIds,
  ) async {
    if (query.isEmpty || currentGroupIds.isEmpty) return [];

    if (currentGroupIds.length > 10) {
      // Giới hạn để tránh lỗi truy vấn whereIn của Firestore
      currentGroupIds = currentGroupIds.sublist(0, 10);
    }

    try {
      final snapshot = await _firestore
          .collection('Post')
          .where('status_id', isEqualTo: 1) // Bài viết công khai
          .where('group_id', whereIn: currentGroupIds) // Lọc theo nhóm
          .where(
            'content',
            isGreaterThanOrEqualTo: query,
          ) // Bắt đầu tìm kiếm tiền tố
          .where('content', isLessThan: query + '\uf8ff')
          // ĐÃ SỬA: Bắt buộc thêm orderBy('content', descending: true) để khớp Index
          .orderBy('content', descending: true)
          .orderBy(
            'date_created',
            descending: true,
          ) // Sắp xếp theo ngày mới nhất
          .limit(20)
          .get();

      final postsWithDetails = await Future.wait(
        snapshot.docs.map((doc) async {
          final data = doc.data();
          final userId = data["user_id"] as String?;
          Map<String, dynamic> userDetails = {};

          if (userId != null && userId.isNotEmpty) {
            userDetails = await _fetchUserDetail(userId);
          }

          // Lấy dữ liệu và chuẩn hóa
          return {
            "id": doc.id,
            "user_id": userId ?? "Ẩn danh",
            "fullname": userDetails["fullname"] ?? "Ẩn danh",
            "avatar": userDetails["avatar"],
            "group": data["group_id"] ?? "Không rõ",
            "title": data["content"] ?? "Không có nội dung",
            "date": (data["date_created"] is Timestamp)
                ? (data["date_created"] as Timestamp).toDate().toString()
                : null,
            "images": data["image_urls"] ?? [],
            "likes": data["likes"] ?? 0,
            "isLiked": false,
            // Đảm bảo comments là List (hoặc mảng rỗng) để tránh lỗi .length
            "comments": data["comments"] is List
                ? data["comments"]
                : <Map<String, dynamic>>[],
            "files": data["files"] ?? [],
          };
        }).toList(),
      );

      return postsWithDetails;
    } catch (e) {
      // Bỏ qua lỗi và trả về mảng rỗng
      return [];
    }
  }
}
