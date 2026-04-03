import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_admin/Admin/Home.dart';
import 'package:giao_tiep_sv_admin/Login_QuenMK_Screens/quen_mk.dart';

class DangNhapAdmin extends StatefulWidget {
  const DangNhapAdmin({super.key});

  @override
  State<DangNhapAdmin> createState() => _DangNhapAdminState();
}

class _DangNhapAdminState extends State<DangNhapAdmin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _welcomeMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _dangNhap() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Vui lòng nhập đầy đủ thông tin!");
      return;
    }

    setState(() {
      _isLoading = true;
      _welcomeMessage = null;
    });

    try {
      UserCredential userCred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      final userDoc = await _firestore
          .collection('Users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userDoc.docs.isEmpty) {
        _showSnackBar("Tài khoản không tồn tại trong hệ thống!");
        return;
      }

      final role = userDoc.docs.first.data()['role'] ?? 0;
      if (role != 1) {
        _showSnackBar("Tài khoản không có quyền Admin!");
        return;
      }

      // Hiển thị banner thông báo xin chào
      setState(() {
        _welcomeMessage = "Xin chào Admin!";
      });

      // Chờ 1.5 giây trước khi chuyển màn hình
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const AdminScreen()));

    } on FirebaseAuthException catch (e) {
      _showSnackBar("Lỗi đăng nhập: ${e.message}");
    } catch (e) {
      _showSnackBar("Lỗi hệ thống: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.redAccent,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Image.asset('assets/images/logo.png', width: 150),
                const SizedBox(height: 20),
                const Text(
                  "ĐĂNG NHẬP ADMIN",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontFamily: 'Georgia',
                  ),
                ),
                const SizedBox(height: 30),

                // Banner thông báo xin chào
                if (_welcomeMessage != null)
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      _welcomeMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),

                // Email field
                _buildInputField(
                  controller: _emailController,
                  hintText: "Email ",
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                // Password field
                _buildInputField(
                  controller: _passwordController,
                  hintText: "Mật khẩu",
                  icon: Icons.lock,
                  obscureText: !_isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() => _isPasswordVisible = !_isPasswordVisible);
                    },
                  ),
                ),
                const SizedBox(height: 10),

                const SizedBox(height: 20),

                // Button Đăng nhập
                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _dangNhap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1F65DE),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            "Đăng nhập",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black),
          suffixIcon: suffixIcon,
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black54, fontSize: 13),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }
}
