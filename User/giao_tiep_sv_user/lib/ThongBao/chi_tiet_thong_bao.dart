import 'package:flutter/material.dart';

class ChiTietThongBao extends StatelessWidget {
  final String tieuDe;
  final String noiDung;

  const ChiTietThongBao({
    super.key,
    required this.tieuDe,
    required this.noiDung,
  }); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Image.asset('assets/icons/ic_back.png', width: 24, height: 24),
        ),
        title: Text(
          tieuDe,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(noiDung, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
