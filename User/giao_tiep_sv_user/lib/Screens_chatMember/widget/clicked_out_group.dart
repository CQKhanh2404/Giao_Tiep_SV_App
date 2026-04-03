import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Home_screen/home.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/FirebaseStore/MessageService.dart';

class ClickedOutGroup extends StatefulWidget {
  final String roomId;
  final String myId;
  const ClickedOutGroup({super.key, required this.roomId, required this.myId});

  @override
  State<ClickedOutGroup> createState() => _ClickedOutGroupState();
}

class _ClickedOutGroupState extends State<ClickedOutGroup> {
  final messService = MessageService();
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async{
        print("clicked roi nhom chat");
        _showExitDialog(context);
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.red,
        ),
        child: Row(
          children: [
            Icon(Icons.output_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text("Rời nhóm", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Future<void> outGroup()async{
    await messService.removeMembersToChatRoom(widget.roomId, widget.myId);
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home(),));
  }

  Future<bool?> _showExitDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false, // bắt buộc chọn
    builder: (_) => AlertDialog(
      title: const Text('Thoát ?'),
      content: const Text('Bạn có muốn thoát cuộc trò chuyện này không?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false), // không thoát
          child: const Text('Không'),
        ),
        TextButton(
          onPressed: () async{
            await outGroup();
          }, // đồng ý thoát
          child: const Text('Có'),
        ),
      ],
    ),
  );
}
}
