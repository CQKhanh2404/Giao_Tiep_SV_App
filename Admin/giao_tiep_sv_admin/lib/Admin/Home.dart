import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_admin/Admin/duyet_nhom_admin/duyet_nhom_admin.dart';
import 'package:giao_tiep_sv_admin/Gui_Thong_bao/view/Notifycation_Sceen.dart';
import 'package:giao_tiep_sv_admin/Tao_nhom_cong_Dong/view/Create_group_community.dart';
import 'package:giao_tiep_sv_admin/Truy_Xuat_TK_Screens/truy_xuat_tai_Khoan.dart';
import 'package:giao_tiep_sv_admin/lock_person/lock_person.dart';
import 'bao_cao_vi_pham.dart';

/// Màn hình tổng quan của Admin: hiển thị các chức năng quản trị chính
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'ADMIN',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Icon(Icons.person, color: Colors.black, size: 30),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 30),
              _buildAdminButton(
                context,
                icon: Icons.verified_user_outlined,
                text: 'Báo cáo vi phạm',
                color: const Color(0xFFFFEBEE),
                iconColor: Colors.green,
                onPressed: () {
                  // Chuyển đến màn hình báo cáo vi phạm
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReportScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),

              // Nút "Truy xuất tài khoản member"
              _buildAdminButton(
                context,
                icon: Icons.people_alt, // Icon người dùng
                text: 'Truy xuất tài khoản',
                color: const Color(0xFFE8F5E9), // Màu xanh lá nhạt
                iconColor: Colors.blue, // Màu icon xanh dương
                onPressed: () {
                  // Xử lý khi nhấn nút
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TruyXuatTaiKhoan()),
                  );
                },
              ),
              const SizedBox(height: 15),

              _buildAdminButton(
                context,
                icon: Icons.lock_person, // Icon người dùng
                text: 'Tài khoản bị khóa',
                color: const Color.fromARGB(255, 222, 126, 71),
                iconColor: Colors.blue, // Màu icon xanh dương
                onPressed: () {
                  // Xử lý khi nhấn nút
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LockPerson()),
                  );
                },
              ),
              const SizedBox(height: 15),

              // Nút "Tạo nhóm cộng đồng"
              _buildAdminButton(
                context,
                icon: Icons.groups, // Icon nhóm
                text: 'Tạo nhóm cộng đồng',
                color: const Color(0xFFE3F2FD), // Màu xanh dương nhạt
                iconColor: Colors.purple, // Màu icon tím
                onPressed: () {
                  // Xử lý khi nhấn nút
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScreenCommunityGroup(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),

              // Nút "Quản lý Nhóm người dùng"
              _buildAdminButton(
                context,
                icon: Icons.list_alt,
                text: 'Quản lý nhóm người dùng',
                color: const Color(0xFFFFF8E1),
                iconColor: Color(0xFF1565C0),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DuyetNhomAdminScreen(),
                    ),
                  );
                },
              ),
              SizedBox(height: 15),
              // Nút "Quản lý bài viết và báo cáo"
              _buildAdminButton(
                context,
                icon: Icons.notification_add, // Icon báo cáo
                text: 'Gửi thông báo người dùng',
                color: const Color.fromARGB(255, 85, 138, 243), // Màu cam nhạt
                iconColor: Colors.yellow, // Màu icon đỏ
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ScreenNotify()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tạo widget nút điều hướng tái sử dụng cho trang chủ Admin
  Widget _buildAdminButton(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Color color,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity, // Chiếm toàn bộ chiều rộng có thể
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15), // Bo tròn góc
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2), // Đổ bóng nhẹ
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, color: iconColor, size: 30),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios, // Icon mũi tên bên phải
              color: Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
