import 'package:cloud_firestore/cloud_firestore.dart';
import '../Data/global_state.dart';

class GroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. TÁCH MÃ KHOA TỪ USER_ID
  String _extractFacultyCode(String userId) {
    if (userId.isEmpty) return '';

    // Lấy cụm ký tự in hoa liên tiếp
    final RegExp facultyRegex = RegExp(r'[A-Z]+');
    final match = facultyRegex.firstMatch(userId);

    return match?.group(0) ?? '';
  }

  // 2. LẤY DANH SÁCH NHÓM MÀ NGƯỜI DÙNG ĐƯỢC HIỂN THỊ
  Future<List<DocumentSnapshot>> fetchGroupsToJoin() async {
    final String currentUserId = GlobalState.currentUserId;
    final String facultyCode = _extractFacultyCode(currentUserId);

    if (currentUserId.isEmpty || facultyCode.isEmpty) {
      return [];
    }

    // B1: Lấy nhóm mà user đang là thành viên hoặc đã gửi yêu cầu
    final QuerySnapshot memberGroupsSnapshot = await _firestore
        .collection('Groups_members')
        .where('user_id', isEqualTo: currentUserId)
        .get();

    final Set<String> groupIdsToExclude = memberGroupsSnapshot.docs
        .where((doc) {
          final status = doc.get('status_id') as int?;
          return status == 1 || status == 0; // 1 = đã vào, 0 = đang chờ duyệt
        })
        .map((doc) => doc['group_id'] as String)
        .toSet();
    // B2: Lấy tất cả nhóm đã được duyệt
    final QuerySnapshot allGroupsSnapshot = await _firestore
        .collection('Groups')
        .where('id_status', isEqualTo: 1) // nhóm active
        .get();
    // B3: Lọc nhóm theo KEY của faculty_id
    final List<DocumentSnapshot> filteredGroups = allGroupsSnapshot.docs.where((
      groupDoc,
    ) {
      final dynamic rawFaculty = groupDoc.get('faculty_id');

      Map<String, dynamic> facultyMap = {};

      // Trường hợp faculty_id là Map (định dạng chuẩn)
      if (rawFaculty is Map<String, dynamic>) {
        facultyMap = rawFaculty;
      }
      // Trường hợp faculty_id chỉ là chuỗi (VD: "KT")
      else if (rawFaculty is String) {
        facultyMap = {rawFaculty: rawFaculty};
      } else {
        return false;
      }

      // Lấy tất cả key trừ "id"
      final facultyKeys = facultyMap.keys.where((key) => key != "id").toList();

      final matchesFaculty = facultyKeys.contains(facultyCode);

      return matchesFaculty && !groupIdsToExclude.contains(groupDoc.id);
    }).toList();

    return filteredGroups;
  }

  // 3. GỬI YÊU CẦU THAM GIA NHÓM
  Future<void> requestJoinGroup(String groupId) async {
    final String currentUserId = GlobalState.currentUserId;

    await _firestore.collection('Groups_members').add({
      'group_id': groupId,
      'user_id': currentUserId,
      'role': 0, // thành viên thường
      'status_id': 0, // chờ duyệt
      'joined_at': FieldValue.serverTimestamp(),
    });
  }

  // thanh vien roi nhom 
  Future<void> deleteMemberByUserId(String userId,String roomId) async {
  try {
    final snap = await FirebaseFirestore.instance
        .collection('Groups_members')
        .where('user_id', isEqualTo: userId.toUpperCase())
        .where("group_id", isEqualTo: roomId)
        .get();

    if (snap.docs.isEmpty) {
      print('Không tìm thấy member nào có user_id = $userId');
      return;
    }

    // Xóa tất cả document tìm được (thường chỉ có 1)
    for (final doc in snap.docs) {
      await doc.reference.delete();
      print('Đã xóa member ${doc.id}');
    }
  } catch (e) {
    print('Lỗi khi xóa member: $e');
  }
}
}
