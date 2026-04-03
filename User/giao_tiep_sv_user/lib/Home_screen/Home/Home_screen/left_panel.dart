import 'package:flutter/material.dart';
import 'Group_create/tham_gia_nhom.dart';
import 'package:giao_tiep_sv_user/Home_screen/home.dart';
import 'package:giao_tiep_sv_user/Data/global_state.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/get_joined_groups.dart';

class LeftPanel extends StatefulWidget {
  final VoidCallback onClose;
  final bool isGroupPage;

  // Hàm onGroupSelected phải nhận (ID nhóm, Tên nhóm)
  final void Function(String id, String name) onGroupSelected;

  const LeftPanel({
    super.key,
    required this.onClose,
    required this.onGroupSelected,
    this.isGroupPage = false,
  });

  @override
  State<LeftPanel> createState() => _LeftPanelState();
}

class _LeftPanelState extends State<LeftPanel> {
  final GetJoinedGroupsService _groupService = GetJoinedGroupsService();
  final TextEditingController _searchController = TextEditingController();

  // ID người dùng hiện tại (Lấy từ global state hoặc mặc định)
  final String _currentUserId = GlobalState.currentUserId.isNotEmpty
      ? GlobalState.currentUserId
      : "23211TT4679"; // ID mặc định nếu chưa đăng nhập

  List<Map<String, dynamic>> _groups = [];
  List<Map<String, dynamic>> _filteredGroups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGroups();
    _searchController.addListener(_filterGroups);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterGroups);
    _searchController.dispose();
    super.dispose();
  }

  // Hàm tải danh sách nhóm từ Firebase
  Future<void> _fetchGroups() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final fetched = await _groupService.fetchJoinedGroups(_currentUserId);

    if (!mounted) return;
    setState(() {
      // Bỏ nhóm "Tất cả" khỏi danh sách hiển thị bằng cách lọc theo ID
      _groups = fetched.where((group) => group["id"] != "ALL").toList();
      _filteredGroups = _groups;
      _isLoading = false;
      if (_searchController.text.isNotEmpty) _filterGroups();
    });
  }

  // Hàm lọc nhóm theo tên
  void _filterGroups() {
    final query = _searchController.text.toLowerCase();
    if (!mounted) return;
    setState(() {
      if (query.isEmpty) {
        _filteredGroups = _groups;
      } else {
        _filteredGroups = _groups
            .where(
              (group) => (group["name"] ?? "").toLowerCase().contains(query),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: 260,
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header "Nhóm" + nút Mở rộng
            Row(
              children: [
                const Text(
                  "Nhóm:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (!widget.isGroupPage)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ThamGiaNhomPage(),
                        ),
                      );
                      widget.onClose();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreenAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Mở rộng", style: TextStyle(color: Colors.black)),
                        SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.black,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Thanh tìm kiếm
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Tìm nhóm...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Nút "Trang chủ"
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Trang chủ"),
              onTap: () {
                // LOGIC ĐÃ ĐIỀU CHỈNH: Không còn chọn "ALL" cho Trang Chủ

                if (_groups.isNotEmpty) {
                  // Chọn nhóm đầu tiên trong danh sách (đã được lọc bỏ "ALL")
                  final defaultGroup = _groups[0];
                  widget.onGroupSelected(
                    defaultGroup["id"],
                    defaultGroup["name"],
                  );
                } else {
                  // Nếu không có nhóm nào, gửi tín hiệu không có nhóm để Trang Chủ hiển thị thông báo
                  widget.onGroupSelected(
                    "NO_GROUP_SELECTED",
                    "Hãy tham gia nhóm!",
                  );
                }

                widget.onClose();

                // 2. Chỉ chuyển hướng nếu đang ở màn hình khác
                if (widget.isGroupPage) {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Home()),
                    );
                  }
                }
              },
            ),
            const Divider(),

            // Danh sách nhóm
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredGroups.isEmpty
                  ? const Center(
                      child: Text(
                        "Không có nhóm nào",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: _filteredGroups.length,
                      itemBuilder: (context, index) {
                        final group = _filteredGroups[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: group["avatar_url"] != null
                                ? NetworkImage(group["avatar_url"])
                                : const AssetImage(
                                        'assets/images/default_group.png',
                                      )
                                      as ImageProvider,
                          ),
                          title: Text(group["name"]),
                          onTap: () {
                            widget.onGroupSelected(group["id"], group["name"]);
                            widget.onClose();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
