import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_admin/Admin/Home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

/// Điểm khởi đầu ứng dụng: khởi tạo Firebase trước khi chạy app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

/// Widget gốc của ứng dụng, cấu hình theme và màn hình mặc định (AdminScreen)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // ẩn banner debug
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: AdminScreen(), // Trang mặc định
    );
  }
}
