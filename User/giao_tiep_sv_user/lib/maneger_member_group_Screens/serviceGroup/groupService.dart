import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_user/Data/groups.dart';
import 'package:giao_tiep_sv_user/Data/groups_members.dart';

class GroupserviceManeger {
  final FirebaseFirestore groupDb = FirebaseFirestore.instance;

  //them vao membergroup
  Future<void> addDataGroupMember(Groupmember grMember) async {
    try {
      final querySnap = groupDb.collection("Groups_members");
      await querySnap.add({
        'group_id': grMember.group_id,
        'user_id': grMember.user_id,
        'role': grMember.role,
        'status_id': grMember.status_id,
        'joined_at': FieldValue.serverTimestamp(),
      });

      print("them thanh vien thanh cong");
    } catch (e) {
      print("loi khi them thanh vien vao nhom: $e");
    }
  }

  // lay created by của nhóm
  Future<List<String>?> getCreateAtID(String idGroup, bool type) async {
    try {
      List<String> listResult = [];
      final ref = groupDb.collection("Groups_members");

      try {
        if (type == false) {
          QuerySnapshot query = await ref
              .where("group_id", isEqualTo: idGroup)
              .where("role", isEqualTo: 1)
              .get();
          for (var doc in query.docs) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            if (data.containsKey("user_id")) {
              var item = data["user_id"] as String;
              listResult.add(item);
            }
          }
          return listResult;
        } else {
          QuerySnapshot query = await ref
              .where("group_id", isEqualTo: idGroup)
              .where("role", isEqualTo: 1)
              .get();
          for (var doc in query.docs) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            if (data.containsKey("user_id")) {
              var item = data["user_id"] as String;
              listResult.add(item);
            }
          }
          return listResult;
        }
      } catch (e) {
        print("loi khi lay du lieu create by: $e");
      }
    } catch (e) {
      print("loi khi lay create At: $e");
      return null;
    }
  }

  //tim cac thanh vien ben trong nhom
  Future<List<String?>> listChat(String idRoom) async {
    try {
      final querySnap = await groupDb
          .collection("Groups_members")
          .where("group_id", isEqualTo: idRoom)
          .where("status_id", isEqualTo: 1)
          .get();

      if (querySnap.docs.isEmpty) {
        print("khong co thanh vien nao ca");
        return [];
      }

      // SỬA Ở ĐÂY: Map để lấy ra 'user_id' (String) thay vì đối tượng Users
      List<String?> listUserIDs = querySnap.docs.map((doc) {
        return doc.data()['user_id'] as String?;
      }).toList();

      return listUserIDs;
    } catch (e) {
      print("loi khi lay du lieu thanh vien cua nhom: $e");
      return [];
    }
  }

  //lay danh sach toan bo thanh vien trong nhom x
  Stream<List<String>> streamGetAllmember(String x) {
    try {
      Query query = FirebaseFirestore.instance
          .collection("Groups_members")
          .where("group_id", isEqualTo: x);
      return query.snapshots().map((event) {
        return event.docs.map((e) {
          Map<String, dynamic> data = e.data() as Map<String, dynamic>;
          print("lay du lieu thanh cong");
          return data['user_id'] as String;
        }).toList();
      });
    } catch (e) {
      print("Loi lay thanh vien cua nhom: $e");
      return Stream.empty();
    }
  }

  //load cac group theo ma
  Future<List<String>> loadGroupsforId(String id) async {
    try {
      final snap = await FirebaseFirestore.instance.collection('Groups').get();

      final List<String> groupIds = snap.docs
          .where((element) {
            final data = element.data();
            int typeGroup = data["type_group"] ?? 2;
            final facultyIdMap = data['faculty_id'];
            if (facultyIdMap != null && facultyIdMap is Map && typeGroup == 0) {
              return facultyIdMap.containsKey(id);
            }
            return false;
          })
          .map((e) {
            return e.id;
          })
          .toList();
      return groupIds;
    } catch (e) {
      print('Lỗi khi lọc nhóm theo mã $id: $e');
      return [];
    }
  }

  // XÓA THÀNH VIÊN
  Future<bool> removeMemberFromGroup({
    required String groupId,
    required String userIdToRemove,
    required String currentUserId,
  }) async {
    try {
      // Kiểm tra xem currentUser có phải chủ nhóm (role = 1) không
      final ownerCheck = await FirebaseFirestore.instance
          .collection("Groups_members")
          .where("group_id", isEqualTo: groupId)
          .where("user_id", isEqualTo: currentUserId)
          .where("role", isEqualTo: 1)
          .limit(1)
          .get();

      if (ownerCheck.docs.isEmpty) {
        print("Không có quyền: Bạn không phải chủ nhóm (role=1)");
        return false;
      }
      if (userIdToRemove == currentUserId) {
        print("Không thể tự xóa chính mình khỏi nhóm");
        return false;
      }

      // Tìm và xóa bản ghi thành viên
      final memberDocs = await FirebaseFirestore.instance
          .collection("Groups_members")
          .where("group_id", isEqualTo: groupId)
          .where("user_id", isEqualTo: userIdToRemove)
          .get();

      if (memberDocs.docs.isEmpty) {
        print("Không tìm thấy thành viên để xóa");
        return false;
      }

      for (var doc in memberDocs.docs) {
        await doc.reference.delete();
      }

      print("Xóa thành viên thành công: $userIdToRemove");
      return true;
    } catch (e) {
      print("Lỗi xóa thành viên: $e");
      return false;
    }
  }

  Future<List<String>> getAdminsInGroup(String groupId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("Groups_members")
          .where("group_id", isEqualTo: groupId)
          .where("role", isEqualTo: 1)
          .get();

      final List<String> adminIds = snapshot.docs
          .map((doc) => doc['user_id'] as String)
          .toList();

      print("Danh sách quản trị viên (role=1): $adminIds");
      return adminIds;
    } catch (e) {
      print("Lỗi lấy danh sách admin: $e");
      return [];
    }
  }

  Future<String> makeMemberAdmin({
    required String groupId,
    required String userIdToPromote,
    required String currentUserId,
  }) async {
    try {
      print("Bắt đầu thêm quản trị viên: $userIdToPromote");

      // Kiểm tra người thực hiện có phải chủ nhóm (role = 1) không
      final ownerCheck = await FirebaseFirestore.instance
          .collection("Groups_members")
          .where("group_id", isEqualTo: groupId)
          .where("user_id", isEqualTo: currentUserId)
          .where("role", isEqualTo: 1)
          .limit(1)
          .get();

      if (ownerCheck.docs.isEmpty) {
        return "Không có quyền: Chỉ chủ nhóm mới được thêm quản trị viên";
      }
      // 2. Tìm thành viên cần thêm
      final memberQuery = await FirebaseFirestore.instance
          .collection("Groups_members")
          .where("group_id", isEqualTo: groupId)
          .where("user_id", isEqualTo: userIdToPromote)
          .limit(2)
          .get();

      if (memberQuery.docs.isEmpty) {
        return "Không tìm thấy thành viên trong nhóm";
      }

      final doc = memberQuery.docs.first;
      final currentRole = doc['role'] as int?;
      if (currentRole == 1) {
        return "Người này đã là quản trị viên rồi!";
      }
      await doc.reference.update({'role': 1});
      print("Đã thêm làm quản trị viên thành công: $userIdToPromote");
      return "success";
    } catch (e) {
      print("Lỗi khi thêm quản trị viên: $e");
      return "Đã xảy ra lỗi, vui lòng thử lại";
    }
  }
}
