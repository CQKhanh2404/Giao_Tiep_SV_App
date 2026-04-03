import 'dart:io';

import 'package:flutter/material.dart';

class Custommessage extends StatelessWidget {
  final bool forme_sender;
  final String url_avt;
  final String nameSender;
  final String content;
  final String? Url_media;
  final DateTime dateSend;

  const Custommessage({
    super.key,
    required this.forme_sender,
    required this.url_avt,
    required this.content,
    this.Url_media, required this.nameSender, required this.dateSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: createMessage(),
    );
  }


  Widget createMessage() {
  bool hasText = content.isNotEmpty;
  bool hasImage = Url_media != null && Url_media!.isNotEmpty;

  // Nếu là người khác gửi
  if (!forme_sender) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipOval(
          child: Image.network(
            url_avt,
            fit: BoxFit.cover,
            height: 35,
            width: 35,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasText)
                  Text(
                    content,
                    style: const TextStyle(fontSize: 14),
                    softWrap: true,
                  ),
                if (hasImage) ...[
                  const SizedBox(height: 8),
                  _buildImage(Url_media!),
                ],

                SizedBox(height: 5,),
                //thoi gian gui tin nhan
                Text("${dateSend.hour}:${dateSend.minute}",style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey
                ),)
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Nếu là bản thân gửi
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Flexible(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (hasText)
                Text(
                  content,
                  style: const TextStyle(fontSize: 14),
                  softWrap: true,
                ),
              if (hasImage) ...[
                const SizedBox(height: 8),
                _buildImage(Url_media!),
              ],

               SizedBox(height: 5,),
                //thoi gian gui tin nhan
                Text("${dateSend.hour}:${dateSend.minute}",style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey
                ),)
            ],
          ),
        ),
      ),
      const SizedBox(width: 10),
      ClipOval(
        child: Image.network(
          url_avt,
          fit: BoxFit.cover,
          height: 35,
          width: 35,
        ),
      ),
    ],
  );
}

Widget _buildImage(String url) {
  // Nếu là link mạng (Firebase Storage, HTTP, HTTPS)
  if (url.startsWith("http")) {
    return Image.network(url, width: 150, fit: BoxFit.cover);
  }
  //  Nếu là file local (chụp hoặc chọn từ máy)
  return Image.file(File(url), width: 150, fit: BoxFit.cover);
}



}
