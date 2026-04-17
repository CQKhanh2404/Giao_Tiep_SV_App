import 'dart:async';
import 'dart:io';
import 'package:giao_tiep_sv_user/Data/faculty.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/ProfileService.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Profile/editProflie/models/profile_model.dart';
import 'package:giao_tiep_sv_user/Profile/editProflie/widgets/confirm_button_widget.dart';
import 'package:giao_tiep_sv_user/Profile/editProflie/widgets/profile_text_field_widget.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final Function(String, String, String, String)? onProfileUpdated;
  final String currentName;
  final String currentAvatarUrl;
  final String currentAddress;
  final String currentPhone;
  final File? currentAvatarFile;

  const EditProfileScreen({
    super.key,
    this.onProfileUpdated,
    required this.currentName,
    required this.currentAvatarUrl,
    required this.currentAddress,
    required this.currentPhone,
    this.currentAvatarFile,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late ProfileModel _profile;
  final ProfileService _profileService = ProfileService();

  File? _avatarImage;
  final ImagePicker _picker = ImagePicker();
  static const Color _primaryColor = Color.fromARGB(255, 0, 85, 150);

  bool _hasChanges = false;
  bool _isLoading = false; // Thêm biến loading
  bool _isInitializing = true; // Thêm biến để theo dõi khởi tạo

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;

  StreamSubscription<ProfileModel?>? _profileStream;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _avatarImage = widget.currentAvatarFile;

    _nameController = TextEditingController(text: widget.currentName);
    _emailController = TextEditingController();
    _addressController = TextEditingController(text: widget.currentAddress);
    _phoneController = TextEditingController(text: widget.currentPhone);

    _nameController.addListener(_checkForChanges);
    _addressController.addListener(_checkForChanges);
    _phoneController.addListener(_checkForChanges);

    // Hàm bắt sự kiện realtime
    _startProfileStream();
  }

  Future<void> _loadProfileData() async {
    try {
      setState(() {
        _isInitializing = true;
      });
      // gán trước dl rỗng cho _profile trước khi _loadProfileData
      _profile = ProfileModel(
        name: '',
        email: '',
        address: '',
        phone: '',
        avatarUrl: '',
        faculty: Faculty(faculty_id: '', name_faculty: ''),
        roleId: '',
      );
      final profile = await _profileService.getProfile();

      if (profile != null) {
        setState(() {
          _profile = profile;
          _nameController.text = profile.name;
          _emailController.text = profile.email;
          _addressController.text = profile.address;
          _phoneController.text = profile.phone;
        });
      } else {
        throw Exception("Không tìm thấy dữ liệu hồ sơ trên Firestore");
      }
    } catch (e) {
      print('❌ Lỗi khi load profile: $e');

      // Hiển thị thông báo lỗi (ví dụ bằng SnackBar)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Không thể tải dữ liệu hồ sơ. Vui lòng thử lại!"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  // THÊM: Lắng nghe stream realtime
  void _startProfileStream() {
    _profileStream = _profileService.getProfileStream().listen(
      (profile) {
        if (profile != null && mounted) {
          setState(() {
            _profile = profile;
            _nameController.text = profile.name;
            _emailController.text = profile.email;
            _addressController.text = profile.address;
            _phoneController.text = profile.phone;
            _avatarImage = null; // Reset ảnh local nếu thay đổi từ xa
            _isInitializing = false;
            _isLoading = false;
          });
        }
      },
      onError: (e) {
        print('Lỗi stream profile: $e');
        setState(() => _isLoading = false);
      },
    );
  }

  void _checkForChanges() {
    final hasTextChanges =
        _nameController.text != widget.currentName ||
        _addressController.text != widget.currentAddress ||
        _phoneController.text != widget.currentPhone;

    final hasImageChanges = _avatarImage != widget.currentAvatarFile;

    setState(() {
      _hasChanges = hasTextChanges || hasImageChanges;
    });
  }

  @override
  void dispose() {
    _nameController.removeListener(_checkForChanges);
    _addressController.removeListener(_checkForChanges);
    _phoneController.removeListener(_checkForChanges);
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Thêm hàm xử lý thay đổi avatar
  Future<void> _handleChangeAvatar() async {
    // Nếu đang loading thì không cho chọn ảnh
    if (_isLoading) return;

    // Hiển thị dialog chọn nguồn ảnh
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Chọn ảnh đại diện",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Nút Camera
                _buildImageSourceButton(
                  icon: Icons.camera_alt,
                  label: "Chụp ảnh",
                  color: Colors.purple,
                  source: ImageSource.camera,
                ),
                // Nút Thư viện
                _buildImageSourceButton(
                  icon: Icons.photo_library,
                  label: "Thư viện",
                  color: Colors.blue,
                  source: ImageSource.gallery,
                ),
              ],
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Hủy",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );

    // Nếu người dùng chọn nguồn ảnh
    if (source != null) {
      await _pickImageFromSource(source);
    }
  }

  // Widget con để tạo nút chọn ảnh đẹp
  Widget _buildImageSourceButton({
    required IconData icon,
    required String label,
    required Color color,
    required ImageSource source,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, source),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(icon, size: 40, color: color),
          ),
          const SizedBox(height: 12),
          Text(label, style: TextStyle(fontSize: 15, color: Colors.grey[800])),
        ],
      ),
    );
  }

  // Hàm thực tế lấy ảnh từ nguồn đã chọn
  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 512,
        maxHeight: 512,
        preferredCameraDevice:
            CameraDevice.front, // Ưu tiên camera trước nếu là camera
      );

      if (pickedFile != null) {
        setState(() {
          _avatarImage = File(pickedFile.path);
          _hasChanges = true;
        });
        _showSuccessSnackBar('Đã chọn ảnh đại diện mới! 📸');
      }
    } catch (e) {
      print('Lỗi khi chọn ảnh: $e');
      _showErrorSnackBar('Không thể chọn ảnh. Vui lòng thử lại!');
    }
  }

  Future<void> _handleSaveProfile() async {
    final full_name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();

    // Kiểm tra nếu không có thay đổi
    if (!_hasChanges) {
      _showInfoSnackBar('Không có thay đổi nào để lưu!');
      return;
    }

    // Kiểm tra trường tên
    if (full_name.isEmpty) {
      _showErrorSnackBar('Vui lòng nhập họ và tên!');
      return;
    } else if (full_name.length < 4) {
      _showErrorSnackBar('Họ và tên phải có ít nhất 4 ký tự!');
      return;
    } else if (full_name.length > 35) {
      _showErrorSnackBar('Họ và tên không được vượt quá 35 ký tự!');
      return;
    }

    // Kiểm tra địa chỉ nếu có nhập vào
    if (address.isNotEmpty && address.length > 70) {
      _showErrorSnackBar('Địa chỉ không được vượt quá 70 ký tự!');
      return;
    }

    // Kiểm tra số điện thoại nếu có nhập vào
    final isPhoneInvalid =
        phone.isNotEmpty &&
        (phone.length != 10 || !RegExp(r'^\d{10}$').hasMatch(phone));

    if (isPhoneInvalid) {
      _showErrorSnackBar('Số điện thoại phải gồm đúng 10 chữ số!');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Cập nhật dữ liệu từ controllers vào model
      final updatedProfile = _profile.copyWith(
        name: _nameController.text,
        email: _emailController.text,
        address: _addressController.text,
        phone: phone,
      );

      String? newAvatarUrl;

      if (_avatarImage != null) {
        try {
          setState(() => _isLoading = true);
          newAvatarUrl = await _profileService.uploadAvatar(_avatarImage!);
        } catch (e) {
          _showErrorSnackBar('Lỗi upload ảnh: $e');
          setState(() => _isLoading = false);
          return;
        }
      }

      // Cập nhật profile với URL mới
      await _profileService.updateProfile(
        updatedProfile,
        newAvatarUrl: newAvatarUrl,
      );

      // Refresh profile từ server
      final refreshed = await _profileService.getProfile(forceRefresh: true);
      if (refreshed != null) {
        setState(() => _profile = refreshed);
      }

      // Gọi callback + pop
      if (widget.onProfileUpdated != null) {
        widget.onProfileUpdated!(
          _nameController.text,
          newAvatarUrl ?? _profile.avatarUrl,
          _addressController.text,
          _phoneController.text,
        );
      }

      // Trả về kết quả cho ProfileScreen
      Navigator.pop(context, {
        'name': _nameController.text,
        'avatarUrl': _avatarImage != null
            ? _avatarImage!.path
            : _profile.avatarUrl,
        'hasNewImage': _avatarImage != null,
        'address': _addressController.text,
        'phone': _phoneController.text,
      });
    } catch (e) {
      // Hiển thị lỗi
      _showErrorSnackBar('Lỗi khi cập nhật: $e');
      print('Lỗi khi lưu profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    showTopSnackBar(
      Overlay.of(context),
      Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.all(8),
          height: 60,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      displayDuration: const Duration(seconds: 1),
    );
  }

  void _showSuccessSnackBar(String message) {
    showTopSnackBar(
      Overlay.of(context),
      Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.all(8),
          height: 60,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      displayDuration: const Duration(seconds: 1),
    );
  }

  void _showInfoSnackBar(String message) {
    showTopSnackBar(
      Overlay.of(context),
      Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.all(8),
          height: 60,
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      displayDuration: const Duration(seconds: 1),
    );
  }

  Widget _buildDefaultAvatar() {
    final avtUrl = _profile.avatarUrl.trim();
    return Stack(
      children: [
        ClipOval(
          child: Image.network(
            avtUrl,
            fit: BoxFit.cover,
            width: 130,
            height: 130,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: const Icon(Icons.person, size: 60, color: Colors.grey),
              );
            },
          ),
        ),
        Positioned(
          bottom: 5,
          right: 5,
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _primaryColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chỉnh sửa thông tin",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).orientation ==
                            Orientation.landscape
                        ? 500
                        : double.infinity,
                  ),
                  child: Column(
                children: [
                  // Avatar widget với thiết kế mới
                  GestureDetector(
                    onTap: _isLoading ? null : _handleChangeAvatar,
                    child: Opacity(
                      opacity: _isLoading ? 0.6 : 1.0,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _hasChanges ? Colors.orange : _primaryColor,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _avatarImage != null
                            ? ClipOval(
                                child: Image.file(
                                  _avatarImage!,
                                  fit: BoxFit.cover,
                                  width: 130,
                                  height: 130,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildDefaultAvatar();
                                  },
                                ),
                              )
                            : _buildDefaultAvatar(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_hasChanges)
                    Text(
                      'Có thay đổi chưa lưu',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const SizedBox(height: 30),

                  // Các trường thông tin
                  ProfileTextFieldWidget(
                    controller: _nameController,
                    labelText: "Họ và tên",
                    icon: Icons.person_outline,
                  ),

                  ProfileTextFieldWidget(
                    controller: _emailController,
                    labelText: "Email",
                    icon: Icons.email_outlined,
                    isReadOnly: true,
                  ),

                  ProfileTextFieldWidget(
                    controller: _addressController,
                    labelText: "Địa chỉ",
                    icon: Icons.location_on_outlined,
                  ),

                  ProfileTextFieldWidget(
                    controller: _phoneController,
                    labelText: "Số điện thoại",
                    icon: Icons.call,
                  ),

                  const SizedBox(height: 40),
                  // Nút xác nhận
                  ConfirmButtonWidget(
                    onPressed: _isLoading ? null : _handleSaveProfile,
                    isActive: _hasChanges && !_isLoading,
                    isLoading: _isLoading,
                  ),
                ],
              ),
                ),
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
