import 'package:flutter/material.dart';

class TieuDeThongBao extends StatelessWidget {
  const TieuDeThongBao({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Thông Báo Gần Đây",
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
