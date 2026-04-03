import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/ProfileService.dart';
import 'package:giao_tiep_sv_user/Login_register/dang_nhap.dart';
import 'package:giao_tiep_sv_user/Profile/Widget/avatarWidget.dart';
import 'package:giao_tiep_sv_user/Profile/editProflie/edit_profile_screen.dart';
import 'package:giao_tiep_sv_user/Profile/editProflie/models/profile_model.dart';
import 'package:giao_tiep_sv_user/Profile/personalPost/personal_post_screen.dart';
import 'package:giao_tiep_sv_user/Profile/saveItemsProfile/saved_items_profile_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Dữ liệu profile - có thể cập nhật được
  String _userName = "Đang tải...";
  String _avatarUrl = "";
  String _major = "Đang tải...";
  String _schoolYear = "Đang tải...";
  String _address = "";
  String _phone = "";
  File? _avatarFile;
  String _userId = "";

  final ProfileService _profileService = ProfileService();
  bool _isLoading = true;
  late StreamSubscription<ProfileModel?> _profileStream;
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // Hàm tải dữ liệu từ Firebase
  Future<void> _loadProfile() async {
    _profileStream = _profileService.getProfileStream().listen(
      (profile) async {
        if (profile == null || !mounted) return;

        try {
          // Lấy major + schoolYear
          final facultyInfo = await _profileService.layNganhVaNienKhoa(
            profile.email,
            profile.faculty.faculty_id,
          );

          setState(() {
            _userName = profile.name;
            _avatarUrl = profile.avatarUrl.trim();
            _address = profile.address;
            _phone = profile.phone;
            _major = facultyInfo['major'] ?? 'Không tìm thấy';
            _schoolYear = facultyInfo['schoolYear'] ?? 'Không tìm thấy';
            _userId = _profileService.getUserId();
            _isLoading = false;
          });
        } catch (e) {
          print('Lỗi khi lấy ngành/năm: $e');
          if (mounted) {
            setState(() {
              _major = 'Lỗi tải dữ liệu';
              _isLoading = false;
            });
          }
        }
      },
      onError: (e) {
        print('Lỗi stream profile: $e');
        setState(() {
          _isLoading = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _profileStream.cancel();
    super.dispose();
  }

  // Hàm để cập nhật dữ liệu từ EditProfileScreen
  void _updateProfile(
    String newName,
    String newAvatarPath,
    String newAdress,
    String newPhone,
  ) {
    setState(() {
      _userName = newName;
      _address = newAdress;
      _phone = newPhone;

      if (newAvatarPath.startsWith('/')) {
        // Đây là file local
        _avatarFile = File(newAvatarPath);
        _avatarUrl = "";
      } else {
        // Đây là URL network
        _avatarUrl = newAvatarPath;
        _avatarFile = null;
      }
    });
    // Reload lại dữ liệu từ Firebase để đảm bảo đồng bộ
    _loadProfile();
  }

  // Hàm cắt chuỗi nếu quá dài
  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Hàm mở liên kết web
  Future<void> _launchWebsite() async {
    final Uri url = Uri.parse('https://tdc.edu.vn/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Không thể mở liên kết $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thông tin avatar + tên
              Row(
                children: [
                  AvatarWidget(
                    avatarUrl: _avatarUrl,
                    avatarFile: _avatarFile,
                    radius: 35,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _truncateText(_userName, 16),
                            style: const TextStyle(
                              fontSize: 21,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                "Ngành học: ",
                                style: TextStyle(color: Colors.black54),
                              ),
                              Text(
                                _truncateText(_major, 16),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              const Text(
                                "Niên khóa: ",
                                style: TextStyle(color: Colors.black54),
                              ),
                              Text(
                                _schoolYear,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Thông tin chung
              const Text(
                "Thông tin chung",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 10),

              ListTile(
                leading: const Icon(Icons.person_outline, color: Colors.blue),
                title: const Text("Chỉnh sửa thông tin"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 20),
                onTap: () async {
                  // Chờ kết quả từ EditProfileScreen
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      // lấy đa
                      builder: (context) => EditProfileScreen(
                        onProfileUpdated: _updateProfile,
                        currentName: _userName,
                        currentAvatarUrl: _avatarUrl,
                        currentAddress: _address,
                        currentPhone: _phone,
                        currentAvatarFile: _avatarFile,
                      ),
                    ),
                  );

                  // Nếu có kết quả trả về, cập nhật profile
                  if (result != null && result is Map) {
                    _updateProfile(
                      result['name'] ?? _userName,
                      result['avatarUrl'] ?? _avatarUrl,
                      result['address'] ?? _address,
                      result['phone'] ?? _phone,
                    );
                  }
                },
              ),

              ListTile(
                leading: const Icon(Icons.article_outlined, color: Colors.blue),
                title: const Text("Bài viết"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PersonalPostScreen(
                        userName: _userName,
                        avatarUrl: _avatarUrl,
                        avatarFile: _avatarFile,
                        currentUserId: _userId,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.bookmark_border, color: Colors.blue),
                title: const Text("Mục đã lưu"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SavedItemsProfileScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),
              const Text(
                "Liên kết",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 10),

              ListTile(
                leading: const Icon(Icons.language, color: Colors.blue),
                title: const Text("Website trường TDC"),
                onTap: _launchWebsite, // ✅ mở website khi click
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.blue),
                title: const Text("Đăng xuất"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const DangNhap();
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
