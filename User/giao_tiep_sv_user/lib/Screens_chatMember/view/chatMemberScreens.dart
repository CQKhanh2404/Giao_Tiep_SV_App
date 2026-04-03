import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:giao_tiep_sv_user/Data/Users.dart';
import 'package:giao_tiep_sv_user/Data/room_chat.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/UserServices.dart';
import 'package:giao_tiep_sv_user/Screen_member_group/widget/customSearch.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/FirebaseStore/MessageService.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/data/dataRoomChat.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/view/CreateRoomChat.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/view/chatMessage.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/widget/custom_chat_member.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/widget/pickedMemberChatSingle.dart';
import 'package:giao_tiep_sv_user/ThongBao/ManHinhThongBao.dart';
import 'package:giao_tiep_sv_user/Widget/MyButton.dart';
import 'package:giao_tiep_sv_user/Widget/headerWidget.dart';

class ChatMemberScreen extends StatefulWidget {
  const ChatMemberScreen({super.key});

  @override
  State<ChatMemberScreen> createState() => _ChatMemberScreenState();
}

class _ChatMemberScreenState extends State<ChatMemberScreen> {
  final MessageService messService = MessageService();
  final Userservices userService = Userservices();
  bool isload = false;
  bool isloadListMessage = true;

  List<ChatRoom> listMessage = [];
  List<ChatRoom> listChatGroup = [];
  double width = 0;
  bool ischatGroup = false;
  List<ChatRoom> listMessageSearch = [];
  late final Uid;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      Uid = user.email!.split("@")[0].toUpperCase();
      print("My UID: $Uid");

      // Sau khi có UID thì gọi hàm lấy dữ liệu
      FeatchDataListChats(Uid);
    } else {
      print(" User chưa đăng nhập!");
    }
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // child: SingleChildScrollView(
        child: Column(
          children: [
            //header
            createHeader(Uid.toString()),
            //search Message
            SizedBox(height: 8),
            createSearchMessage(),
            //2 button bạn bè và nhóm
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: createButtonMessage(),
            ),
            //danh sach tin nhắn
            Expanded(child: createListMessage()),
          ],
        ),
      ),
      floatingActionButton:
      SpeedDial(
        icon: Icons.message,
        activeIcon: Icons.close,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        activeBackgroundColor: Colors.red,
        children: [
          SpeedDialChild(
            child: Icon(Icons.person),
            label: "Gửi tin nhắn người dùng khác",
            onTap: () {
              print("nhan cho nguoi dung khac");
              Navigator.push(context, MaterialPageRoute(builder: (context) => PickedmemberchatSingle(myID: Uid),));
            },
          ),

          SpeedDialChild(
            child: Icon(Icons.group),
            label: "Tạo tin nhắn nhóm",
            onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateRoomChat(myId: Uid),
              ),
            );
            },
          )
        ],
      )
   
   
    );
  }

  //get user tu id
  Future<Users?> fetchIdUs(String myId) {
    return userService.getUserForID(myId);
  }

  //lay dl dua vao danh sach chat
  Future<void> FeatchDataListChats(String Uid) async {
    isload = true;
    await messService.streamChatRooms(Uid).listen((event) {
      print("listChat length: ${event.length}");
      if (mounted) {
        setState(() {
          listMessage = event.where((element) {
            return element.typeId == 0;
          }).toList();
          listMessageSearch = listMessage;

          listChatGroup = event.where((element) {
            return element.typeId == 1;
          }).toList();
          listMessageSearch = listChatGroup;
          isload = false;
        });
      }
    });
  }

  //custom header
  Widget createHeader(String myId) {
    return FutureBuilder<Users?>(
      future: fetchIdUs(myId.toUpperCase()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Lỗi: ${snapshot.error}');
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Text('Không tìm thấy user');
        }

        final user = snapshot.data!;

        return Headerwidget(
          myUs: user,
          width: width.toDouble(),
          chucnang: IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ManHinhThongBao(currentUser: user),
              ),
            ),
            icon: const Icon(
              Icons.notifications,
              color: Colors.amber,
              size: 45,
            ),
          ),
        );
      },
    );
  }

  //create listview message
  Widget createListMessage() {
    bool isnew = true;
    return (isload == true)
        ? Center(child: CircularProgressIndicator())
        : RefreshIndicator(onRefresh: () async{
          if(mounted){
             setState(() {
              
            });
          }
        },
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: listMessageSearch.length,
            itemBuilder: (context, index) {
              var value = listMessageSearch[index];
              return CustomChatMember(
                key: ValueKey(value.roomId),
                myid: Uid,
                userInfo: value,
                content: value.lastMessage,
                isnew: isnew,
                ontap: (valueTap) {
                  Dataroomchat valueOnTap = valueTap;
                  //value tap tra ve id phong da nhan vao
                  //chuyen sang man hinh nhan tin
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ScreenMessage(
                          myId: Uid.toString(),
                          sender_to: ChatRoom(
                            roomId: "",
                            lastMessage: value.lastMessage,
                            lastSender: value.lastSender,
                            lastTime: DateTime.now(),
                            users: [],
                            name: value.name,
                            createdAt: DateTime.now(),
                            avatarUrl: value.avatarUrl,
                            createdBy: value.createdBy,
                            typeId: value.typeId,
                          ),
                          idRoom: valueOnTap.id,
                          avtChat: valueOnTap.avt,
                          nameChat: valueOnTap.name,
                          dataroomchat: valueOnTap,
                        );
                      },
                    ),
                  );

                  print("room john: ${valueTap}");
                },
              );
            },
          ),
        );
  }

  //nut chon ban be va nhom
  Widget createButtonMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Mybutton(
          Mycolor: Color(0xffecf3e5),
          url_icon: "assets/icons/ic_friend.png",
          nameButton: "Bạn bè",
          ontap: () {
            setState(() {
              ischatGroup = false;
              listMessageSearch = listMessage;
            });
          },
        ),
        Mybutton(
          Mycolor: Color(0xffffe5e5),
          url_icon: "assets/icons/ic_group.png",
          nameButton: "Nhóm",
          ontap: () {
            setState(() {
              ischatGroup = true;
              listMessageSearch = listChatGroup;
            });
          },
        ),
      ],
    );
  }

  //tim kiem cuoc tro chuyen
  Widget createSearchMessage() {
    return Customsearch(
      onTap: (value) {
        if (ischatGroup == false) {
          setState(() {
            listMessageSearch = listMessage.where((element) {
              return element.name.toLowerCase().contains(value.toLowerCase()) &&
                  element.typeId == 0;
            }).toList();
          });
        } else {
          setState(() {
            listMessageSearch = listMessage.where((element) {
              return element.name.toLowerCase().contains(value.toLowerCase()) &&
                  element.typeId == 1;
            }).toList();
          });
        }
      },
    );
  }
}
