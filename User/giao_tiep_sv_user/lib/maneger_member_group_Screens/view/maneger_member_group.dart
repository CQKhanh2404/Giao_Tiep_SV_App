import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Data/Users.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/UserServices.dart';
import 'package:giao_tiep_sv_user/Screen_member_group/view/Add_member.dart';
import 'package:giao_tiep_sv_user/Screen_member_group/widget/customSearch.dart';
import 'package:giao_tiep_sv_user/Widget/MyButton.dart';
import 'package:giao_tiep_sv_user/maneger_member_group_Screens/serviceGroup/groupService.dart';
import 'package:giao_tiep_sv_user/maneger_member_group_Screens/widget/custom_member_group.dart';

class ManegerMemberGroupScreen extends StatefulWidget {
  final String idGroup;
  const ManegerMemberGroupScreen({super.key, required this.idGroup});

  @override
  State<ManegerMemberGroupScreen> createState() =>
      _ManegerMemberGroupScreenState();
}

class _ManegerMemberGroupScreenState extends State<ManegerMemberGroupScreen> {
  final manegerDB = GroupserviceManeger();
  final userDB = Userservices();

  List<Users?> Listsearch = [];
  List<Users?> ListMember = [];

  bool isload = false;
  bool selecAll = true;

  String get currentUserId =>
      FirebaseAuth.instance.currentUser!.email!.split('@').first.toUpperCase();

  bool isGroupOwner = false; // ← Quan trọng: Dựa vào role = 1

  @override
  void initState() {
    super.initState();
    print("ManegerMemberGroupScreen - Current User ID: $currentUserId");
    print("ManegerMemberGroupScreen - Group ID: ${widget.idGroup}");
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isload = true);

    // Load danh sách thành viên
    await getMemberGroup(widget.idGroup);

    // Kiểm tra xem user hiện tại có phải chủ nhóm không (role = 1)
    isGroupOwner = await _checkIfGroupOwner(widget.idGroup);

    if (mounted) {
      setState(() {
        Listsearch = List.from(ListMember);
        isload = false;
      });
    }

    print("Tải xong dữ liệu. Là chủ nhóm? $isGroupOwner");
  }

  // Hàm kiểm tra chính xác: user có role = 1 trong nhóm không?
  Future<bool> _checkIfGroupOwner(String groupId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("Groups_members")
          .where("group_id", isEqualTo: groupId)
          .where("user_id", isEqualTo: currentUserId)
          .where("role", isEqualTo: 1)
          .limit(1)
          .get();

      final bool result = snapshot.docs.isNotEmpty;
      print("Kiểm tra quyền chủ nhóm → role=1: $result");
      return result;
    } catch (e) {
      print("Lỗi kiểm tra chủ nhóm: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Thành viên",
          style: TextStyle(
            color: Color(0xffA72E2E),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Image.asset(
              "assets/icons/ic_back.png",
              height: 15,
              width: 15,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddMemberScreen(groupID: widget.idGroup),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 8),
                  Text(
                    "Thêm",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Mybutton(
                  url_icon: "assets/icons/ic_tabAll.png",
                  nameButton: "Tất cả",
                  ontap: () => setState(() {
                    selecAll = true;
                    Listsearch = List.from(ListMember);
                  }),
                  Mycolor: const Color(0xffECF3E5),
                ),
                Mybutton(
                  url_icon: "assets/icons/ic_group.png",
                  nameButton: "Quản trị",
                  ontap: () async {
                    setState(() {
                      selecAll = false;
                    });

                    // Lấy danh sách thành viên + role từ Firestore
                    final adminIds = await manegerDB.getAdminsInGroup(
                      widget.idGroup,
                    );

                    setState(() {
                      Listsearch = ListMember.where((user) {
                        return user != null && adminIds.contains(user.id_user);
                      }).toList();
                    });
                  },
                  Mycolor: const Color(0xffFFE5E5),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Customsearch(onTap: _performSearch),
            const SizedBox(height: 10),
            Expanded(child: createListMember()),
          ],
        ),
      ),
    );
  }

  void _performSearch(String value) {
    if (value.isEmpty) {
      Listsearch = List.from(ListMember);
    } else {
      final lower = value.toLowerCase();
      setState(() {
        Listsearch = ListMember.where(
          (e) =>
              e != null &&
              (e.fullname.toLowerCase().contains(lower) ||
                  e.email.toLowerCase().contains(lower)),
        ).toList();
      });
    }
  }

  Widget createListMember() {
    if (isload)
      return const Center(
        child: CircularProgressIndicator(color: Colors.blueAccent),
      );
    if (Listsearch.isEmpty)
      return const Center(child: Text("Không có thành viên nào"));

    print("Render danh sách thành viên. Là chủ nhóm? $isGroupOwner");

    return ListView.builder(
      itemCount: Listsearch.length,
      itemBuilder: (context, index) {
        final user = Listsearch[index];
        if (user == null) return const SizedBox.shrink();

        return CustomMemberGroupManeger(
          url: user.url_avt,
          fullname: user.fullname,
          userId: user.id_user,
          groupId: widget.idGroup,
          isGroupOwner: isGroupOwner,
          currentUserId: currentUserId,
          onMemberRemoved: _loadData,
        );
      },
    );
  }

  Future<void> getMemberGroup(String idRoom) async {
    ListMember.clear();
    try {
      final listUserIDs = await manegerDB.listChat(idRoom);

      for (final userId in listUserIDs) {
        if (userId == null) continue;
        final user = await userDB.getUserForID(userId);
        if (user != null) ListMember.add(user);
      }
    } catch (e) {
      print("Lỗi load thành viên: $e");
    }
  }
}
