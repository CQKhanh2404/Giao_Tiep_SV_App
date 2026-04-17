import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 👈 thêm dòng này

// Màn hình Quên Mật Khẩu: gửi email đặt lại mật khẩu qua Firebase Auth
class QuenMatKhau extends StatefulWidget {
  const QuenMatKhau({super.key});

  @override
  State<QuenMatKhau> createState() => _QuenMatKhauState();
}

class _QuenMatKhauState extends State<QuenMatKhau> {
  final _emailController = TextEditingController();
  String? _emailError;
  bool _isLoading = false; // 👈 thêm biến loading
  final _emailRegex = RegExp(r'^[0-9]{5}[A-Za-z]{2}[0-9]{4}@mail\.tdc\.edu\.vn$');

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Xác thực email và gửi link đặt lại mật khẩu qua Firebase Auth
  Future<void> _validateAndSubmit() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _emailError = 'Vui lòng nhập email');
      return;
    }

    if (!_emailRegex.hasMatch(email)) {
      setState(() => _emailError = 'Email phải thuộc định dạng: @mail.tdc.edu.vn');
      return;
    }

    setState(() {
      _emailError = null;
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Liên kết đặt lại mật khẩu đã được gửi!\nVui lòng kiểm tra hộp thư.',
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context); // Quay lại trang đăng nhập
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'Không tìm thấy tài khoản với email này!';
      } else {
        message = 'Lỗi: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, textAlign: TextAlign.center),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'QUÊN MẬT KHẨU',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).orientation ==
                          Orientation.landscape
                      ? 450
                      : double.infinity,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      const Text(
                        'Nhập Email của bạn,\nchúng tôi sẽ gửi liên kết đặt lại mật khẩu',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Email',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          errorText: _emailError,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          if (_emailError != null) {
                            setState(() {
                              _emailError = null;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _validateAndSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1F65DE),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  'Gửi yêu cầu',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
