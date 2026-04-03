import 'dart:io';

import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_admin/Data/Notifycation.dart';
import 'package:giao_tiep_sv_admin/Data/Users.dart';
import 'package:giao_tiep_sv_admin/Data/faculty.dart';
import 'package:giao_tiep_sv_admin/FirebaseFirestore/NotifycationFirebase.dart';
import 'package:giao_tiep_sv_admin/Tao_nhom_cong_Dong/view/Screen_uyquyen.dart';
import 'package:giao_tiep_sv_admin/Tao_nhom_cong_Dong/widget/custom_all_khoa.dart';
import 'package:giao_tiep_sv_admin/Tao_nhom_cong_Dong/widget/selected.dart';
import 'package:giao_tiep_sv_admin/widget/MyButton.dart';
import 'package:uuid/uuid.dart';

class ScreenNotify extends StatefulWidget {
  const ScreenNotify({super.key});

  @override
  State<ScreenNotify> createState() => _ScreenNotify();
}

class _ScreenNotify extends State<ScreenNotify> {
  //firestore notify
  final Notifycationfirebase notifyService = Notifycationfirebase();
  File? avt_group = null;
  TextEditingController nameGroup = TextEditingController();
  TextEditingController descriptionGroup = TextEditingController();
  List<Users> listSelected_uyquyen = [];
  List<Faculty> listSelected_khoa = [];
  List<Users> ListMember = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
          "Gửi thông báo",
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
            SizedBox(height: 10),
            createButton(),
            SizedBox(height: 15),
            CustomSlected(
              Throws: 2,
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

  Widget complate_create() {
    return InkWell(
      onTap: () async {
        if (nameGroup.text.trim().isEmpty ||
            descriptionGroup.text.trim().isEmpty || (listSelected_khoa.length <= 0 &&
            listSelected_uyquyen.length <= 0)
             ) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vui lòng nhập đầy đủ thông tin!'),
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          final String id = const Uuid().v4();
          final String title = nameGroup.text;
          final String content = descriptionGroup.text;
          final int type_notify = 1;
          Map<String, dynamic> selectedReps = {};
          

          if (listSelected_uyquyen.length > 0) {
            for (var item in listSelected_uyquyen) {
              selectedReps[item.id_user] = item.fullname;
            }
          }
          if (listSelected_khoa.length > 0) {
            for (var item in listSelected_khoa) {
              selectedReps[item.id] = item.name_faculty;
            }
          }

          Notifycation notifyAdd = Notifycation(
            title,
            id: id,
            type_notify: type_notify,
            content: content,
            user_recipient_ID: selectedReps,
          );
          notifyService.createNotifycation(notifyAdd);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gửi thông báo thành công!'),
              duration: Duration(seconds: 3),
            ),
          );
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
          child: Text(
            "Xác nhận",
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
          nameButton: "Chọn người",
          Mycolor: Colors.white,
          ontap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Screen_uyquyen(
                throwss: 2,
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
        Text("Tiêu đề:", style: TextStyle(fontSize: 25)),
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

  Widget createDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Nội dung:", style: TextStyle(fontSize: 25)),
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
}
