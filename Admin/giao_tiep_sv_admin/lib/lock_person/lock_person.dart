import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_admin/widget/customSearch.dart';

class LockPerson extends StatefulWidget {
  const LockPerson({super.key});

  @override
  State<LockPerson> createState() => _LockPersonState();
}

class _LockPersonState extends State<LockPerson> {
  String? selectedFacultyId; // id khoa (VD: "TT")
  List<Map<String, dynamic>> faculties = [];
  bool isLoadingFaculties = true;

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _accounts = [];
  List<Map<String, dynamic>> _filteredAccounts = [];

  @override
  void initState() {
    super.initState();
    _loadFaculties();
  }

  /// Lấy danh sách Khoa từ Firestore
  Future<void> _loadFaculties() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Faculty')
          .get();

      final List<Map<String, dynamic>> loadedFaculties = snapshot.docs.map((
        doc,
      ) {
        final data = doc.data();
        return {
          'id': data['id'] ?? doc.id, // lấy theo id
          'name': data['name'] ?? 'Không tên',
        };
      }).toList();

      setState(() {
        faculties = loadedFaculties;
        isLoadingFaculties = false;
      });

      if (faculties.isNotEmpty) {
        selectedFacultyId = faculties.first['id']; // "TT"
        // Gọi hàm đã sửa đổi để tải tài khoản bị khóa
        await _loadLockedUsers(selectedFacultyId!);
      }
    } catch (e) {
      print('Lỗi tải khoa: $e');
      setState(() => isLoadingFaculties = false);
    }
  }

  //  HÀM ĐỂ MỞ KHÓA TÀI KHOẢN
  Future<void> _unlockUser(String userId, String facultyId) async {
    if (userId.isEmpty) return;
    try {
      // Cập nhật trường is_locked thành false
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .update({'is_locked': false});

      // Hiển thị thông báo (có thể dùng SnackBar trong thực tế)
      print('Tài khoản $userId đã được mở khóa.');

      // Tải lại danh sách để tài khoản vừa mở khóa biến mất khỏi danh sách
      await _loadLockedUsers(facultyId); 

      // Optional: Show success message via SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã mở khóa tài khoản $userId')),
      );

    } catch (e) {
      print('Lỗi mở khóa user $userId: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi mở khóa: $e')),
      );
    }
  }

  // Lấy danh sách User theo khoa VÀ is_locked = true
  Future<void> _loadLockedUsers(String facultyId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('faculty_id', isEqualTo: facultyId)
          // THÊM ĐIỀU KIỆN LỌC is_locked = true
          .where('is_locked', isEqualTo: true)
          .get();

      final List<Map<String, dynamic>> loadedAccounts = snapshot.docs.map((
        doc,
      ) {
        final data = doc.data();
        return {
          'id': doc.id, // mã sinh viên
          'fullname': data['fullname'] ?? 'Không tên',
          'email': data['email'] ?? '',
          'faculty_id': data['faculty_id'] ?? '',
          'avt': data['avt'] ?? 'assets/images/user_avt.png',
        };
      }).toList();

      setState(() {
        _accounts = loadedAccounts;
        _filteredAccounts = loadedAccounts;
      });
    } catch (e) {
      print('Lỗi tải user bị khóa: $e');
      setState(() {
        _accounts = [];
        _filteredAccounts = [];
      });
    }
  }

  // Lọc theo từ khóa tìm kiếm
  void _locTheoTimKiem(String query) {
    final lower = query.toLowerCase();
    setState(() {
      _filteredAccounts = _accounts.where((user) {
        final name = (user['fullname'] ?? '').toLowerCase();
        final id = (user['id'] ?? '').toLowerCase();
        return name.contains(lower) || id.contains(lower) || query.isEmpty;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 20),
            _buildDropdown(),
            const SizedBox(height: 20),
            _buildListHeader(),
            const SizedBox(height: 10),
            _buildAccountList(),
          ],
        ),
      ),
    );
  }

  // AppBar
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Truy Xuất Tài Khoản Bị Khóa'),
      titleTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Image.asset("assets/icons/ic_back.png", width: 32, height: 32),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: const [SizedBox(width: 48)],
    );
  }

  // Ô tìm kiếm
  Widget _buildSearchBar() {
    return Customsearch(
      onTap: (value) {
        _locTheoTimKiem(value);
      },
    );
  }

  // Dropdown chọn khoa
  Widget _buildDropdown() {
    if (isLoadingFaculties) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(66, 0, 0, 0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedFacultyId,
          items: faculties.map((khoa) {
            return DropdownMenuItem<String>(
              value: khoa['id'],
              child: Text(khoa['name']?.toString() ?? ''),
            );
          }).toList(),
          onChanged: (newValue) async {
            if (newValue == null) return;
            setState(() {
              selectedFacultyId = newValue;
              _accounts = [];
              _filteredAccounts = [];
            });
            // Gọi hàm mới đã sửa đổi
            await _loadLockedUsers(newValue);
          },
        ),
      ),
    );
  }

  //Header danh sách
  Widget _buildListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Danh sách tài khoản bị khóa",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          "Kết quả: ${_filteredAccounts.length}",
          style: const TextStyle(color: Colors.black),
        ),
      ],
    );
  }

  // Danh sách tài khoản
  Widget _buildAccountList() {
    if (_filteredAccounts.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text(
            "Không có tài khoản bị khóa nào",
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: _filteredAccounts.length,
        itemBuilder: (context, index) {
          return _buildAccountItem(_filteredAccounts[index]);
        },
      ),
    );
  }

  // Item tài khoản (ĐÃ SỬA ĐỔI LẠI VỊ TRÍ NÚT MỞ KHÓA)
  Widget _buildAccountItem(Map<String, dynamic> user) {
    final String userId = user['id'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black87, width: 1),
        borderRadius: BorderRadius.circular(18),
        color: const Color.fromARGB(255, 255, 230, 230), 
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Giữ các item căn trên
        children: [
          // 1. Avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: user["avt"] != null && user["avt"].toString().isNotEmpty
                ? Image.network(
                    user["avt"],
                    width: 45,
                    height: 45,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    "assets/images/user.png",
                    width: 45,
                    height: 45,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: 12),
          
          // 2. Thông tin (Tên và ID/Nút Mở khóa)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên (Hàng trên, chiếm hết chiều rộng)
                Text(
                  user["fullname"] ?? "",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.red, 
                  ),
                ),
                
                // Hàng chứa ID và Nút Mở khóa
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ID (Bên trái)
                    Expanded(
                      child: Text(
                        user["id"] ?? "",
                        style: const TextStyle(color: Colors.black54, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // NÚT MỞ KHÓA
                    ElevatedButton(
                      onPressed: () {
                        if (selectedFacultyId != null) {
                          _unlockUser(userId, selectedFacultyId!);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 
                        minimumSize: Size.zero, 
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), 
                        ),
                      ),
                      child: const Text(
                        'Mở khóa', 
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold), 
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}