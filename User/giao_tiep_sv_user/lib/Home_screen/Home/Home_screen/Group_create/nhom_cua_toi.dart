import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_user/Data/global_state.dart';
import 'package:giao_tiep_sv_user/Home_screen/home.dart';
import 'package:giao_tiep_sv_user/duyet_Nguoi_Dung/member_post_screen.dart';
import '../left_panel.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/myGroup_service.dart';

class NhomCuaToi extends StatefulWidget {
  const NhomCuaToi({super.key});

  @override
  State<NhomCuaToi> createState() => _NhomCuaToiState();
}

class _NhomCuaToiState extends State<NhomCuaToi> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  //  Gọi từ service thay vì trực tiếp Firestore
  final Stream<List<DocumentSnapshot>> _groupsStream =
      MygroupService.getMyGroupsStream();

  @override
  Widget build(BuildContext context) {
    print(">>> Current User ID: ${GlobalState.currentUserId}");

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: _buildDrawer(),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: LeftPanel(
        onClose: () => Navigator.of(context).pop(),
        onGroupSelected: (id, name) {},
        isGroupPage: true,
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      title: const Text(
        "Nhóm của tôi",
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.black),
      actions: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 21),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: _buildGroupList(),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupList() {
    // Cập nhật kiểu dữ liệu của StreamBuilder
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: _groupsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Đã xảy ra lỗi khi tải dữ liệu: ${snapshot.error}'),
          );
        }

        // Lấy dữ liệu là List<DocumentSnapshot>
        final groupsDocs = snapshot.data ?? [];

        if (groupsDocs.isEmpty) {
          if (GlobalState.currentUserId.isEmpty) {
            return const Center(
              child: Text('Lỗi: ID người dùng chưa được thiết lập.'),
            );
          }
          return const Center(child: Text('Bạn chưa tạo nhóm nào.'));
        }

        return ListView.builder(
          itemCount: groupsDocs.length,
          itemBuilder: (context, index) {
            final groupDoc = groupsDocs[index];
            final groupData = groupDoc.data() as Map<String, dynamic>;

            final group = {
              "id": groupDoc.id,
              "name": groupData["name"] ?? "Nhóm không tên",
              "image":
                  groupData.containsKey("avt") && groupData["avt"] is String
                  ? groupData["avt"]
                  : "assets/images/database.png",
            };

            return _buildGroupCard(group);
          },
        );
      },
    );
  }

  Widget _buildGroupCard(Map<String, dynamic> group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGroupImage(group["image"]),
          const SizedBox(width: 16),
          _buildGroupInfo(group),
        ],
      ),
    );
  }

  Widget _buildGroupImage(String imagePath) {
    final bool isNetworkImage =
        imagePath.startsWith('http') || imagePath.startsWith('https');

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 60,
        height: 60,
        child: isNetworkImage
            ? Image.network(
                imagePath,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  "assets/images/database.png",
                  fit: BoxFit.cover,
                ),
              )
            : Image.asset(imagePath, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildGroupInfo(Map<String, dynamic> group) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group["name"],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          _buildAccessButton(group["id"], group["name"]),
        ],
      ),
    );
  }

  Widget _buildAccessButton(String groupId, String groupName) {
    return OutlinedButton(
      onPressed: () => _handleAccessGroup(groupId, groupName),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.blueAccent),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Quản lý", style: TextStyle(color: Colors.blueAccent)),
          SizedBox(width: 6),
          Icon(Icons.arrow_forward, color: Colors.blueAccent, size: 18),
        ],
      ),
    );
  }

  void _handleAccessGroup(String groupId, String groupName) {
    print(">>> Đang chuyển hướng và chọn nhóm: ID=$groupId | Tên=$groupName");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MemberPostScreen(groupId: groupId),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đang truy cập quản lý nhóm "$groupName" '),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
