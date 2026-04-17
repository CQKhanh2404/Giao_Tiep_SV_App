import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/SavedPostsService.dart';
import 'package:giao_tiep_sv_user/Home_screen/Home/Home_screen/wiget/comment_sheet_content.dart';
import 'package:giao_tiep_sv_user/Home_screen/Home/Home_screen/wiget/report_dialog.dart';
import '../../../FireBase_Service/get_posts.dart';
import 'port_card.dart';
import 'dang_bai_dialog.dart';
import 'left_panel.dart';
import 'group_info_dialog.dart';
import 'search_page.dart';
import '../../../FireBase_Service/get_joined_groups.dart';
import '../../../Data/global_state.dart';
import '../../../FireBase_Service/post_interaction_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Màn hình Trang Chủ: hiển thị bảng tin bài viết theo nhóm đã tham gia
class TrangChu extends StatefulWidget {
  const TrangChu({super.key});

  @override
  State<TrangChu> createState() => TrangChuState();
}

class TrangChuState extends State<TrangChu> {
  // Khởi tạo User ID và Fullname
  final String _currentUserId = GlobalState.currentUserId.isNotEmpty
      ? GlobalState.currentUserId
      : "23211TT4679";
  final String _currentFullname = GlobalState.currentFullname.isNotEmpty
      ? GlobalState.currentFullname
      : "Người dùng ẩn danh";

  final GetPosts _postService;
  final GetJoinedGroupsService _groupService = GetJoinedGroupsService();
  final PostInteractionService _interactionService = PostInteractionService(
    userId: GlobalState.currentUserId.isNotEmpty
        ? GlobalState.currentUserId
        : "23211TT4679",
    userFullname: GlobalState.currentFullname.isNotEmpty
        ? GlobalState.currentFullname
        : "Người dùng ẩn danh",
  );
  final SavedPostsService _savedPostsService = SavedPostsService();

  bool _isOpen = false;
  String currentGroupId = "";
  String currentGroupName = "Loading...";
  int _currentUserRole = 1;
  String _groupOwnerId = ""; // ID người tạo nhóm hiện tại

  List<Map<String, dynamic>> allPosts = [];
  List<Map<String, dynamic>> filteredPosts = [];
  List<Map<String, dynamic>> _joinedGroupsData = [];

  TrangChuState()
    : _postService = GetPosts(
        currentUserId: GlobalState.currentUserId.isNotEmpty
            ? GlobalState.currentUserId
            : "23211TT4679",
      );

  // ---------------- FETCH DATA ----------------

  // Lấy danh sách bài viết từ Firestore và lọc theo nhóm hiện tại
  Future<void> _fetchPosts() async {
    final fetchedPosts = await _postService.fetchPosts();
    if (mounted) {
      setState(() {
        allPosts = fetchedPosts;
        _filterPosts();
      });
    }
  }

  // Lấy vai trò của người dùng hiện tại trong nhóm (0 = thành viên, 1 = trưởng nhóm)
  Future<void> _fetchCurrentUserRole(String groupId) async {
    if (groupId.isEmpty || groupId == "NO_GROUP_SELECTED" || groupId == "ALL") {
      if (mounted) setState(() => _currentUserRole = 1);
      return;
    }
    try {
      final memberDoc = await FirebaseFirestore.instance
          .collection('Groups_members')
          .where('user_id', isEqualTo: _currentUserId)
          .where('group_id', isEqualTo: groupId)
          .where('status_id', isEqualTo: 1)
          .get();

      int role = 1;
      if (memberDoc.docs.isNotEmpty) {
        role = memberDoc.docs.first.data()['role'] as int? ?? 1;
      }

      if (mounted) {
        setState(() {
          _currentUserRole = role;
        });
      }
    } catch (e) {
      print("Lỗi tra cứu vai trò: $e");
      if (mounted) setState(() => _currentUserRole = 1);
    }
  }

  // Lấy ID người tạo nhóm hiện tại
  Future<void> _fetchGroupOwnerId(String groupId) async {
    if (groupId.isEmpty || groupId == "NO_GROUP_SELECTED" || groupId == "ALL") {
      if (mounted) setState(() => _groupOwnerId = "");
      return;
    }
    try {
      final groupDoc = await FirebaseFirestore.instance
          .collection('Groups')
          .doc(groupId)
          .get();

      String ownerId = "";
      if (groupDoc.exists && groupDoc.data() != null) {
        final createdByData = groupDoc.data()!['created_by'];

        if (createdByData is String) {
          ownerId = createdByData;
        } else if (createdByData is Map) {
          final Map<String, dynamic> createdByMap = createdByData
              .cast<String, dynamic>();
          if (createdByMap.isNotEmpty) {
            ownerId = createdByMap.keys.first;
          }
        }
      }

      if (mounted) {
        setState(() {
          _groupOwnerId = ownerId;
        });
      }
    } catch (e) {
      print("Lỗi tra cứu ID người tạo: $e");
      if (mounted) {
        setState(() {
          _groupOwnerId = "";
        });
      }
    }
  }

  // Tải danh sách các nhóm đã tham gia và chọn nhóm mặc định
  Future<void> _fetchJoinedGroupNames() async {
    final userId = GlobalState.currentUserId.isNotEmpty
        ? GlobalState.currentUserId
        : "23211TT4679";

    final groups = await _groupService.fetchJoinedGroups(userId);

    if (mounted) {
      setState(() {
        _joinedGroupsData = groups;

        if (currentGroupId.isEmpty && groups.length > 1) {
          final defaultGroup = groups[1];
          currentGroupId = defaultGroup["id"] as String;
          currentGroupName = defaultGroup["name"] as String;
        } else if (currentGroupId.isEmpty && groups.length == 1) {
          currentGroupId = "NO_GROUP_SELECTED";
          currentGroupName = "Hãy tham gia nhóm!";
        } else if (currentGroupId.isEmpty && groups.isEmpty) {
          currentGroupId = "NO_GROUP_SELECTED";
          currentGroupName = "Hãy tham gia nhóm!";
        }

        _filterPosts();
      });

      _fetchCurrentUserRole(currentGroupId);
      _fetchGroupOwnerId(currentGroupId);
    }
  }

  // Lọc bài viết theo nhóm đang được chọn
  void _filterPosts() {
    if (currentGroupId.isEmpty ||
        currentGroupId == "ALL" ||
        currentGroupId == "NO_GROUP_SELECTED") {
      filteredPosts = [];
      return;
    }

    filteredPosts = allPosts
        .where((post) => post["group_id"] == currentGroupId)
        .map((post) {
          return {
            ...post,
            "group_name":
                _joinedGroupsData.firstWhere(
                  (g) => g['id'] == post['group_id'],
                  orElse: () => {"name": "Không rõ"},
                )['name'] ??
                "Không rõ",
          };
        })
        .toList();
  }

  // Xử lý khi người dùng chuyển sang nhóm khác từ panel trái
  void _changeGroup(String newGroupId, String newGroupName) {
    setState(() {
      currentGroupId = newGroupId;
      currentGroupName = newGroupName;
      _isOpen = false;
      _filterPosts();
    });
    _fetchCurrentUserRole(newGroupId);
    _fetchGroupOwnerId(newGroupId);
  }

  // Xử lý like/unlike bài viết (cập nhật UI ngay lập tức, đồng bộ Firestore sau)
  void _toggleLike(Map<String, dynamic> post) async {
    final bool currentlyLiked = post["isLiked"] ?? false;
    final String postId = post["id"] as String;

    setState(() {
      post["isLiked"] = !currentlyLiked;
      post["likes"] = (post["likes"] ?? 0) + (currentlyLiked ? -1 : 1);
      if (post["likes"]! < 0) post["likes"] = 0;
    });

    try {
      final success = await _interactionService.toggleLike(
        postId,
        currentlyLiked,
      );
      if (!success) throw Exception("Cập nhật Firestore thất bại.");
    } catch (e) {
      print("Lỗi tương tác Like: $e");
      if (mounted) {
        setState(() {
          post["isLiked"] = currentlyLiked;
          post["likes"] = (post["likes"] ?? 0) + (currentlyLiked ? 1 : -1);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi cập nhật lượt thích!')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchJoinedGroupNames();
    _fetchPosts();
  }

  String _getGroupNameFromId(String groupId) {
    if (groupId == "ALL" || groupId == "NO_GROUP_SELECTED") return "Tất cả";
    final groupData = _joinedGroupsData.firstWhere(
      (group) => group['id'] == groupId,
      orElse: () => {"name": "Không rõ"},
    );
    return groupData['name'] ?? "Không rõ";
  }

  String _getCurrentGroupAvatar() {
    final currentGroupData = _joinedGroupsData.firstWhere(
      (group) => group['id'] == currentGroupId,
      orElse: () => {"avatar_url": null},
    );
    if (currentGroupId == "NO_GROUP_SELECTED" ||
        currentGroupData['avatar_url'] == null) {
      return "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTq0u-w59YWMH2YXama4Hu6dNpdzg8Ra2ZfjQ&s";
    }
    return currentGroupData['avatar_url'] ??
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTq0u-w59YWMH2YXama4Hu6dNpdzg8Ra2ZfjQ&s";
  }

  @override
  Widget build(BuildContext context) {
    final groupAvatarUrl = _getCurrentGroupAvatar();
    final myIdLogin = _currentUserId;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thanh trên
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () => setState(() => _isOpen = !_isOpen),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SearchPage(myID: myIdLogin),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.search, color: Colors.grey),
                                  SizedBox(width: 8),
                                  Text(
                                    "Tìm kiếm",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _openDangBaiDialog,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.5),
                                  offset: const Offset(0, 4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.edit, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "Đăng Bài",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: NetworkImage(groupAvatarUrl),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              currentGroupName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        if (currentGroupId != "NO_GROUP_SELECTED")
                          IconButton(
                            icon: const Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => GroupInfoDialog(
                                  //groupId: currentGroupId,
                                  myId: myIdLogin,
                                  groupName: currentGroupName,
                                  currentGroupId: currentGroupId,
                                  currentUserRole: _currentUserRole,
                                  groupOwnerId: _groupOwnerId,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8,
                    ),
                    child: Text(
                      "Bảng tin",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredPosts.length,
                    itemBuilder: (context, i) {
                      final post = filteredPosts[i];
                      return PostCard(
                        post: post,
                        currentUserId: _currentUserId,
                        onCommentPressed: () => _showCommentSheet(post),
                        onLikePressed: () => _toggleLike(post),
                        onMenuSelected: (value) async {
                          if (value == "save") {
                            final postId = post["id"] as String;
                            await _savedPostsService.savePost(
                              _currentUserId,
                              postId,
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: Colors.green[600],
                                  duration: Duration(seconds: 2),
                                  content: Row(
                                    children: [
                                      Icon(
                                        Icons.bookmark_added,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          "Đã lưu bài viết!",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          }

                          if (value == "report") {
                            _showReportDialog(post);
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          if (_isOpen)
            GestureDetector(
              onTap: () => setState(() => _isOpen = false),
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: 0,
            bottom: 0,
            left: _isOpen ? 0 : -260,
            child: LeftPanel(
              onClose: () => setState(() => _isOpen = false),
              onGroupSelected: _changeGroup,
            ),
          ),
        ],
      ),
    );
  }

  // Mở dialog đăng bài mới, lọc bỏ nhóm "Tất cả" khỏi danh sách chọn
  void _openDangBaiDialog() async {
    // TẠO DANH SÁCH NHÓM ĐÃ LỌC:
    // Loại bỏ mục có ID là 'ALL'
    final List<Map<String, dynamic>> filteredGroupsForPost = _joinedGroupsData
        .where((group) => group['id'] != 'ALL')
        .toList();

    // Loại bỏ mục có tên là "Tất cả"
    final List<Map<String, dynamic>> finalFilteredGroups = filteredGroupsForPost
        .where(
          (group) =>
              (group['name'] as String?)?.toLowerCase() != 'tất cả' &&
              (group['name'] as String?)?.toLowerCase() != 'all',
        )
        .toList();

    final isSuccess = await showDialog<bool>(
      context: context,
      // TRUYỀN DANH SÁCH ĐÃ LỌC SANG DangBaiDialog
      builder: (_) => DangBaiDialog(availableGroupsData: finalFilteredGroups),
    );

    if (isSuccess == true) {
      await _fetchPosts();
    }
  }

  // Mở bottom sheet hiển thị bình luận của bài viết
  void _showCommentSheet(Map<String, dynamic> post) {
    final String postId = post["id"] as String;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return CommentSheetContent(
          postId: postId,
          post: post,
          interactionService: _interactionService,
          getGroupNameFromId: _getGroupNameFromId,
          onCommentsCountUpdate: (count) {
            setState(() {
              post["comments"] = count;
            });
          },
        );
      },
    );
  }

  // --- HÀM MỚI: Mở Dialog Báo cáo ---
  void _showReportDialog(Map<String, dynamic> post) async {
    final String postId = post["id"] as String;
    final String postTitle = post["content"] as String? ?? "Bài viết";

    // >> LẤY ID NGƯỜI ĐĂNG BÀI: Giả định trường user_id chứa ID người đăng
    final String authorId = post["user_id"] as String? ?? '';

    if (authorId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi: Không tìm thấy ID người đăng bài.")),
      );
      return;
    }

    // Mở dialog và đợi kết quả (true nếu gửi thành công)
    final bool? isSubmitted = await showDialog<bool>(
      context: context,
      builder: (context) => ReportDialog(
        postId: postId,
        postTitle: postTitle,
        recipientUserId: authorId, // << TRUYỀN ID NGƯỜI ĐĂNG VÀO ĐÂY
      ),
    );

    if (isSubmitted == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Báo cáo đã được gửi."),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
