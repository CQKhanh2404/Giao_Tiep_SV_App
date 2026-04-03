import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Data/Users.dart';
import 'package:giao_tiep_sv_user/Data/room_chat.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/UserServices.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/data/dataRoomChat.dart';

class CustomChatMember extends StatefulWidget {
  // final String id_chat;
  final String myid;
  final ChatRoom userInfo;
  final String content;
  final bool isnew;
  final ValueChanged ontap;
  const CustomChatMember({
    super.key,
    required this.content,
    required this.isnew,
    required this.ontap,
    required this.userInfo,
    required this.myid,
  });

  @override
  State<CustomChatMember> createState() => _CustomChatMemberState();
}

class _CustomChatMemberState extends State<CustomChatMember> {
  String URl_avt =
      "https://as2.ftcdn.net/v2/jpg/02/88/85/71/1000_F_288857162_l7ZOOsEveQf1d8PMsNC6HMQFeqafLJhx.jpg";
  String name_chat = "loading...";
  final usDb = Userservices();

  @override
  void initState() {
    super.initState();
    xulyNameandAVT();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: createMember(),
    );
  }

  //lay thong tin nguoi dung tu id
  Future<Users?> getInfoUser(String id) async {
    return await usDb.getUserForID(id);
  }

  //xu ky avt va name cho nhom va ca nhan 1-1
  void xulyNameandAVT() async {
    if (widget.userInfo.typeId == 1) {
      URl_avt = widget.userInfo.avatarUrl;
      name_chat = widget.userInfo.name;
    } else if (widget.userInfo.typeId == 0) {
      for (var item in widget.userInfo.users) {
        if (!item.trim().toLowerCase().contains(widget.myid.toLowerCase())) {
          print("thang id ${widget.myid}");
          var user = await getInfoUser(item);
          if(mounted){
            setState(() {
            URl_avt =  user!.url_avt;
            name_chat =  user!.fullname;
          });
          }
        }
      }
    }
  }

  Widget createMember() {
    return InkWell(
      onTap: () {
        Dataroomchat dataroomChat = Dataroomchat(avt: URl_avt,name: name_chat,id: widget.userInfo.roomId);
        return widget.ontap?.call(dataroomChat);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ClipOval(child: Image.network(URl_avt, width: 45, height: 45)),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name_chat,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.content,
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),

          //update status new or old
          Icon(
            Icons.circle,
            size: 10,
            color: (widget.isnew == true) ? Colors.blue : Colors.red,
          ),
        ],
      ),
    );
  }
}
