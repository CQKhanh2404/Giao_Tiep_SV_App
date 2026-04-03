import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Data/room_chat.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/data/dataRoomChat.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/view/Member_Chat.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/widget/featchMemberChat.dart';

class HeaderMessage extends StatelessWidget {
  final ChatRoom myInfo;
  final Dataroomchat dataroomchat;
  final String myId;
  HeaderMessage({
    super.key,
    required this.myInfo,
    required this.dataroomchat,
    required this.myId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),

      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 2)),
      ),

      child: createHeader(context),
    );
  }

  Widget createHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: ClipOval(
            child: Image.asset(
              "assets/icons/ic_back.png",
              fit: BoxFit.cover,
              width: 30,
              height: 30,
            ),
          ),
        ),

        Row(
          children: [
            Text(
              (myInfo.typeId == 1) ? myInfo.name : dataroomchat.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),

            SizedBox(width: 10),

            InkWell(
              onTap: () {
                print("${dataroomchat.id} - ${myInfo.roomId}");
                print("type: ${myInfo.typeId}");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShowMemberChat(
                      idRoom: dataroomchat.id,
                      myId: myId,
                      thrown: myInfo.typeId,
                    ),
                  ),
                );
              },
              child: ClipOval(
                child: Image.network(
                  (myInfo.typeId == 1) ? myInfo.avatarUrl : dataroomchat.avt,
                  fit: BoxFit.cover,
                  width: 45,
                  height: 45,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
