import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:giao_tiep_sv_user/FireBase_Service/create_group_service.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/faculty_service.dart';
import 'package:flutter/services.dart'; // Thêm thư viện này cho InputFormatter
import '../../../../Data/global_state.dart';

class TaoNhomPage extends StatefulWidget {
  const TaoNhomPage({super.key});

  @override
  State<TaoNhomPage> createState() => _TaoNhomPageState();
}

class _TaoNhomPageState extends State<TaoNhomPage> {
  // --- Services ---
  final CreateGroupService _groupService = CreateGroupService();
  final FacultyService _facultyService = FacultyService();

  // --- Controllers và Utils ---
  final TextEditingController _tenNhomController = TextEditingController();
  final TextEditingController _moTaController = TextEditingController();
  File? _anhNhom;
  final ImagePicker _picker = ImagePicker();

  bool _isCreating = false; // Trạng thái loading

  // Màu chủ đạo
  static const Color _primaryColor = Color.fromARGB(255, 0, 85, 150); // Teal
  static const Color _backgroundColor = Color(0xFFF0F4F8);

  // HÀM TRÍCH XUẤT MÃ KHOA TỪ ID NGƯỜI DÙNG (Giữ nguyên)
  String _extractFacultyCode(String userId) {
    if (userId.isEmpty) return '';
    final RegExp facultyRegex = RegExp(r'[A-Z]+');
    final Iterable<RegExpMatch> matches = facultyRegex.allMatches(userId);
    if (matches.isNotEmpty) {
      return matches.first.group(0)!;
    } else {
      return '';
    }
  }

  Future<void> _chonAnh() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _anhNhom = File(image.path);
      });
    }
  }

  void _taoNhom() async {
    String ten = _tenNhomController.text.trim();
    String moTa = _moTaController.text.trim();

    // 1. Kiểm tra điều kiện đầu vào cơ bản
    if (ten.isEmpty || moTa.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập đầy đủ Tên và Mô tả nhóm! ⚠️"),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final userId = GlobalState.currentUserId;
    final fullname = GlobalState.currentFullname;
    final facultyCode = _extractFacultyCode(userId);

    // Kiểm tra thông tin người dùng
    if (userId.isEmpty || facultyCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Lỗi: Không tìm thấy thông tin đăng nhập hoặc Mã Khoa. Vui lòng đăng nhập lại.",
          ),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    // 2. Tải động tên khoa từ Faculty Service
    final facultyIdMap = await _facultyService.fetchFacultyIdMap(facultyCode);

    if (facultyIdMap == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Lỗi: Không tìm thấy thông tin khoa hợp lệ trong Database. ❌",
          ),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isCreating = false;
      });
      return;
    }

    // 3. Gọi Service tạo nhóm
    final success = await _groupService.createGroup(
      creatorUserId: userId,
      creatorFullname: fullname,
      name: ten,
      description: moTa,
      groupImage: _anhNhom,
      facultyId: facultyIdMap, // TRUYỀN MAP TÊN KHOA ĐÃ LẤY ĐƯỢC
    );

    setState(() {
      _isCreating = false;
    });

    // 4. Xử lý kết quả
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Nhóm "$ten" đã được tạo thành công!'),
          duration: const Duration(seconds: 2),
          backgroundColor: _primaryColor,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Lỗi: Không thể tạo nhóm. Vui lòng thử lại.'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- Widgets---
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    int maxLines = 1,
    int? maxLength, // Thêm tham số maxLength
  }) {
    // Thêm InputFormatter để giới hạn ký tự
    final List<TextInputFormatter> formatters = [];
    if (maxLength != null) {
      formatters.add(LengthLimitingTextInputFormatter(maxLength));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength, // Hiển thị bộ đếm ký tự
          inputFormatters: formatters, // Áp dụng giới hạn ký tự
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            // Xóa khoảng trống của counterText khi không cần thiết
            counterText: maxLength != null ? null : '',
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primaryColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupImagePicker() {
    return Center(
      child: Column(
        children: [
          const Text(
            "Ảnh nhóm:",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: _chonAnh,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: _primaryColor, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _anhNhom != null
                  ? ClipOval(child: Image.file(_anhNhom!, fit: BoxFit.cover))
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 40, color: _primaryColor),
                        SizedBox(height: 4),
                        Text(
                          "Chọn ảnh",
                          style: TextStyle(color: _primaryColor),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        // Vô hiệu hóa nút khi đang tạo
        onPressed: _isCreating ? null : _taoNhom,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor, // Màu chủ đạo
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
          elevation: 5, // Thêm đổ bóng
        ),
        child: _isCreating
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : const Text(
                "TẠO NHÓM",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Tạo Nhóm Mới",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGroupImagePicker(),
              const SizedBox(height: 30),
              _buildTextField(
                controller: _tenNhomController,
                labelText: "Tên nhóm:",
                hintText: "Nhập tên nhóm...",
                maxLength: 100, // Giới hạn tên nhóm 100 ký tự
              ),
              const SizedBox(height: 25),
              _buildTextField(
                controller: _moTaController,
                labelText: "Mô tả nhóm:",
                hintText: "Mô tả ngắn về mục đích của nhóm...",
                maxLines: 4,
                maxLength: 250, // **GIỚI HẠN 250 KÝ TỰ**
              ),
              const SizedBox(height: 50),
              _buildCreateButton(),
            ],
          ),
        ),
      ),
    );
  }
}
