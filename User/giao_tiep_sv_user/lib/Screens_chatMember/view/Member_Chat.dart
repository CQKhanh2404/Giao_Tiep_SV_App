import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/widget/clicked_add_member.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/widget/clicked_out_group.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/widget/featchMemberChat.dart';

class ShowMemberChat extends StatefulWidget {
  final int thrown;
  final String idRoom;
  final String myId;
  const ShowMemberChat({super.key, required this.idRoom, required this.myId, required this.thrown});

  @override
  State<ShowMemberChat> createState() => _ShowMemberChatState();
}

class _ShowMemberChatState extends State<ShowMemberChat> {
  List<String> listFirst=[];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Thành viên",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Featchmemberchat(idRoomChat: widget.idRoom,onLoad: (value) {
        
        print("membergroup1: ${value.length}");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if(!mounted){
          return;
        }

        if(listFirst.length!=value.length){
          setState(() {
          listFirst = value;
        });
        }
        },);
      },),


      //2 nut chuc nang
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(bottom: 30),
        child: Row(
          //crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Text("aa:${listFirst.length}"),
            //chuc nang them thanh vien 
            (widget.thrown==0 && listFirst.length==2)?SizedBox():ClickedAddMember(myId: widget.myId,ListFirst: listFirst,myRoom: widget.idRoom,thrown: widget.thrown,),
            //chuc nang roi nhom
            ClickedOutGroup(myId: widget.myId,roomId: widget.idRoom,),
          ],
        ),
      ),
    );
  }
}
