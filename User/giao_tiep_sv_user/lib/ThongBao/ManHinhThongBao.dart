import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Data/Users.dart';
import 'package:giao_tiep_sv_user/Data/Notifycation.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/notifycationFirebase.dart';
import 'package:giao_tiep_sv_user/ThongBao/chi_tiet_thong_bao.dart';
import 'package:giao_tiep_sv_user/Widget/headerWidget.dart';
import 'package:intl/intl.dart'; // <<< 1. THÊM IMPORT NÀY
import 'package:cloud_firestore/cloud_firestore.dart'; // Cần thiết cho Timestamp
import 'TieuDe.dart';
import 'OThongBao.dart';

class ManHinhThongBao extends StatefulWidget {
  final Users currentUser;
  final Notifycationfirebase notifyService = Notifycationfirebase();

  ManHinhThongBao({required this.currentUser, super.key});

  @override
  State<ManHinhThongBao> createState() => _ManHinhThongBaoState();
}

class _ManHinhThongBaoState extends State<ManHinhThongBao> {
  // 1. Thêm controller và biến trạng thái tìm kiếm
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    // Lắng nghe thay đổi của TextField
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    // Giải phóng controller khi widget bị hủy
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Cập nhật biến trạng thái tìm kiếm, gọi setState để rebuild widget
    setState(() {
      _searchText = _searchController.text.toLowerCase();
    });
  }

  void _handleNotificationTap(Notifycation tb) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChiTietThongBao(
          tieuDe: tb.title,
          noiDung: tb.content,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              // Header
              Headerwidget(
                myUs: widget.currentUser,
                width: widthScreen,
                chucnang: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Image.asset(
                    "assets/icons/ic_back.png",
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const TieuDeThongBao(),
              const SizedBox(height: 20),

              // Thêm ô tìm kiếm
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Tìm kiếm thông báo...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  ),
                ),
              ),

              // Danh sách thông báo
              Expanded(
                child: StreamBuilder<List<Notifycation>>(
                  // Stream đã được sắp xếp bởi server (trong notifycationFirebase)
                  stream: widget.notifyService.getAllNotifycation(),
                  // stream: widget.notifyService.getNotifycationForUser(
                  //    widget.currentUser.id_user.toUpperCase()
                    
                  //   ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Lỗi: ${snapshot.error}",
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("Không có thông báo nào"));
                    }

                    final allNotify = snapshot.data!;
                    final userId = widget.currentUser.id_user;
                    final facultyId = widget.currentUser.faculty_id;

                    // Lọc thông báo cho user hiện tại
                  print('userId = "$userId"');
print('facultyId = "$facultyId"');
print('allNotify.length = ${allNotify.length}');
allNotify.forEach((n) => print('recipients keys: ${n.user_recipient_ID.keys}'));


                    final notifyForUser = allNotify.where((tb) {
                      final recipients = tb.user_recipient_ID.keys.toSet();
                      final matchUser = recipients.contains(userId.toUpperCase());
                      final matchFaculty = facultyId != null && recipients.contains(facultyId);
                      return matchUser || matchFaculty;
                    }).toList();

                    // Lọc theo từ khóa tìm kiếm
                    final filteredNotify = notifyForUser.where((tb) {
                      if (_searchText.isEmpty) {
                        return true; // Nếu không có từ khóa tìm kiếm, hiển thị tất cả
                      }
                      // Tìm kiếm theo tiêu đề hoặc nội dung
                      return tb.title.toLowerCase().contains(_searchText) ||
                          tb.content.toLowerCase().contains(_searchText);
                    }).toList()
                      // Sắp xếp mới nhất lên đầu dựa theo created_at
                      ..sort((a, b) {
                        // Đẩy các thông báo thiếu timestamp xuống cuối danh sách
                        if (a.created_at == null) return 1;
                        if (b.created_at == null) return -1;

                        // Sắp xếp giảm dần (b.compareTo(a) => mới nhất lên đầu)
                        return b.created_at!.compareTo(a.created_at!);
                      });

                    if (filteredNotify.isEmpty) {
                      return Center(
                        child: Text(_searchText.isEmpty
                            ? "Không có thông báo dành cho bạn"
                            : "Không tìm thấy thông báo nào khớp với \"${_searchController.text}\""),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: filteredNotify.length,
                      itemBuilder: (context, index) {
                        final tb = filteredNotify[index];
                        
                        // 2. LẤY VÀ ĐỊNH DẠNG THỜI GIAN
                        String timeString = '';
                        if (tb.created_at != null && tb.created_at is Timestamp) {
                          // Chuyển Timestamp sang DateTime
                          final DateTime dateTime = (tb.created_at as Timestamp).toDate();
                          // Định dạng
                          timeString = formatTimeAgo(dateTime);
                        } else {
                          // Trường hợp created_at không có hoặc không phải Timestamp
                          timeString = 'Không rõ thời gian';
                        }
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: OThongBao(
                            tieuDe: tb.title,
                            noiDung: tb.content,
                            // 3. TRUYỀN THỜI GIAN ĐÃ ĐỊNH DẠNG VÀO OThongBao
                            thoiGian: timeString, 
                            onTap: () => _handleNotificationTap(tb),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// hàm định dạng thời gian "time ago"
String formatTimeAgo(DateTime time) {
  final Duration diff = DateTime.now().difference(time);

  if (diff.inDays > 7) {
    // Nếu quá 7 ngày, hiển thị ngày tháng năm đầy đủ
    return DateFormat('dd/MM/yyyy HH:mm').format(time); 
  } else if (diff.inDays > 0) {
    return '${diff.inDays} ngày trước';
  } else if (diff.inHours > 0) {
    return '${diff.inHours} giờ trước';
  } else if (diff.inMinutes > 0) {
    return '${diff.inMinutes} phút trước';
  } else {
    return 'Vừa xong';
  }
}