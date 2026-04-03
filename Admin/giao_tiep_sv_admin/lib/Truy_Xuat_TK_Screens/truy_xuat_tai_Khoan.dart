import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chi_tiet_tai_khoan.dart';
import 'package:giao_tiep_sv_admin/widget/customSearch.dart';

class TruyXuatTaiKhoan extends StatefulWidget {
  const TruyXuatTaiKhoan({super.key});

  @override
  State<TruyXuatTaiKhoan> createState() => _TruyXuatTaiKhoanState();
}

class _TruyXuatTaiKhoanState extends State<TruyXuatTaiKhoan> {
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
        await _loadUsers(selectedFacultyId!);
      }
    } catch (e) {
      print('Lỗi tải khoa: $e');
      setState(() => isLoadingFaculties = false);
    }
  }

  // Lấy danh sách User theo khoa
  Future<void> _loadUsers(String facultyId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('faculty_id', isEqualTo: facultyId)
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
      print('Lỗi tải user: $e');
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
      title: const Text('Truy Xuất Tài Khoản'),
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
            await _loadUsers(newValue);
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
          "Danh sách tài khoản",
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
            "Không có dữ liệu",
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

  // Item tài khoản
  Widget _buildAccountItem(Map<String, dynamic> user) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChiTietTaiKhoan(
              mssv: user["id"], // CHỈ CẦN MSSV
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black87, width: 1),
          borderRadius: BorderRadius.circular(18),
          color: const Color.fromARGB(255, 255, 250, 250),
        ),
        child: Row(
          children: [
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user["fullname"] ?? "",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  user["id"] ?? "",
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
