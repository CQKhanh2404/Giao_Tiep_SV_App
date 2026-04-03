import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/FirebaseStore/MessageService.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/widget/picked_add_member_chat.dart';

class ClickedAddMember extends StatefulWidget {
  final String myRoom;
  final String myId;
  final int thrown;
  final List<String> ListFirst;

  
  const ClickedAddMember({
    super.key,
    required this.myId,
    required this.ListFirst, required this.myRoom, required this.thrown,
  });

  @override
  State<ClickedAddMember> createState() => _ClickedAddMemberState();
}

class _ClickedAddMemberState extends State<ClickedAddMember> {
//danh sach cac id nguoi dung duoc chon
  List<String> listIdMemberSelected=[];
  final messService = MessageService();
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print("clicked them thanh vien nhom chat");
        tapAddMember();
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.blue,
        ),
        child: Row(
          children: [
            Icon(Icons.person_add, color: Colors.white),
            SizedBox(width: 10),
            Text("Thêm thành viên", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  void tapAddMember() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PickedAddMemberChat(
          throwss: widget.thrown,
          myID: widget.myId,
          ListFirst: widget.ListFirst,
          GetList: (value)async {
            value.forEach((element) {
              listIdMemberSelected.add(element.id_user);
            },);
           await addMemberChat(listIdMemberSelected);
          },
        ),
      ),
    );
  }

  //them thanh vien vao nhom chat
  Future<void> addMemberChat(List<String> listAddMember)async{
    await messService.addMembersToChatRoom(widget.myRoom, listAddMember);
  }
}
