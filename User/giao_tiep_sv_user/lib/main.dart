import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giao_tiep_sv_user/Home_screen/Home/Home_screen/Group_create/nhom_cua_toi.dart';
import 'package:giao_tiep_sv_user/Home_screen/home.dart';
import 'package:giao_tiep_sv_user/Login_register/dang_ki.dart';
import 'package:giao_tiep_sv_user/Login_register/dang_nhap.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Hàm khởi chạy ứng dụng: khởi tạo Firebase rồi chạy app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Cho phép xoay ngang và dọc
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

// Widget gốc của ứng dụng, cấu hình theme và trang khởi đầu là màn hình Đăng Nhập
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      home: DangNhap(), // Trang mặc định
    );
  }
}
