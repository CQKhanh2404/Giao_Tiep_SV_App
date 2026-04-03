import 'package:cloud_firestore/cloud_firestore.dart';

class FacultyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Truy vấn Firebase để lấy tên khoa dựa trên mã khoa (ví dụ: 'TT').
  /// Trả về Map<String, String> {facultyCode: facultyName}
  Future<Map<String, String>?> fetchFacultyIdMap(String facultyCode) async {
    if (facultyCode.isEmpty) return null;

    try {
      // 1. Truy vấn collection 'Faculty'
      // 2. Tìm document có trường 'id' khớp với mã khoa (facultyCode)
      final querySnapshot = await _firestore
          .collection('Faculty')
          .where('id', isEqualTo: facultyCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        final facultyName = data['name'] as String? ?? 'Khoa chưa xác định';

        // Trả về Map {Mã khoa: Tên khoa} đúng định dạng cần lưu vào Groups
        return {facultyCode: facultyName};
      }
    } catch (e) {
      print("🔥 Lỗi khi lấy thông tin Khoa từ Firestore: $e");
    }
    return null;
  }
}
