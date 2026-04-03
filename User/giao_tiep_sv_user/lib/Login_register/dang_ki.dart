import 'dart:math';

import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Data/groups.dart';
import 'package:giao_tiep_sv_user/Data/groups_members.dart';
import 'package:giao_tiep_sv_user/maneger_member_group_Screens/serviceGroup/groupService.dart';
import 'package:uuid/uuid.dart';
import 'dang_nhap.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DangKi extends StatefulWidget {
  const DangKi({super.key});

  @override
  State<DangKi> createState() => _DangKiState();
}

class _DangKiState extends State<DangKi> {
  final groupService = GroupserviceManeger();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _hienThiLoi;

  String? tenNganh;
  String? maNganh;

  void _kiemTraEmail() async {
    String email = emailController.text.trim();
    final RegExp pattern = RegExp(
      r'^[0-9]{5}([A-Za-z]{2})[0-9]{4}@mail\.tdc\.edu\.vn$',
      caseSensitive: false,
    );

    final match = pattern.firstMatch(email);
    if (match != null) {
      String ma = match.group(1)!.toUpperCase();
      setState(() {
        maNganh = ma;
        tenNganh = "Đang kiểm tra...";
      });

      try {
        final query = await FirebaseFirestore.instance
            .collection("Faculty")
            .where("id", isEqualTo: ma.toUpperCase())
            .get();

        setState(() {
          tenNganh = query.docs.isNotEmpty
              ? query.docs.first['name']
              : "Không tìm thấy mã ngành";
        });
      } catch (e) {
        setState(() => tenNganh = "Lỗi kết nối");
      }
    } else {
      setState(() {
        maNganh = null;
        tenNganh = null;
      });
    }
  }

  // ==================== HÀM ĐĂNG KÝ ====================
  Future<void> _dangKy(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirm = confirmController.text.trim();
    final name = nameController.text.trim();

    if (email.isEmpty || password.isEmpty || confirm.isEmpty || name.isEmpty) {
      _showSnackBar("Vui lòng nhập đầy đủ thông tin!");
      return;
    }

    if (password != confirm) {
      _showSnackBar("Mật khẩu không khớp!");
      return;
    }

    final RegExp pattern = RegExp(
      r'^[0-9]{5}([A-Z]{2})[0-9]{4}@mail\.tdc\.edu\.vn$',
      caseSensitive: false,
    );

    final match = pattern.firstMatch(email);
    if (match == null) {
      _showSnackBar("Email sai định dạng!");
      return;
    }

    final ma = match.group(1)!.toUpperCase();
    final idUser = email.split('@').first.toUpperCase();

    setState(() => _isLoading = true);

    try {
      // Kiểm tra mã ngành có tồn tại không
      final query = await FirebaseFirestore.instance
          .collection("Faculty")
          .where("id", isEqualTo: ma)
          .get();

      if (query.docs.isEmpty) {
        _showSnackBar("Mã ngành $ma không tồn tại!");
        setState(() => _isLoading = false);
        return;
      }

      // Tạo tài khoản Firebase Auth
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Gửi email xác thực
      await userCredential.user!.sendEmailVerification();

      // Lưu dữ liệu người dùng vào Firestore
      await FirebaseFirestore.instance.collection("Users").doc(idUser).set({
        "email": email,
        "fullname": name,
        "phone": "",
        "address": "",
        "avt":
            "https://cellphones.com.vn/sforum/wp-content/uploads/2023/10/avatar-trang-4.jpg", // ảnh mặc định
        "role": 0,
        "faculty_id": ma,
        "is_locked": false,
      });

      _showSnackBar(
        "Đăng ký thành công!\nVui lòng kiểm tra email để xác nhận tài khoản.",
        isError: false,
      );

      await loadGroup(ma.toUpperCase(),idUser);

      // Đăng xuất user chưa xác thực
      await FirebaseAuth.instance.signOut();

      // Chờ 3s rồi chuyển sang trang đăng nhập
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DangNhap()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showSnackBar("Email đã được sử dụng!");
      } else {
        _showSnackBar("Lỗi đăng ký: ${e.message}");
      }
    } catch (e) {
      _showSnackBar("Đã xảy ra lỗi, vui lòng thử lại!");
    } finally {
      setState(() => _isLoading = false);
    }
  }
  //dua member vao group cua khoa 
  Future<void> loadGroup(String id,String idUser)async{
    List<String> listTemp = [];
    listTemp = await groupService.loadGroupsforId(id.toUpperCase());
    print("leng memeber: ${listTemp.length}");
    listTemp.forEach((element) {
      print("id gr: $element");
      Groupmember grMember = Groupmember(group_id:element , user_id: idUser, role: 0, status_id: 1, joined_at: DateTime.now());
      groupService.addDataGroupMember(grMember);
    },);
  }

  void _showSnackBar(String message, {bool isError = true}) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.4,
        left: 40,
        right: 40,
        child: Material(
          color: Colors.transparent,
          child: AnimatedOpacity(
            opacity: 1,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isError ? Colors.red.shade600 : Colors.blue.shade600,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2)).then((_) => entry.remove());
  }

  // ==================== GIAO DIỆN ====================
  @override void initState() {
    // TODO: implement initState
    super.initState();
    // loadGroup("tt", "");
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_hienThiLoi != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _hienThiLoi!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    Image.asset('assets/images/logo.png', width: 150),
                    const SizedBox(height: 20),
                    const Text(
                      "TẠO TÀI KHOẢN",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontFamily: 'Georgia',
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildEmailField(),
                    if (tenNganh != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        tenNganh!,
                        style: TextStyle(
                          color:
                              tenNganh!.contains("Không") ||
                                  tenNganh!.contains("Lỗi")
                              ? Colors.red
                              : Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    _buildNameField(),
                    const SizedBox(height: 20),
                    _buildPasswordField(),
                    const SizedBox(height: 15),
                    _buildConfirmPasswordField(),
                    const SizedBox(height: 25),
                    _buildRegisterButton(context),
                    const SizedBox(height: 20),
                    _buildLoginLink(context),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 12),
                    Text(
                      "Đang xử lý...",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // TEXT FIELDS
  Widget _buildEmailField() => _textField(
    emailController,
    Icons.email,
    'Email sinh viên',
    onChanged: (_) => _kiemTraEmail(),
  );

  Widget _buildNameField() =>
      _textField(nameController, Icons.person, 'Họ và tên');

  Widget _buildPasswordField() => _textField(
    passwordController,
    Icons.lock,
    'Mật khẩu',
    obscure: _obscurePassword,
    suffixIcon: IconButton(
      icon: Icon(
        _obscurePassword ? Icons.visibility_off : Icons.visibility,
        color: Colors.black54,
      ),
      onPressed: () => setState(() {
        _obscurePassword = !_obscurePassword;
      }),
    ),
  );

  Widget _buildConfirmPasswordField() => _textField(
    confirmController,
    Icons.lock_outline,
    'Xác nhận mật khẩu',
    obscure: _obscureConfirm,
    suffixIcon: IconButton(
      icon: Icon(
        _obscureConfirm ? Icons.visibility_off : Icons.visibility,
        color: Colors.black54,
      ),
      onPressed: () => setState(() {
        _obscureConfirm = !_obscureConfirm;
      }),
    ),
  );

  Widget _textField(
    TextEditingController controller,
    IconData icon,
    String hint, {
    bool obscure = false,
    Widget? suffixIcon,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.black),
        suffixIcon: suffixIcon,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1F65DE),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        onPressed: _isLoading ? null : () => _dangKy(context),
        child: const Text(
          "Đăng ký",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Bạn đã có tài khoản? "),
        GestureDetector(
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DangNhap()),
          ),
          child: const Text(
            "Đăng nhập",
            style: TextStyle(
              color: Color(0xFF1F65DE),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
