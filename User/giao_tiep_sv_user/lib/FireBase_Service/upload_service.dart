import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class UploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Tải file lên Firebase Storage
  Future<String?> uploadFile(File file, String userId) async {
    // 1. Tạo đường dẫn trên Storage (Storage Path)
    final fileName = file.path.split('/').last;
    final now = DateTime.now().millisecondsSinceEpoch;
    // Đường dẫn tổ chức theo user ID và timestamp để tránh trùng lặp
    final path = 'groups/$userId/$now-$fileName';

    try {
      // 2. Tạo reference và upload file
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);

      // 3. Chờ đợi quá trình upload hoàn thành
      final snapshot = await uploadTask.whenComplete(() {});

      // 4. Lấy URL công khai (Download URL)
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print("✅ Upload file thành công. URL: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      print("🔥 LỖI TẢI FILE LÊN STORAGE: $e");
      return null;
    }
  }
}
