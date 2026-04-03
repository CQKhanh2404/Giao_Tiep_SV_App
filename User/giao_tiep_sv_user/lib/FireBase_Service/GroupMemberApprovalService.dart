// GroupMemberApprovalService.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_user/duyet_Nguoi_Dung/models/MemberApprovalModel.dart';
import 'package:rxdart/rxdart.dart';

class MemberApprovalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'Groups_members';
  // Lấy thành viên theo trạng thái
  Stream<QuerySnapshot> getMembersByStatus({
    required String groupId,
    int limit = 100,
    DocumentSnapshot? startAfter,
    int statusId = -1,
    bool orderDescending = true,
  }) {
    // Trước tiên kiểm tra nhóm có bật duyệt không
    return _firestore
        .collection('Groups')
        .doc(groupId)
        .snapshots()
        .where((groupSnapshot) {
          final data = groupSnapshot.data();
          return data != null && (data['id_status'] as num?)?.toInt() == 1;
        })
        .switchMap((_) {
          // Chỉ khi id_status == 1 mới query members
          Query query = _firestore
              .collection(_collection)
              .where('group_id', isEqualTo: groupId)
              .orderBy('joined_at', descending: orderDescending)
              .limit(limit);

          if (statusId >= 0) {
            query = query.where('status_id', isEqualTo: statusId);
          }
          if (startAfter != null) {
            query = query.startAfterDocument(startAfter);
          }

          return query.snapshots();
        });
  }

  Future<MemberApprovalModel> docToMemberModel(
    QueryDocumentSnapshot doc,
  ) async {
    final data = doc.data() as Map<String, dynamic>;
    final String? userId = data['user_id'] as String?;

    String fullName = 'Không tên';
    String avatar = '';
    String? faculty;
    String? facultyId;

    if (userId != null && userId.isNotEmpty) {
      try {
        final userDoc = await _firestore.collection('Users').doc(userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          fullName = userData['fullname'] ?? 'Không tên';
          avatar = userData['avt'] ?? '';
          facultyId = userData['faculty_id']?.toString();

          if (facultyId != null && facultyId.isNotEmpty) {
            final facultySnapshot = await _firestore
                .collection('Faculty')
                .where('id', isEqualTo: facultyId)
                .limit(1)
                .get();
            faculty = facultySnapshot.docs.isNotEmpty
                ? facultySnapshot.docs.first['name'] ?? 'Không rõ khoa'
                : facultyId;
          }
        }
      } catch (e) {
        print("Lỗi lấy user: $e");
      }
    }

    final int statusId = (data['status_id'] as num?)?.toInt() ?? 0;
    return MemberApprovalModel(
      id: doc.id,
      userId: userId ?? '',
      fullName: fullName,
      avatar: avatar,
      groupId: data['group_id'] ?? '',
      role: _roleToString((data['role'] as num?)?.toInt() ?? 0),
      status: _statusIdToString(statusId),
      joinedAt: (data['joined_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      faculty: faculty,
      facultyId: facultyId,
    );
  }

  Future<void> approveMember(String docId) async {
    await _firestore.collection(_collection).doc(docId).update({
      'status_id': 1,
    });
  }

  Future<void> rejectMember(String docId) async {
    await _firestore.collection(_collection).doc(docId).update({
      'status_id': 2,
    });
  }

  String _statusIdToString(int id) {
    switch (id) {
      case 0:
        return 'pending';
      case 1:
        return 'approved';
      case 2:
        return 'rejected';
      default:
        return 'pending';
    }
  }

  String _roleToString(int id) {
    switch (id) {
      case 0:
        return 'member';
      case 1:
        return 'admin';
      default:
        return 'member';
    }
  }
}
