import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Data/Users.dart';
import 'package:giao_tiep_sv_user/Data/global_state.dart';
import 'package:giao_tiep_sv_user/Data/room_chat.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/UserServices.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/get_joined_groups.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/search_service.dart';
import 'package:giao_tiep_sv_user/Home_screen/Home/Home_screen/port_card.dart';
import 'package:giao_tiep_sv_user/Home_screen/Home/Home_screen/wiget/user_card.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/FirebaseStore/MessageService.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/data/dataRoomChat.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/view/chatMessage.dart';
import 'package:uuid/uuid.dart';
import '../Home_screen/wiget/comment_sheet_content.dart';
import '../../../FireBase_Service/post_interaction_service.dart';

class SearchPage extends StatefulWidget {
  final String myID;
  const SearchPage({super.key, required this.myID});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final SearchService _searchService = SearchService();
  final userservices = Userservices();
  final GetJoinedGroupsService _groupsService = GetJoinedGroupsService();
  final mesService = MessageService();
  Users? memberChat;

  final PostInteractionService _postInteractionService = PostInteractionService(
    userId: GlobalState.currentUserId.isNotEmpty
        ? GlobalState.currentUserId
        : "23211TT4679",
    userFullname: GlobalState.currentFullname.isNotEmpty
        ? GlobalState.currentFullname
        : "Người dùng ẩn danh",
  );

  String selectedCategory = 'Người dùng';
  final List<String> categories = ['Người dùng', 'Bài viết'];
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  final String _currentUserId = GlobalState.currentUserId;

  List<String> _currentUserGroupIds = [];
  Map<String, String> _groupIdToName = {};
  bool _isGroupsLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGroups();
    _searchController.addListener(_onSearchChanged);
    
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> GetmememberChat(String id) async{
    memberChat = await userservices.getUserForID(id.toUpperCase());
    print("name: ${memberChat!.fullname}");
  }

  Future<void> _fetchGroups() async {
    if (_currentUserId.isEmpty) {
      setState(() {
        _isGroupsLoading = false;
      });
      return;
    }

    setState(() => _isGroupsLoading = true);

    final groups = await _groupsService.fetchJoinedGroups(_currentUserId);

    final groupIds = groups
        .map((g) => g["id"] as String)
        .where((id) => id != "ALL")
        .toList();

    setState(() {
      _currentUserGroupIds = groupIds;

      _groupIdToName = {
        for (var g in groups)
          if (g["id"] != "ALL") g["id"]: g["name"] as String,
      };

      _isGroupsLoading = false;
    });

    if (_searchController.text.length > 1 && selectedCategory == 'Bài viết') {
      _performSearch(_searchController.text.trim());
    }
  }

  void _onSearchChanged() {
    if (!_isGroupsLoading && _searchController.text.length > 1) {
      _performSearch(_searchController.text.trim());
    } else if (_searchController.text.isEmpty) {
      setState(() => _searchResults = []);
    }
  }

  Future<List<Map<String, dynamic>>> _enrichPostsWithInteractions(
    List<Map<String, dynamic>> posts,
  ) async {
    final String currentUserId = _currentUserId;

    final futures = posts.map((post) async {
      final postId = post["id"] as String?;
      if (postId == null) return post;

      final counts = await _postInteractionService.getPostInteractionCounts(
        postId,
      );

      final isLiked = await _postInteractionService.isPostLikedByUser(
        postId,
        currentUserId,
      );

      return {
        ...post,
        "likes": counts["likes"] ?? 0,
        "comments": counts["comments"] ?? 0,
        "isLiked": isLiked,
      };
    }).toList();

    return await Future.wait(futures);
  }

  Future<void> _performSearch(String query) async {
    if (_isLoading || _isGroupsLoading) return;

    setState(() {
      _isLoading = true;
      _searchResults = [];
    });

    List<Map<String, dynamic>> results;

    if (selectedCategory == 'Người dùng') {
      results = await _searchService.searchUsers(query);
    } else {
      results = await _searchService.searchPosts(query, _currentUserGroupIds);

      results = results.map((post) {
        return {
          ...post,
          "group_name": _groupIdToName[post["group"]] ?? "Không rõ",
        };
      }).toList();

      results = await _enrichPostsWithInteractions(results);
    }

    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  // HÀM MỚI: Xử lý sự kiện Like/Unlike
  void _toggleLike(Map<String, dynamic> post) async {
    final int postIndex = _searchResults.indexOf(post);
    if (postIndex == -1) return;

    final bool currentlyLiked = post["isLiked"] ?? false;
    final String postId = post["id"] as String;

    setState(() {
      post["isLiked"] = !currentlyLiked;
      post["likes"] = (post["likes"] ?? 0) + (currentlyLiked ? -1 : 1);
      if (post["likes"]! < 0) post["likes"] = 0;
    });

    try {
      final success = await _postInteractionService.toggleLike(
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

  void _showCommentSheet(Map<String, dynamic> post) {
    final int postIndex = _searchResults.indexOf(post);
    if (postIndex == -1) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CommentSheetContent(
          postId: post["id"] as String,
          post: post,
          interactionService: _postInteractionService,
          getGroupNameFromId: (groupId) =>
              _groupIdToName[groupId] ?? "Không rõ",
          onCommentsCountUpdate: (count) {
            if (mounted) {
              setState(() {
                _searchResults[postIndex]["comments"] = count;
              });
            }
          },
        );
      },
    );
  }

  Widget _buildResultList() {
    if (_isGroupsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (selectedCategory == 'Bài viết' && _currentUserGroupIds.isEmpty) {
      return Center(
        child: Text('Bạn chưa tham gia nhóm nào. Không thể tìm kiếm bài viết.'),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.isEmpty
              ? 'Nhập từ khóa để tìm kiếm...'
              : 'Không tìm thấy kết quả cho "${_searchController.text}"',
        ),
      );
    }

    _searchResults = _searchResults.where(
      (element) {
        var id= element["id"] as String;
        return !id.trim().toLowerCase().contains(widget.myID.toLowerCase().trim());
      },
    ).toList();
    // _searchResults.forEach(
    //   (element) {
    //     print("gtri map: ${element["id"]}");
    //   },
    // );
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];

        if (selectedCategory == 'Người dùng') {
          return UserCard(
            user: item,
            onTap: () {},
            onMessagePressed: (user)async {
              String idMember = user["id"];
              await GetmememberChat(idMember);
              // print("member chat ${memberChat}");
              // print('Nhắn tin với: ${user["fullname"]} (ID: ${user["id"]})');
              
              String idRoom = Uuid().v4();  
            ChatRoom chatRoom = ChatRoom(roomId: idRoom, lastMessage: "", lastSender: "", lastTime: DateTime.now(), users: [widget.myID.toUpperCase(),idMember!], name: "", avatarUrl: "", typeId: 0, createdBy: widget.myID, createdAt: DateTime.now());
            mesService.createChatRooms(chatRoom);
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return ScreenMessage(
                          myId: widget.myID,
                          sender_to: ChatRoom(
                            roomId: "",
                            lastMessage: "",
                            lastSender: "",
                            lastTime: DateTime.now(),
                            users: [],
                            name: "",
                            createdAt: DateTime.now(),
                            avatarUrl: "",
                            createdBy: widget.myID,
                            typeId: 0,
                          ),
                          idRoom: idRoom,
                          avtChat: "",
                          nameChat: "",
                          dataroomchat: Dataroomchat(id: widget.myID, name: memberChat!.fullname, avt: memberChat!.url_avt),
                        );
            },));
            // Navigator.pop(context);
            },
          );
        } else {
          return PostCard(
            post: item,
            onCommentPressed: () => _showCommentSheet(item),
            onLikePressed: () => _toggleLike(item),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Tìm kiếm', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm...',
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                    onSubmitted: (value) => _performSearch(value.trim()),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedCategory,
                  items: categories
                      .map(
                        (String value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategory = newValue!;
                      if (_searchController.text.length > 1) {
                        _performSearch(_searchController.text.trim());
                      } else {
                        _searchResults = [];
                      }
                    });
                  },
                  underline: Container(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildResultList()),
          ],
        ),
      ),
    );
  }
}
