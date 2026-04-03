import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Data/Users.dart';
import 'package:giao_tiep_sv_user/Data/message.dart';
import 'package:giao_tiep_sv_user/Data/room_chat.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/UserServices.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/FirebaseStore/MessageService.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/data/dataRoomChat.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/widget/customMessage.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/widget/custom_sender_message.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/widget/header_Message.dart';

class ScreenMessage extends StatefulWidget {
  final String myId;
  final String nameChat;
  final String avtChat;
  final ChatRoom sender_to;
  final String idRoom;
  final Dataroomchat dataroomchat;
  const ScreenMessage({
    super.key,
    required this.sender_to,
    required this.idRoom,
    required this.myId,
    required this.nameChat,
    required this.avtChat,
    required this.dataroomchat,
  });

  @override
  State<ScreenMessage> createState() => ScreenMessageState();
}

class ScreenMessageState extends State<ScreenMessage> {
  //khai báo service
  final messageService = MessageService();
  final userService = Userservices();

  //khai bao dl
  Users? myus;
  List<Message> listMessage = [];

  //chuyen dong man hinh xuong ben duoi
  final ScrollController _scrollController = ScrollController();
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    try {
      loadInfoUser(widget.myId);
      //print("name: ${myus!.fullname.toString()}");
    } catch (e) {
      print("loi init: $e");
    }
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xfff5f5f5),
      body: SafeArea(
        child: Column(
          children: [
            Header(),
            Expanded(child: createListMessage()),
            create(widget.myId.toString()),
          ],
        ),
      ),
    );
  }

  //lay thong tin User
  Future<void> loadInfoUser(String id) async {
    try {
      print("My id: $id");
      Users? result = await userService.getUserForID(id);
      if (!mounted) {
        return;
      } else {
        setState(() {
          myus = result;
        });
      }

      if (myus != null) {
        print("lay du lieu thanh cong");
      } else {
        print("lay dl that bai");
      }
    } catch (e) {
      print("da co loix $e");
    }
  }

  //gui tin nhan
  Widget create(String myId) {
    return SafeArea(
      child: CustomSenderMessage(
        onSelectedImage: (value) async {
          //gui hinh anh
          if (value != null) {
            await messageService.sendImageMessage(
              roomId: widget.idRoom, // id phòng chat
              senderId: myId.toUpperCase(), // id người gửi
              senderName: myus!.fullname, // tên người gửi
              senderAvatar: myus!.url_avt,
              imageFile: value, // ảnh đã chọn
            );
          }
        },

        //gui tin nhan
        onTapSend: (value) async {
          //value tra ve doan tin nhan da nhap
          final newValue = await messageService.sendMessage(
            avt_sender: myus!.url_avt,
            name_sender: myus!.fullname,
            roomId: widget.idRoom,
            senderID: widget.myId.toUpperCase(),
            content: value,
          );
          listMessage.add(newValue!);
          _scrollToBottom();
        },
      ),
    );
  }

  //hien thi list tin nhan
  Widget createListMessage() {
    //lay avt nguoi dung
    return StreamBuilder(
      stream: messageService.streamMessage(widget.idRoom),
      builder: (context, snapshot) {
        //doi load dl
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.blue));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("Chưa có tin nhắn nào"));
        }

        final lisstMessage = snapshot.data!;
        return ListView.builder(
          controller: _scrollController,
          shrinkWrap: true,
          itemCount: lisstMessage.length,
          reverse: false,
          itemBuilder: (context, index) {
            var value = lisstMessage[index];
            return Custommessage(
              dateSend: value.create_at,
              forme_sender: (value.sender_id == widget.myId),
              nameSender: value.sender_name, //ten nguoi gui
              url_avt: value.sender_avatar, //avt nguoi gui
              content: value.content ?? "",
              Url_media: value.media_url ?? "",
            );
          },
        );
      },
    );
  }

  Widget Header() {
    return HeaderMessage(
      myInfo: widget.sender_to,
      dataroomchat: widget.dataroomchat,
      myId: widget.myId,
    );
  }
}
