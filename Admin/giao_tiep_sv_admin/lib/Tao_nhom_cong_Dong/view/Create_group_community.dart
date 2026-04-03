import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_admin/Data/Group.dart';
import 'package:giao_tiep_sv_admin/Data/GroupMember.dart';
import 'package:giao_tiep_sv_admin/Data/Notifycation.dart';
import 'package:giao_tiep_sv_admin/Data/Users.dart';
import 'package:giao_tiep_sv_admin/Data/faculty.dart';
import 'package:giao_tiep_sv_admin/FirebaseFirestore/GroupsFirebase.dart';
import 'package:giao_tiep_sv_admin/FirebaseFirestore/NotifycationFirebase.dart';
import 'package:giao_tiep_sv_admin/FirebaseFirestore/UserFirebase.dart.dart';
import 'package:giao_tiep_sv_admin/FirebaseFirestore/notify_service.dart';
import 'package:giao_tiep_sv_admin/Tao_nhom_cong_Dong/view/Screen_uyquyen.dart';
import 'package:giao_tiep_sv_admin/Tao_nhom_cong_Dong/widget/custom_all_khoa.dart';
import 'package:giao_tiep_sv_admin/Tao_nhom_cong_Dong/widget/selected.dart';
import 'package:giao_tiep_sv_admin/widget/MyButton.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ScreenCommunityGroup extends StatefulWidget {
  const ScreenCommunityGroup({super.key});

  @override
  State<ScreenCommunityGroup> createState() => _ScreenCommunityGroupState();
}

class _ScreenCommunityGroupState extends State<ScreenCommunityGroup> {
  final userService = FirestoreServiceUser();
  final Groupsfirebase firebaseServicesGroup = Groupsfirebase();
  final notifyService = Notifycationfirebase();
  


  final urlImageGroup =
      "https://i.pinimg.com/736x/28/5f/6a/285f6a1b06bc79a6e1c50c7326ba6ce9.jpg";
  
  File? avt_group = null;
  String? UrlImg;
  TextEditingController nameGroup = TextEditingController();
  TextEditingController descriptionGroup = TextEditingController();
  List<Users> listSelected_uyquyen = [];
  List<Faculty> listSelected_khoa = [];
  List<Users> ListMember = [];
  List<Users> ListAllUser = [];
  List<String> idMemberForFalcuty = [];
  Map<String, String> faculty_id_apply = {};

  bool isUploadImage = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadUser();
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
          "Tạo nhóm cộng đồng",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            createNameGroup(),
            SizedBox(height: 10),
            createDescription(),
            SizedBox(height: 10),
            create_avt(),
            SizedBox(height: 10),
            createButton(),
            SizedBox(height: 15),
            CustomSlected(
              Throws: 1,
              listmember: listSelected_uyquyen,
              listFaculty: listSelected_khoa,
            ),
            SizedBox(height: 30),
            complate_create(),
          ],
        ),
      ),
    );
  }

  //ham lay cac thanh vien ben trong nhom duoc chon
  Future<void> loadUser() async {
    List<Users> listUserTemp = [];
    listUserTemp = await userService.streamBuilder().first;
    print("Listtemp: ${listUserTemp.length}");

    ListAllUser = listUserTemp;
  }

  //them cac thanh vien trong khoa vao nhom
  void addMember() {
    for (var idKhoa in listSelected_khoa) {
      for (var itemUser in ListAllUser) {
        if (itemUser.faculty_id.trim().toLowerCase().contains(
          idKhoa.id.toLowerCase().trim(),
        )) {
          print(
            "${itemUser.faculty_id.trim().toLowerCase()} - ${idKhoa.id.toLowerCase().trim()}",
          );
          idMemberForFalcuty.add(itemUser.id_user);
        }
      }
    }
  }

  //nut xac nhan tao nhom
  Widget complate_create() {
    return InkWell(
      onTap: () async {
        addMember();
        print("ds khoa: ${listSelected_khoa.length}");

        if (nameGroup.text.trim().isEmpty ||
            descriptionGroup.text.trim().isEmpty ||
            avt_group == null ||
            listSelected_khoa.length <= 0 ||
            listSelected_uyquyen.length <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vui lòng đưa đầy đủ thông tin!'),
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          // lấy id ngẫu nhiên
          final groupId = const Uuid().v4();
          final groupName = nameGroup.text;
          final groupDes = descriptionGroup.text;
          final groupMode = false;
          final groupAvt = urlImageGroup;
          final groupType = 0;
          Map<String, String> groupcreatedBy = {};
          for (var item in listSelected_uyquyen) {
            groupcreatedBy[item.id_user] = item.fullname;
          }

          for (var item in listSelected_khoa) {
            faculty_id_apply[item.id] = item.name_faculty;
          }

          Group group = Group(
            id: groupId,
            name: groupName,
            description: groupDes,
            created_by: groupcreatedBy,
            faculty_id: faculty_id_apply,
            avt: UrlImg ?? groupAvt,
            type_group: groupType,
            status_id: 1,
          );
          if (isUploadImage == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                ),
                duration: Duration(seconds: 3),
              ),
            );
          } else {
            //dua cac thanh vien trong khoa auto duoc vao nhom
            for (var itemId in idMemberForFalcuty) {
              // kiểm tra xem itemId có nằm trong groupcreatedBy không
              final isAdmin = groupcreatedBy.keys
                  .map((k) => k.trim())
                  .contains(itemId.trim());

              final newMember = Groupmember(
                group_id: group.id,
                joined_at: DateTime.now(),
                role: isAdmin ? 1 : 0,
                status_id: 1,
                user_id: itemId,
              );

              await firebaseServicesGroup.createGroupAdmin(group, newMember);
            }
            //gui thong bao khi tao nhom den thanh vien 
            listSelected_khoa.forEach((element) {
               final idNotifi = Uuid().v4();
              Notifycation notifyAdd = Notifycation(
                "Bạn đã được tham gia vào nhóm ${nameGroup.text}",
                id: idNotifi,
                type_notify: 0,
                content: descriptionGroup.text,
                user_recipient_ID: {
                  "${element.id}":"${element.name_faculty}"
                },
              );
              notifyService.createNotifycation(notifyAdd);
            },);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã tạo nhóm thành công !'),
                duration: Duration(seconds: 3),
              ),
            );
            Navigator.pop(context);
          }
        }
      },
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
          decoration: BoxDecoration(
            color: Color(0xff55B9F6),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey, width: 0.9),
          ),
          child: (isUploadImage)
              ? Center(child: CircularProgressIndicator(color: Colors.blue))
              : Text(
                  "Tạo nhóm",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
        ),
      ),
    );
  }

  Widget createButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Mybutton(
          url_icon: 'assets/images/admin.png',
          nameButton: "Ủy quyền",
          Mycolor: Colors.white,
          ontap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Screen_uyquyen(
                throwss: 1,
                GetList: (value) {
                  setState(() {
                    listSelected_uyquyen = value;
                  });
                },
              ),
            ),
          ),
        ),
        Mybutton(
          url_icon: 'assets/images/group.png',
          nameButton: "Khoa",
          Mycolor: Colors.white,
          ontap: () {
            showDialog(
              context: context,
              builder: (context) => CustomAllKhoa(
                listKhoa_out: (value) {
                  setState(() {
                    listSelected_khoa = value;
                  });
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget createNameGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Tên Nhóm:", style: TextStyle(fontSize: 25)),
        SizedBox(height: 5),
        TextField(
          controller: nameGroup,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.lightBlueAccent),
            ),
            //border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  //tạo phần mô tả
  Widget createDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Mô Tả:", style: TextStyle(fontSize: 25)),
        SizedBox(height: 5),
        TextField(
          textAlignVertical: TextAlignVertical.top,
          minLines: 3,
          maxLines: 5,
          controller: descriptionGroup,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.lightBlueAccent),
            ),
          ),
        ),
      ],
    );
  }

  Widget create_avt() {
    return Row(
      children: [
        Expanded(
          child: Text("Chọn ảnh đại diện:", style: TextStyle(fontSize: 20)),
        ),
        Expanded(
          child: InkWell(
            onTap: () async {
              print("pick img");
              final ImagePicker pickerImg = ImagePicker();
              final XFile? image = await pickerImg.pickImage(
                source: ImageSource.gallery,
              );
              if (image != null) {
                setState(() {
                  avt_group = File(image.path);
                  isUploadImage = true;
                });

                if (avt_group != null) {
                  UrlImg = await firebaseServicesGroup.uploadImageGroupChat(
                    nameGroup.text,
                    avt_group!,
                  );
                }

                setState(() {
                  isUploadImage = false;
                });
              }
            },
            child: (avt_group == null)
                ? Image.asset(
                    'assets/images/picked_avt_group.png',
                    width: 100,

                    height: 100,
                    fit: BoxFit.contain,
                  )
                : Image.file(
                    // avt_group.path?'assets/images/picked_avt_group.png',
                    avt_group!,
                    fit: BoxFit.contain,
                    width: 45,
                    height: 45,
                  ),
          ),
        ),
      ],
    );
  }
}
