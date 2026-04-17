// Profile_Service.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:giao_tiep_sv_user/Data/faculty.dart';
import 'package:giao_tiep_sv_user/Profile/editProflie/models/profile_model.dart';

// Service quản lý profile người dùng: đọc, cập nhật, upload ảnh đại diện
// Dùng Singleton để đảm bảo chỉ có 1 instance duy nhất trong toàn app
class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage =
      FirebaseStorage.instance; // Kích hoạt Storage

  final String _collectionName = 'Users';
  final String _facultyCollectionName = 'Faculty';

  String? _userId;

  String getUserId() {
    if (_userId == null) {
      throw Exception('User ID chưa được thiết lập. Vui lòng đăng nhập lại.');
    }
    return _userId!;
  }

  void setUserId(String userId) {
    _userId = userId;
  }

  ProfileModel? _cachedProfile;

  // Xóa cache và tải lại profile mới nhất từ Firestore
  Future<void> refreshProfile() async {
    _cachedProfile = null;
    await getProfile(forceRefresh: true);
  }

  // Lấy thông tin profile (có cache, chỉ gọi Firestore nếu chưa có hoặc forceRefresh)
  Future<ProfileModel?> getProfile({bool forceRefresh = false}) async {
    final userId = getUserId();

    if (_cachedProfile != null && !forceRefresh) {
      return _cachedProfile;
    }

    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        final profile = ProfileModel(
          name: data['fullname'] ?? '',
          email: data['email'] ?? '',
          address: data['address'] ?? '',
          phone: data['phone'] ?? '',
          avatarUrl: data['avt'] ?? '',
          faculty: Faculty(
            faculty_id: data['faculty_id'] ?? '',
            name_faculty: data['name_faculty'] ?? '',
          ),
          roleId: data['role_id']?.toString() ?? '',
        );
        _cachedProfile = profile;
        return profile;
      }
      return null;
    } catch (e) {
      print('Lỗi khi lấy profile: $e');
      rethrow;
    }
  }

  // Lấy profile dướng stream real-time (tự động cập nhật khi dữ liệu thay đổi)
  Stream<ProfileModel?> getProfileStream() {
    final userId = getUserId();
    return _firestore.collection(_collectionName).doc(userId).snapshots().map((
      doc,
    ) {
      if (!doc.exists) return null;
      final data = doc.data()!;
      return ProfileModel(
        name: data['fullname'] ?? '',
        email: data['email'] ?? '',
        address: data['address'] ?? '',
        phone: data['phone'] ?? '',
        avatarUrl: data['avt'] ?? '',
        faculty: Faculty(
          faculty_id: data['faculty_id'] ?? '',
          name_faculty: data['name_faculty'] ?? '',
        ),
        roleId: data['role_id']?.toString() ?? '',
      );
    });
  }

  // Upload ảnh đại diện lên Firebase Storage và trả về URL mới
  Future<String> uploadAvatar(File imageFile) async {
    final userId = getUserId();
    // Lưu ảnh vào thư mục users/
    final ref = _storage.ref().child('users').child('$userId.jpg');

    try {
      try {
        await ref.delete();
      } catch (e) {
        print('Không có ảnh cũ để xóa hoặc lỗi: $e');
      }
      // UPLOAD ẢNH MỚI
      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();
      print('Upload thành công! URL: $url');
      return url;
    } on FirebaseException catch (e) {
      print('Lỗi upload: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // Cập nhật thông tin profile (tên, địa chỉ, sđt, ảnh đại diện) lên Firestore
  Future<void> updateProfile(
    ProfileModel profile, {
    String? newAvatarUrl,
  }) async {
    final userId = getUserId();

    try {
      Map<String, dynamic> updateData = {
        'fullname': profile.name,
        'address': profile.address,
        'phone': profile.phone,
      };

      if (newAvatarUrl != null && newAvatarUrl.isNotEmpty) {
        updateData['avt'] = newAvatarUrl;
      }

      await _firestore
          .collection(_collectionName)
          .doc(userId)
          .update(updateData);

      _cachedProfile = null; // Xóa cache
    } on FirebaseException catch (e) {
      print('Firebase lỗi: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Lỗi không xác định: $e');
      rethrow;
    }
  }

  // Lấy tên ngành và niên khóa từ email và mã khoa
  Future<Map<String, String>> layNganhVaNienKhoa(
    String email,
    String facultyId,
  ) async {
    try {
      String schoolYear = _schoolYearFromEmail(email);
      String major = await _getMajorFromFacultyId(facultyId);
      return {'major': major, 'schoolYear': schoolYear};
    } catch (e) {
      return {'major': 'lỗi', 'schoolYear': '20XX'};
    }
  }

  String _schoolYearFromEmail(String email) {
    if (email.length >= 2) {
      String yearPrefix = email.substring(0, 2);
      return "20$yearPrefix";
    }
    return "null";
  }

  Future<String> _getMajorFromFacultyId(String facultyId) async {
    if (facultyId.isEmpty) return 'Chưa chọn khoa';

    try {
      final snapshot = await _firestore
          .collection(_facultyCollectionName)
          .where('id', isEqualTo: facultyId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return 'Không tìm thấy khoa';

      final data = snapshot.docs.first.data();
      return data['name']?.toString().replaceAll('"', '') ?? 'Tên khoa trống';
    } catch (e) {
      return 'Lỗi khi tải dữ liệu';
    }
  }
}
