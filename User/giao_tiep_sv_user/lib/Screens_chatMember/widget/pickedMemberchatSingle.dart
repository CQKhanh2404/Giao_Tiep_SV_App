import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Data/Users.dart';
import 'package:giao_tiep_sv_user/Data/faculty.dart';
import 'package:giao_tiep_sv_user/Data/room_chat.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/UserServices.dart';
import 'package:giao_tiep_sv_user/Screen_member_group/widget/customSearch.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/FirebaseStore/MessageService.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/widget/customMemberUyquyen.dart';
import 'package:uuid/uuid.dart';


class PickedmemberchatSingle extends StatefulWidget {
  final String myID;
  final ValueChanged<String?>? GetList;

  const PickedmemberchatSingle({super.key, this.GetList,  required this.myID});

  @override
  State<PickedmemberchatSingle> createState() => _PickedmemberchatSingle();
}

class _PickedmemberchatSingle extends State<PickedmemberchatSingle> {
  final mesService = MessageService();

  List<Users> listUyQuyen = [];
  bool isLoading = false;
  String? idUsSelected;
  final firestoreService = Userservices();
  String selectedKhoa = "all";
  List<Users> listUyQuyen_out = [];
  List<Users> Listsearch = [];
  Map<String, bool> selectedMember = {};

  List<Faculty> dsKhoa = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //load nguoi dung
    featchMembers();
    // Listsearch = listUyQuyen;

    //load cac khoa trong dialog
    featchFaculty();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff5f5f5),
      appBar: AppBar(
        backgroundColor: Color(0xfff5f5f5),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          iconSize: 25,
        ),
        title: Text(
          "Chọn người trò chuyện",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: Container(
        child: Column(
          children: [
            Customsearch(
              onTap: (value) {
                setState(() {
                  Listsearch = listUyQuyen.where((element) {
                    return element.fullname.toLowerCase().contains(
                      value.toLowerCase(),
                    ) && !element.id_user.toLowerCase().contains(
                      widget.myID.toLowerCase(),
                    );
                  }).toList();
                });
              },
            ),
            SizedBox(height: 8),
            search(),
            SizedBox(height: 8),
            Text(
              "Danh Sách người dùng",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Expanded(child: createListmember()),
          ],
        ),
      ),
    );
  }

  Widget search() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        createChoseKhoa(),
        InkWell(
          onTap: () {
            widget.GetList?.call(idUsSelected);
            String idRoom = Uuid().v4();
            ChatRoom chatRoom = ChatRoom(roomId: idRoom, lastMessage: "", lastSender: "", lastTime: DateTime.now(), users: [widget.myID.toUpperCase(),idUsSelected!], name: "", avatarUrl: "", typeId: 0, createdBy: widget.myID, createdAt: DateTime.now());
            mesService.createChatRooms(chatRoom);
            Navigator.pop(context);

          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Color(0xff55B9F6),
              border: Border.all(color: Colors.grey, width: 0.6),
            ),
            child: Row(
              children: [
                Text(
                  "Xong",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  //menu chon khoa tim tho+eo khoa
  Widget createChoseKhoa() {
    return PopupMenuButton<String>(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Row(
          children: [
            Text(
              "Khoa: ${selectedKhoa.toString()}",
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            Icon(Icons.arrow_drop_down_outlined, size: 30, color: Colors.black),
          ],
        ),
      ),
      onSelected: (value) {
        if (value == "all") {
          setState(() {
            selectedKhoa = value;
            Listsearch = listUyQuyen;
          });
        } else {
          setState(() {
            selectedKhoa = value;
            Listsearch = listUyQuyen.where((element) {
              return element.faculty_id.toLowerCase().contains(
                value.toLowerCase(),
              ) && !element.id_user.toLowerCase().trim().contains(widget.myID.toLowerCase());
            }).toList();
          });
        }
        print(value);
      },
      itemBuilder: (context) {
        return dsKhoa.map((e) {
          return PopupMenuItem(value: e.faculty_id, child: Text(e.name_faculty));
        }).toList();
      },
    );
  }

  //hiển thị toàn bộ người dùng
  Widget createListmember() {
    Listsearch =  Listsearch.where((element) {
      return !element.id_user.toLowerCase().trim().contains(widget.myID.toLowerCase().trim());
    },).toList();
    return (isLoading == false)
        ? ListView.builder(
            shrinkWrap: true,
            //physics: NeverScrollableScrollPhysics(),
            itemCount: Listsearch.length,
            itemBuilder: (context, index) {
              var valueItem = Listsearch[index];
              bool selectMember = selectedMember[valueItem.id_user] ?? false;
              return customMember(valueItem.id_user,valueItem.fullname,valueItem.url_avt);
            },
          )
        : Center(child: CircularProgressIndicator());
  }

  //lấy danh sách khoa vào
  Future<void> featchFaculty() async {
    final snap = await FirebaseFirestore.instance.collection("Faculty").get();
    final data = snap.docs.map((e) {
      final map = e.data();
      return Faculty(
        faculty_id: map['id'].toString() ?? "",
        name_faculty: map['name'] ?? "",
      );
    }).toList();

    setState(() {
      dsKhoa.add(Faculty(faculty_id: "all", name_faculty: "Tất cả"));
      dsKhoa.addAll(data);
    });
  }

  //lay dach sach nguoi dung vao list uy quyen khac me
  Future<void> featchMembers() async {
    isLoading = true;
    try {
      firestoreService.streamBuilder().listen((data) {
        setState(() {
          listUyQuyen = data;
          Listsearch = listUyQuyen.where((element) {
            return !element.id_user.toLowerCase().trim().contains(
              widget.myID
            );
          },).toList();
          isLoading = false;
        });
      },);

      
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      debugPrint(" Lỗi khi load Faculty: $e");
    }
  }

  Widget customMember(String idUser,String fullName, String url_avt){
    return InkWell(
      onTap: () {
      setState(() {
        checkClicked(idUser, idUsSelected??"");
        idUsSelected = idUser;
      });
      },
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                //create img avatar
                ClipOval(
                  child: Image.network(
                    url_avt,
                    fit: BoxFit.fill,
                    height: 40,
                    width: 40,
                  ),
                ),
                SizedBox(width: 15),
                //name
                Text(
                  fullName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            Checkbox(
              value: checkClicked(idUser, idUsSelected??""),
              activeColor: Colors.blue,
              onChanged: (value) {
                setState(() {
                  value = !value!;
                  idUsSelected = idUser;
                });
              },
            ),
            
          ],
        ),
      ),
    );
  }

  bool checkClicked(String id, String idB){
    return (id.toLowerCase().trim() == idB.toLowerCase().trim());
  }
}
