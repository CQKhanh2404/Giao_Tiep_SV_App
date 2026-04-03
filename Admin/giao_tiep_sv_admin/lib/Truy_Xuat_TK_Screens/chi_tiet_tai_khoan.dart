import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChiTietTaiKhoan extends StatefulWidget {
  final String mssv; // Document ID = mã sinh viên

  const ChiTietTaiKhoan({
    super.key,
    required this.mssv,
  });

  @override
  State<ChiTietTaiKhoan> createState() => _ChiTietTaiKhoanState();
}

class _ChiTietTaiKhoanState extends State<ChiTietTaiKhoan> {
  Map<String, dynamic>? userData;
  String? facultyName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // 1. LẤY USER THEO mssv (document ID)
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.mssv)
          .get();

      if (!userDoc.exists) {
        setState(() => isLoading = false);
        return;
      }

      final data = userDoc.data()!;
      final String facultyId = data['faculty_id'] ?? '';

      // 2. LẤY TÊN KHOA TỪ Faculty
      String name = '';
      if (facultyId.isNotEmpty) {
        final facultyQuery = await FirebaseFirestore.instance
            .collection('Faculty')
            .where('id', isEqualTo: facultyId)
            .limit(1)
            .get();

        if (facultyQuery.docs.isNotEmpty) {
          name = facultyQuery.docs.first['name'] ?? facultyId;
        }
      }

      setState(() {
        userData = data;
        facultyName = name;
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userData == null) {
      return const Scaffold(
        body: Center(child: Text("Không tìm thấy người dùng")),
      );
    }

    final String ten = userData!['fullname'] ?? 'Không tên';
    final String email = userData!['email'] ?? '';
    final String avtUrl = userData!['avt'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chi Tiết Tài Khoản',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // ẢNH ĐẠI DIỆN
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFFE0E0E0),
              backgroundImage: avtUrl.isNotEmpty
                  ? NetworkImage(avtUrl) as ImageProvider
                  : const AssetImage('assets/images/user.png'),
            ),
            const SizedBox(height: 15),

            // TÊN + MSSV
            Text(
              ten,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.2),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              widget.mssv,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 30),

            // THÔNG TIN CHI TIẾT
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.school, "Ngành", facultyName ?? 'Không xác định'),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.email, "Email", email),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.phone, "SĐT", userData!['phone'] ?? 'Chưa có'),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.location_on, "Địa chỉ", userData!['address'] ?? 'Chưa có'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HÀM TẠO DÒNG THÔNG TIN
 static Widget _buildInfoRow(IconData icon, String title, String value) {
  return Row(
    children: [
      Icon(icon, color: const Color(0xFF1F65DE)),
      const SizedBox(width: 10),
      Text(
        "$title: ",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      Expanded(
        child: Text(
          value,
          style: const TextStyle(fontSize: 17),
          softWrap: false,  // KHÔNG ĐƯỢNG HÀNG
          overflow: TextOverflow.ellipsis,  // HIỆN "..." NẾU DÀI
          maxLines: 1,  // CHỈ 1 DÒNG
        ),
      ),
    ],
  );
}
}