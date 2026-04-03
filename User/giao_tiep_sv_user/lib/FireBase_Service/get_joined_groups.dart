import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GetJoinedGroupsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hàm ánh xạ tên nhóm sang Icon (giữ lại để làm fallback nếu không có ảnh)
  IconData _mapGroupToIcon(String groupName) {
    final lowerName = groupName.toLowerCase();
    if (lowerName.contains("mobile") || lowerName.contains("flutter")) {
      return Icons.phone_android;
    } else if (lowerName.contains("thiết kế") || lowerName.contains("đồ họa")) {
      return Icons.computer;
    } else if (lowerName.contains("cntt") || lowerName.contains("công nghệ")) {
      return Icons.school;
    } else if (lowerName.contains("dev") || lowerName.contains("vui vẻ")) {
      return Icons.developer_mode;
    }
    return Icons.people;
  }

  Future<Map<String, dynamic>?> _fetchGroupDetails(String groupId) async {
    try {
      final groupDoc = await _firestore.collection('Groups').doc(groupId).get();
      if (groupDoc.exists && groupDoc.data() != null) {
        final data = groupDoc.data()!;

        if (data["id_status"] != 1) {
          return null;
        }

        // URL ảnh mặc định nếu không có ảnh nhóm
        const defaultAvatarUrl = "https://picsum.photos/seed/group/50";

        return {
          "name": data["name"] ?? "Nhóm không tên",
          "avatar_url": data["avt"] ?? defaultAvatarUrl,
          "icon": _mapGroupToIcon(data["name"] ?? ""),
          "id": groupId,
        };
      }
    } catch (e) {}
    return null;
  }

  Future<List<Map<String, dynamic>>> fetchJoinedGroups(String userId) async {
    List<Map<String, dynamic>> resultGroups = [
      {"name": "Tất cả", "icon": Icons.public, "id": "ALL"},
    ];

    if (userId.isEmpty) {
      return resultGroups;
    }

    try {
      final memberSnapshot = await _firestore
          .collection('Groups_members')
          .where('user_id', isEqualTo: userId)
          .where('status_id', isEqualTo: 1)
          .get();

      final groupIds = memberSnapshot.docs
          .map((doc) => doc['group_id'] as String)
          .toList();

      if (groupIds.isEmpty) {
        return resultGroups;
      }

      List<Future<Map<String, dynamic>?>> groupsFutures = [];

      for (final groupId in groupIds) {
        groupsFutures.add(_fetchGroupDetails(groupId));
      }

      final fetchedGroups = await Future.wait(groupsFutures);

      final validGroups = fetchedGroups
          .whereType<Map<String, dynamic>>()
          .toList();

      resultGroups.addAll(validGroups);
      return resultGroups;
    } catch (e) {
      print("🔥 Service: Lỗi tải danh sách nhóm: $e");
      return resultGroups;
    }
  }
}
