import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/maneger_member_group_Screens/serviceGroup/groupService.dart';

class CustomMemberGroupManeger extends StatefulWidget {
  final String url;
  final String fullname;
  final String userId;
  final String groupId;
  final bool isGroupOwner;
  final String currentUserId;
  final VoidCallback onMemberRemoved;

  const CustomMemberGroupManeger({
    super.key,
    required this.url,
    required this.fullname,
    required this.userId,
    required this.groupId,
    required this.isGroupOwner,
    required this.currentUserId,
    required this.onMemberRemoved,
  });

  @override
  State<CustomMemberGroupManeger> createState() =>
      _CustomMemberGroupManegerState();
}

class _CustomMemberGroupManegerState extends State<CustomMemberGroupManeger> {
  final GroupserviceManeger _service = GroupserviceManeger();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final bool canShowMenu =
        widget.isGroupOwner && widget.userId != widget.currentUserId;

    print("CustomMember - User: ${widget.fullname} ( ${widget.userId})");

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ClipOval(
                child: Image.network(
                  widget.url,
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.person, size: 40),
                ),
              ),
              const SizedBox(width: 15),
              Text(
                widget.fullname,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          if (canShowMenu)
            _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz),
                    onSelected: (value) async {
                      if (value == 'delete') {
                        print("Đang xóa thành viên: ${widget.userId}");
                        setState(() => _isLoading = true);

                        final success = await _service.removeMemberFromGroup(
                          groupId: widget.groupId,
                          userIdToRemove: widget.userId,
                          currentUserId: widget.currentUserId,
                        );

                        setState(() => _isLoading = false);

                        if (!mounted) return;

                        if (success) {
                          print("Xóa thành viên thành công!");
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Đã xóa thành viên thành công!"),
                            ),
                          );
                          widget.onMemberRemoved();
                        } // THÊM MỚI: Xử lý "Thêm làm quản trị viên"
                      } else if (value == 'upmember') {
                        print("Đang thêm làm quản trị viên: ${widget.userId}");
                        setState(() => _isLoading = true);

                        final result = await _service.makeMemberAdmin(
                          groupId: widget.groupId,
                          userIdToPromote: widget.userId,
                          currentUserId: widget.currentUserId,
                        );

                        setState(() => _isLoading = false);
                        if (!mounted) return;

                        // Dựa vào chuỗi trả về để hiện thông báo phù hợp
                        if (result == "success") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Đã thêm làm quản trị viên thành công!",
                              ),
                            ),
                          );
                          widget.onMemberRemoved(); // reload danh sách
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result),
                              backgroundColor:
                                  result.contains("Thêm admin thành công")
                                  ? Colors.orange
                                  : Colors.red,
                            ), // Hiện đúng thông báo lỗi hoặc cảnh báo
                          );
                        }
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: "delete",
                        child: Text(
                          "Xóa thành viên",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      PopupMenuItem(
                        value: "upmember",
                        child: Text("Thêm làm quản trị viên"),
                      ),
                    ],
                  )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}
