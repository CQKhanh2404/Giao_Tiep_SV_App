import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/UserPostRepository.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/ProfileService.dart';
import 'package:giao_tiep_sv_user/Profile/editProflie/models/profile_model.dart';
import 'package:giao_tiep_sv_user/Profile/personalPost/models/personal_post_model.dart';
import 'package:giao_tiep_sv_user/Profile/personalPost/widgets/personal_post_item.dart';
import 'package:giao_tiep_sv_user/Profile/personalPost/widgets/profile_header_widget.dart';

class PersonalPostScreen extends StatefulWidget {
  final String currentUserId;
  final String userName;
  final String avatarUrl;
  final File? avatarFile;

  const PersonalPostScreen({
    super.key,
    required this.currentUserId,
    this.userName = "",
    this.avatarUrl = "",
    this.avatarFile,
  });

  @override
  State<PersonalPostScreen> createState() => _PersonalPostScreenState();
}

class _PersonalPostScreenState extends State<PersonalPostScreen> {
  late final PostRepository _postRepository;
  late final ProfileService _profileService;
  List<PersonalPostModel> _posts = [];
  ProfileModel? _profile;
  bool _isLoadingProfile = true;
  String _major = 'Đang tải...';
  String _schoolYear = 'Đang tải...';
  bool _isLoadingExtra = true;
  @override
  void initState() {
    super.initState();
    _postRepository = PostRepository();
    _profileService = ProfileService();

    // Thiết lập userId
    _profileService.setUserId(widget.currentUserId);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileService.getProfile();
      if (!mounted) return;

      final result = await _profileService.layNganhVaNienKhoa(
        profile?.email ?? '',
        profile?.faculty.faculty_id ?? '',
      );

      setState(() {
        _profile = profile;
        _major = result['major'] ?? 'Không xác định';
        _schoolYear = result['schoolYear'] ?? '20XX';
        _isLoadingProfile = false;
        _isLoadingExtra = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _major = 'Lỗi';
          _schoolYear = 'Lỗi';
          _isLoadingProfile = false;
          _isLoadingExtra = false;
        });
      }
    }
  }

  // xóa bài viết
  void _handleDelete(String postId, List<String> imageUrls) async {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.blueGrey[800],
        content: Row(
          children: const [
            CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            SizedBox(width: 16),
            Text('Đang xóa dữ liệu...', style: TextStyle(color: Colors.white)),
          ],
        ),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );

    try {
      await _deletePostImages(imageUrls);
      await FirebaseFirestore.instance.collection('Post').doc(postId).delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa bài viết thành công'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }
  //xóa ảnh đã lưu trong stoage

  Future<void> _deletePostImages(List<String> imageUrls) async {
    for (String url in imageUrls) {
      if (url.isEmpty) continue;
      try {
        final ref = FirebaseStorage.instance.refFromURL(url);
        await ref.delete();
      } on FirebaseException catch (e) {
        if (e.code == 'object-not-found') {
          print('Ảnh đã bị xóa trước: $url');
        } else {
          print('Lỗi xóa ảnh: $e');
        }
      } catch (e) {
        print('Lỗi không xác định: $e');
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Bài viết"),
      ),
      body: StreamBuilder<List<PersonalPostModel>>(
        stream: _postRepository.personalPostsStream(widget.currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              _isLoadingProfile) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }

          final posts = snapshot.data ?? [];

          final displayName = _profile?.name?.isNotEmpty == true
              ? _profile!.name
              : widget.userName;
          final displayAvatarUrl = _profile?.avatarUrl?.isNotEmpty == true
              ? _profile!.avatarUrl
              : widget.avatarUrl;

          return CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _profile != null
                      ? ProfileHeaderWidget(
                          avatarUrl: displayAvatarUrl,
                          avatarFile: widget.avatarFile,
                          name: displayName,
                          major: _isLoadingExtra ? 'Đang tải...' : _major,
                          schoolYear: _isLoadingExtra
                              ? 'Đang tải...'
                              : _schoolYear,
                          postCount: posts.length,
                        )
                      : const Text("Không tải được thông tin"),
                ),
              ),

              // Tiêu đề "Bài viết"
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Bài viết",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Danh sách bài viết
              posts.isEmpty
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          "Chưa có bài viết nào",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final post = posts[index];
                        return PersonalPostItemWidget(
                          post: post,
                          onDelete: (id, urls) => _handleDelete(id, urls),
                          avatarUrl: displayAvatarUrl,
                          avatarFile: widget.avatarFile,
                          currentUserName: displayName,
                          groupId: '',
                        );
                      }, childCount: posts.length),
                    ),
            ],
          );
        },
      ),
    );
  }
}
