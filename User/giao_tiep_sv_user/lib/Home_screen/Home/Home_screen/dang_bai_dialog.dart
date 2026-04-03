import 'dart:io';
import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Data/global_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../FireBase_Service/create_post.dart';
import '../../../FireBase_Service/upload_service.dart';

class DangBaiDialog extends StatefulWidget {
  final List<Map<String, dynamic>>? availableGroupsData;
  const DangBaiDialog({super.key, this.availableGroupsData});

  @override
  State<DangBaiDialog> createState() => _DangBaiDialogState();
}

class _DangBaiDialogState extends State<DangBaiDialog> {
  final CreatePostService _createPostService = CreatePostService();
  final UploadService _uploadService = UploadService();
  final TextEditingController contentController = TextEditingController();

  final String? userId = GlobalState.currentUserId;

  List<File> selectedImages = [];
  List<File> selectedFiles = [];
  List<String> selectedFileNames = [];

  String? firstImagePath;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> availableGroups = [];
  String? selectedGroupId;

  @override
  void initState() {
    super.initState();

    if (widget.availableGroupsData != null &&
        widget.availableGroupsData!.isNotEmpty) {
      // Lọc nhóm
      availableGroups = widget.availableGroupsData!.where((group) {
        final name = (group['name'] as String?)?.toLowerCase() ?? '';
        final id = (group['id'] as String?)?.toUpperCase() ?? '';
        return id != 'ALL' && name != 'tất cả' && name != 'all';
      }).toList();

      if (availableGroups.isNotEmpty) {
        selectedGroupId = availableGroups.first['id'] as String;
      } else {
        _loadGroupsFallback();
      }
    } else {
      _loadGroupsFallback();
    }
  }

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }

  Future<void> _loadGroupsFallback() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Groups')
          .get();

      final groups = snapshot.docs.map((doc) {
        final data = doc.data();
        return {'id': doc.id, 'name': data['name'] ?? 'Nhóm không tên'};
      }).toList();

      final filteredGroups = groups.where((group) {
        final name = (group['name'] as String?)?.toLowerCase() ?? '';
        final id = (group['id'] as String?)?.toUpperCase() ?? '';
        return id != 'ALL' && name != 'tất cả' && name != 'all';
      }).toList();

      setState(() {
        availableGroups = filteredGroups;
        if (availableGroups.isNotEmpty) {
          selectedGroupId = availableGroups.first['id'] as String;
        } else {
          selectedGroupId = null;
        }
      });
    } catch (e) {
      print("🔥 Lỗi load nhóm: $e");
    }
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        selectedImages.addAll(picked.map((x) => File(x.path)));
        selectedFileNames.clear();
        selectedFiles.clear();
        firstImagePath = selectedImages.first.path;
      });
    }
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedFiles = result.files
            .where((f) => f.path != null)
            .map((f) => File(f.path!))
            .toList();
        selectedFileNames = result.files.map((f) => f.name).toList();
        selectedImages.clear();
        firstImagePath = null;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
      if (selectedImages.isEmpty) firstImagePath = null;
    });
  }

  void _removeFile(int index) {
    setState(() {
      selectedFiles.removeAt(index);
      selectedFileNames.removeAt(index);
    });
  }

  Future<void> _submitPost() async {
    final content = contentController.text.trim();

    if (content.isEmpty && selectedImages.isEmpty && selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập nội dung hoặc chọn tệp!")),
      );
      return;
    }

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lỗi: chưa đăng nhập!")));
      return;
    }

    if (selectedGroupId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Vui lòng chọn nhóm!")));
      return;
    }

    setState(() => _isUploading = true);

    List<String> imageUrls = [];
    String? fileUrl;

    try {
      if (selectedImages.isNotEmpty) {
        final futures = selectedImages.map(
          (img) => _uploadService.uploadFile(img, userId!),
        );
        final results = await Future.wait(futures);
        imageUrls = results.whereType<String>().toList();
      }

      if (selectedFiles.isNotEmpty) {
        final url = await _uploadService.uploadFile(
          selectedFiles.first,
          userId!,
        );
        if (url != null) fileUrl = url;
      }

      final success = await _createPostService.uploadPost(
        currentUserId: userId!,
        content: content,
        groupId: selectedGroupId!,
        imageUrls: imageUrls,
        fileUrl: fileUrl,
      );

      if (!success) throw Exception("Đăng bài thất bại");

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🎉 Đăng bài thành công (chờ duyệt)!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("❌ Lỗi đăng bài: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1E88E5);
    final hasAttachments =
        selectedImages.isNotEmpty || selectedFileNames.isNotEmpty;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Container(
          width: 520,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Đăng Bài Viết Mới',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: contentController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: "Bạn đang nghĩ gì? Chia sẻ ngay...",
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Đính kèm:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.image, color: primaryColor),
                    onPressed: _pickImages,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      hasAttachments
                          ? 'Đã chọn ${selectedImages.length + selectedFileNames.length} tệp'
                          : 'Chưa có tệp nào',
                      style: TextStyle(
                        color: hasAttachments ? Colors.black87 : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),

              if (selectedImages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: selectedImages.length,
                    itemBuilder: (ctx, i) => Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            selectedImages[i],
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: InkWell(
                            onTap: () => _removeImage(i),
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.black54,
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (selectedFileNames.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Wrap(
                    spacing: 8,
                    children: selectedFileNames.asMap().entries.map((e) {
                      return Chip(
                        label: Text(e.value, overflow: TextOverflow.ellipsis),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => _removeFile(e.key),
                      );
                    }).toList(),
                  ),
                ),

              const SizedBox(height: 20),

              const Text(
                'Chọn nhóm:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  return DropdownButtonFormField<String>(
                    value: selectedGroupId,
                    isExpanded: true, // bắt dropdown full width
                    items: availableGroups.map((g) {
                      return DropdownMenuItem<String>(
                        value: g['id'] as String,
                        child: SizedBox(
                          width:
                              constraints.maxWidth, // dùng đúng chiều rộng cha
                          child: Text(
                            g['name'] as String,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedGroupId = value);
                    },
                  );
                },
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isUploading ? null : _submitPost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                    child: _isUploading
                        ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text("Đang đăng..."),
                            ],
                          )
                        : const Text(
                            "Đăng Bài",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
