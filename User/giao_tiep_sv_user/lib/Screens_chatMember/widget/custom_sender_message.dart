import 'dart:io';
import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/view/chatMessage.dart';
import 'package:image_picker/image_picker.dart';

class CustomSenderMessage extends StatefulWidget {
  final ValueChanged? onTapSend;
  final ValueChanged<File?>? onSelectedImage;
  const CustomSenderMessage({super.key, this.onTapSend, this.onSelectedImage});

  @override
  State<CustomSenderMessage> createState()=>_CustomSenderMessage();
}

class _CustomSenderMessage extends State<CustomSenderMessage>{

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 15,vertical: 10
      )
      ,child: createSender());
  }

  //phan chon va gui tin nhan 

  Widget createSender() {
    TextEditingController contenttxt = TextEditingController();
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              GestureDetector(
                onTap: ()async {
                  // print("image");
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  if(image!=null){
                    widget.onSelectedImage?.call(File(image.path));
                  }
                },
                child: Image.asset(
                  "assets/icons/ic_image.png",
                  fit: BoxFit.cover,
                  width: 35,
                  height: 35,
                ),
              ),

              SizedBox(width: 10),

              // GestureDetector(
              //   onTap: () {
              //     // print("file");
              //   },
              //   child: Image.asset(
              //     "assets/icons/ic_file.png",
              //     fit: BoxFit.cover,
              //     width: 35,
              //     height: 35,
              //   ),
              // ),
            ],
          ),
          flex: 2,
        ),
        Expanded(
          child: TextField(
            controller: contenttxt,
            decoration: InputDecoration(
              hintText: "Nhập nội dung",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: Colors.black,
                  width: 1
                )
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: Colors.blue,
                  width: 1
                )
              )
            ),

          ),
          flex: 5,
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              // print("send");
              if(contenttxt.text.isNotEmpty){
               
                widget.onTapSend?.call(contenttxt.text.trim());
               setState(() {
                  contenttxt.clear();
                });
              }
            },

            child: Icon(Icons.send, color: Colors.blue),
          ),
          flex: 1,
        ),
      ],
    );
  }}
