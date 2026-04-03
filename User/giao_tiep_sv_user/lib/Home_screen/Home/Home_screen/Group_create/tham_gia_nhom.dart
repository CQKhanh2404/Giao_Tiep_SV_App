import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_user/Home_screen/Home/Home_screen/Group_create/nhom_cua_toi.dart';
import '../left_panel.dart';
import 'tao_nhom_page.dart';
import '../../../../FireBase_Service/group_service.dart';

class ThamGiaNhomPage extends StatefulWidget {
  const ThamGiaNhomPage({super.key});

  @override
  State<ThamGiaNhomPage> createState() => _ThamGiaNhomPageState();
}

class _ThamGiaNhomPageState extends State<ThamGiaNhomPage> {
  bool _isOpen = false;
  // Khởi tạo Service
  final GroupService _groupService = GroupService();

  // Khai báo Future này để FutureBuilder có thể sử dụng
  late Future<List<DocumentSnapshot>> _groupsFuture;

  // 1. Biến trạng thái và Controller cho Tìm kiếm
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    // Gọi hàm từ Service để tải DỮ LIỆU BAN ĐẦU
    _groupsFuture = _groupService.fetchGroupsToJoin();

    // Lắng nghe thay đổi của thanh tìm kiếm
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // --- HÀM XỬ LÝ TÌM KIẾM---
  void _onSearchChanged() {
    final newSearchText = _searchController.text.toLowerCase().trim();
    if (newSearchText != _searchText) {
      setState(() {
        _searchText = newSearchText;
      });
    }
  }

  void toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  // --- HÀM GỬI YÊU CẦU THAM GIA NHÓM---
  void _requestJoinGroup(String groupId, String groupName) async {
    try {
      await _groupService.requestJoinGroup(groupId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã gửi yêu cầu tham gia "$groupName". Vui lòng chờ quản trị viên duyệt.',
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      // Làm mới danh sách sau khi gửi yêu cầu thành công
      setState(() {
        _groupsFuture = _groupService.fetchGroupsToJoin();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gửi yêu cầu thất bại: $e'),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // --- HÀM XÂY DỰNG ITEM NHÓM ---
  Widget _buildGroupListItem(Map<String, dynamic> group, String groupId) {
    final String imageUrl = group['avt'] ?? "https://via.placeholder.com/60";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Ảnh nhóm
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.group, size: 60, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 16),

            // Tên nhóm và nút tham gia
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group["name"] ?? 'Tên nhóm không xác định',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  // Hiển thị phần 'Mô tả:' nổi bật hơn bằng Text.rich
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Mô tả: ',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        TextSpan(
                          text:
                              (group["description"] ?? '')
                                  .toString()
                                  .trim()
                                  .isEmpty
                              ? 'Không có mô tả'
                              : group["description"].toString(),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _requestJoinGroup(groupId, group["name"]),
                    icon: const Icon(Icons.handshake),
                    label: const Text("Tham Gia"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HÀM XÂY DỰNG THANH TÌM KIẾM ---
  Widget _buildSearchBar() {
    return Container(
      // Loại bỏ padding ngang ở đây để thêm vào Column bên dưới
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      color: Colors.white, // Màu nền cho thanh tìm kiếm
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm tên nhóm...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }

  // --- WIDGET BUILD CHÍNH ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // 🔹 Nội dung chính
          SafeArea(
            child: Column(
              children: [
                // 🔹 AppBar (Không còn nút Tìm kiếm)
                AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0.5,
                  leading: IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black),
                    onPressed: toggleMenu,
                  ),
                  title: const Text(
                    "Tham Gia Nhóm",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                  actions: [
                    // Nút Nhóm của tôi
                    IconButton(
                      icon: const Icon(Icons.group, color: Colors.black),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NhomCuaToi(),
                          ),
                        );
                      },
                    ),
                    // Nút Tạo nhóm
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.black),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TaoNhomPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                // 🔹 THANH TÌM KIẾM (Luôn hiển thị ở đây)
                // Đặt màu nền trắng cho thanh tìm kiếm để phân biệt với nền xám của body
                Container(color: Colors.white, child: _buildSearchBar()),

                // 🔹 Danh sách nhóm - Sử dụng FutureBuilder
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: FutureBuilder<List<DocumentSnapshot>>(
                      future: _groupsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Lỗi tải dữ liệu: ${snapshot.error}'),
                          );
                        }

                        final List<DocumentSnapshot> allGroups =
                            snapshot.data ?? [];

                        // Lọc dữ liệu trên Client dựa trên _searchText
                        final List<DocumentSnapshot> filteredGroups = allGroups
                            .where((groupDoc) {
                              final groupData =
                                  groupDoc.data() as Map<String, dynamic>;
                              final groupName =
                                  (groupData['name'] as String?)
                                      ?.toLowerCase() ??
                                  '';

                              // So sánh tên nhóm với chuỗi tìm kiếm
                              return groupName.contains(_searchText);
                            })
                            .toList();

                        if (filteredGroups.isEmpty) {
                          return Center(
                            child: Text(
                              _searchText.isEmpty
                                  ? "Không tìm thấy nhóm nào phù hợp để tham gia."
                                  : "Không tìm thấy nhóm nào khớp với '$_searchText'.",
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          );
                        }

                        // Hiển thị danh sách nhóm đã lọc
                        return ListView.builder(
                          itemCount: filteredGroups.length,
                          itemBuilder: (context, index) {
                            final groupDoc = filteredGroups[index];
                            final groupData =
                                groupDoc.data() as Map<String, dynamic>;
                            final groupId = groupDoc.id;

                            return _buildGroupListItem(groupData, groupId);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🔹 LeftPanel (menu trái)
          if (_isOpen)
            GestureDetector(
              onTap: toggleMenu,
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Row(
                  children: [
                    LeftPanel(
                      onClose: toggleMenu,
                      isGroupPage: true,
                      onGroupSelected: (id, name) {
                        // Không cần xử lý chọn nhóm trên màn hình này
                      },
                    ),
                    Expanded(child: Container()),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
