import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_user/Profile/saveItemsProfile/models/saved_item_model.dart';
import 'package:giao_tiep_sv_user/Profile/saveItemsProfile/widgets/saved_item_card_widget.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/SavedPostsService.dart';

class SavedItemsProfileScreen extends StatefulWidget {
  const SavedItemsProfileScreen({super.key});

  @override
  State<SavedItemsProfileScreen> createState() =>
      _SavedItemsProfileScreenState();
}

class _SavedItemsProfileScreenState extends State<SavedItemsProfileScreen> {
  final SavedPostsService _savedService = SavedPostsService();
  bool _sortDescending = true; // true = Mới nhất trước

  @override
  Widget build(BuildContext context) {
    final String studentId = _getCurrentStudentId();

    if (studentId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mục đã lưu')),
        body: const Center(child: Text('Vui lòng đăng nhập')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mục đã lưu", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nút sắp xếp
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _sortDescending = !_sortDescending;
                    });
                  },
                  icon: Icon(
                    _sortDescending ? Icons.trending_up : Icons.trending_down,
                    size: 22,
                  ),
                  label: Text(
                    _sortDescending ? "Mới nhất" : "Cũ nhất",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _sortDescending
                        ? Colors.deepPurple
                        : Colors.amber[800],
                    side: BorderSide(
                      width: 1.8,
                      color: _sortDescending
                          ? Colors.deepPurple
                          : Colors.amber[800]!,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // StreamBuilder lấy dữ liệu đã lưu
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _savedService.streamSavedPosts(
                  studentId,
                  sortDescending: _sortDescending, // Truyền tham số sắp xếp
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text("Lỗi tải dữ liệu"));
                  }

                  final List<Map<String, dynamic>> posts = snapshot.data ?? [];
                  final List<SavedItemModel> savedItems = posts.map((post) {
                    return SavedItemModel.fromMap(post);
                  }).toList();

                  if (savedItems.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bookmark_border,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Chưa có mục nào được lưu',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          '${savedItems.length} mục đã lưu',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: savedItems.length,
                          itemBuilder: (context, index) {
                            final item = savedItems[index];
                            return SavedItemCardWidget(
                              item: item,
                              index: index,
                              onDelete: (postId) {
                                _savedService.unsavePost(studentId, postId);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrentStudentId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email == null) return '';
    return user!.email!
        .split('@')
        .first
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]'), '');
  }
}
