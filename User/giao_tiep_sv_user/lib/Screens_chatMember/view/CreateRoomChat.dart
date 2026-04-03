import 'dart:io';

import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Data/Users.dart';
import 'package:giao_tiep_sv_user/Data/room_chat.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/FirebaseStore/MessageService.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/widget/pickedMemberChat.dart';
import 'package:giao_tiep_sv_user/Widget/MyButton.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';


class CreateRoomChat extends StatefulWidget {
  final String myId;
  const CreateRoomChat({super.key, required this.myId});

  @override
  State<CreateRoomChat> createState() => _CreateRoomChatState();
}

class _CreateRoomChatState extends State<CreateRoomChat> {
  //khai bao servies
  final messService = MessageService();
  List<Users> listSelected_uyquyen = [];
  List<String> listIDUser = [];
  String id = Uuid().v4();
  TextEditingController nameChat = TextEditingController();
  //chon hình ảnh
  File? _anhNhom;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getIDUser();
  }

  @override void dispose() {
    // TODO: implement dispose
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Tạo cuộc trò chuyện",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            _buildGroupImagePicker(),
            SizedBox(height: 20,),
            createNameGroup(),
            SizedBox(height: 20),
            createButton(),
            SizedBox(height: 20),
            createConfirm(
              ChatRoom(
                roomId: id,
                lastMessage: "",
                lastSender: "",
                lastTime: DateTime.now(),
                users: listIDUser,
                name: nameChat.text,
                avatarUrl:
                    "https://wallpapers.com/images/hd/football-players-hd-ronaldo-real-madrid-2x3lm9waylolretc.jpg",
                typeId: 0,
                createdBy: widget.myId.toUpperCase(),
                createdAt: DateTime.now(),
              ),
            ),

          ],
        ),
      ),
    );
  }
  //lay id trong danh sach nguoi dung
  Future<List<String>> getIDUser() async {
    listIDUser.clear();
    listIDUser.add(widget.myId.toUpperCase());
    for (var element in listSelected_uyquyen) {
    //  if(!checkIdtrung(element, listSelected_uyquyen)){
       listIDUser.add(element.id_user.toUpperCase());
 //    }
    }
    print("list duoc chon : ${listIDUser.length}");
    return listIDUser;
  }

  //check trung id 
  bool checkIdtrung(Users id,List<Users> list){
    for(var item in list){
      if(item.id_user == id.id_user){
        return true;
      }
    }

    return false;
  }

   Future<void> _chonAnh() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _anhNhom = File(image.path);
      });
    }
  }

  
  //chon anh cho cuo tro chuyen
   Widget _buildGroupImagePicker() {
    return Center(
      child: Column(
        children: [
          const Text(
            "Ảnh nhóm:",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: _chonAnh,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle, // Thay đổi thành hình tròn
                border: Border.all(
                  color: Colors.blue,
                  width: 3,
                ), // Viền nổi bật
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _anhNhom != null
                  ? ClipOval(child: Image.file(_anhNhom!, fit: BoxFit.cover))
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 40, color: Colors.blue),
                        SizedBox(height: 4),
                        Text(
                          "Chọn ảnh",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }


  //create name group
  Widget createNameGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Tên nhóm chat:", style: TextStyle(fontSize: 25)),
        SizedBox(height: 5),
        TextField(
          controller: nameChat,
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

  //chon nguoi nhan
  Widget createButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Mybutton(
          url_icon: 'assets/images/user.png',
          nameButton: "Chọn người",
          Mycolor: Colors.white,
          ontap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Pickedmemberchat(
                myID: widget.myId,
                throwss: 2,
                GetList: (value) {
                  setState(() {
                    listSelected_uyquyen = value;
                    getIDUser();
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  //nut xac nhan tao nhom chat
  Widget createConfirm(ChatRoom chatroom) {
    return InkWell(
      onTap: () async{
        if (nameChat.text.trim() == "" || nameChat.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Vui long nhap day du thong tin"),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.red.withOpacity(0.6),
            ),
          );
        }  if (chatroom.users.length < 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Vui long chon thanh vien tro chuyen"),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.red.withOpacity(0.6),
            ),
          );
        } else {
          String? urlImg;
          if(_anhNhom != null){
            urlImg = await messService.uploadImageGroupChat(nameChat.text.trim(), _anhNhom!);
          }

          ChatRoom newChatRoom = ChatRoom(roomId: id,
           lastMessage: "",
            lastSender: "", 
            lastTime: DateTime.now(), users: listIDUser, name: nameChat.text,
             avatarUrl: urlImg??"https://cdn-icons-png.flaticon.com/512/149/149071.png", 
             typeId: (listIDUser.length>2)?1:0,
             createdBy: widget.myId.toUpperCase(), 
             createdAt: DateTime.now());
          messService.createChatRooms(newChatRoom);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Tao cuoc tro chuyen :${nameChat.text.toString()} thanh cong"),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green.withOpacity(0.6),
            ),
          );
          Navigator.pop(context);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.lightBlueAccent,
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.symmetric(horizontal: 15),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Text(
          "Xác nhận",
          style: TextStyle(color: Colors.white, fontSize: 19),
        ),
      ),
    );
  }
}
