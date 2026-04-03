import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/group_service.dart';
import 'package:giao_tiep_sv_user/duyet_Nguoi_Dung/member_post_screen.dart';
import 'package:giao_tiep_sv_user/maneger_member_group_Screens/view/maneger_member_group.dart';
import '../../../Data/global_state.dart';

class GroupInfoDialog extends StatefulWidget {
  final String myId;
  final String groupName;
  final String currentGroupId;
  final int currentUserRole;
  final String groupOwnerId;

  const GroupInfoDialog({
    super.key,
    required this.groupName,
    required this.currentGroupId,
    required this.currentUserRole,
    required this.groupOwnerId,
    required this.myId,
  });

  @override
  State<GroupInfoDialog> createState() => _GroupInfoDialogState();
}

class _GroupInfoDialogState extends State<GroupInfoDialog> {
  final groupService = GroupService();
  //  HÀM TRUY VẤN ROLE NGƯỜI DÙNG
  Future<int> _fetchCurrentUserRole() async {
    try {
      final result = await FirebaseFirestore.instance
          .collection('Groups_members')
          .where('group_id', isEqualTo: widget.currentGroupId)
          .where('user_id', isEqualTo: GlobalState.currentUserId)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        return result.docs.first.data()['role'] as int? ?? 0;
      }
      return 0;
    } catch (e) {
      print("Lỗi khi fetch role: $e");
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _fetchCurrentUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AlertDialog(
            content: SizedBox(
              height: 50,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final int userRole = snapshot.data ?? 0;
        final bool canApprove = userRole == 1;

        return AlertDialog(
          title: Text(
            "Thông tin ${widget.groupName}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (canApprove)
                  _buildOption(
                    context,
                    Icons.check_circle,
                    "Quản lý",
                    Colors.green,
                    widget.currentGroupId,
                  ),
                _buildOption(
                  context,
                  Icons.group,
                  "Thành viên",
                  Colors.blue,
                  widget.currentGroupId,
                ),

                _buildOption(
                  context,
                  Icons.output_sharp,
                  "Rời nhóm",
                  Colors.red,
                  widget.currentGroupId,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Đóng"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOption(
    BuildContext context,
    IconData icon,
    String text,
    Color color,
    String groupId,
  ) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: color),
      title: Text(text),
      onTap: () async {
        
        Navigator.pop(context);
        //luu trang thai context để tránh dispose gay chết app
        final scaffoldContext = ScaffoldMessenger.of(context);
        if (text == "Quản lý") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MemberPostScreen(groupId: groupId),
            ),
          );
          return;
        } else if (text == "Thành viên") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ManegerMemberGroupScreen(idGroup: groupId),
            ),
          );
          return;
        } else if (text.contains("Rời nhóm")) {
          print("roi nhom");
          print('myId=${widget.myId}, groupId=$groupId'); 
          await groupService.deleteMemberByUserId(widget.myId, groupId);
          print('đã gọi xong deleteMemberByUserId');
        }

        scaffoldContext.showSnackBar(SnackBar(content: Text("Đã chọn: $text")));
      },
    );
  }
}
