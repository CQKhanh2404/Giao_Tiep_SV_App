import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id_message;
  // final String chat_id;
  final String sender_id;
  final String? content;
  final String? media_url;
  final DateTime create_at;
  final bool isread;
    final String sender_name;  
  final String sender_avatar; 
  Message({
    required this.isread,
    required this.id_message,
    required this.sender_id,
    this.content,
    this.media_url,
    required this.create_at,
    required this.sender_name,
    required this.sender_avatar
  });

  //doc du lieu
  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      isread: data['isRead'] ?? false,
      id_message: doc.id,
      sender_id: data['sender_id'] ?? "no id",
      create_at: (data['create_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      content: data['content'] ?? "no conten",
      media_url:
          data['media_url'] ??
          "",
      sender_avatar: data['avt_sender']??"https://tse1.mm.bing.net/th/id/OIP.Kn_AdPUU9nsSfHQfFmHPDgHaH4?rs=1&pid=ImgDetMain&o=7&rm=3",
      sender_name: data['name_sender']??"khong xac dinh", 

    );
  }

  //dua du lieu len firebase
  Map<String,dynamic> toMap(){
    return{
      'id_message':id_message,
      'content':content,
      'media_url':media_url,
      'isRead':isread,
      'sender_id':sender_id,
      'avt_sender':sender_avatar,
      'name_sender':sender_name,
      'create_at':FieldValue.serverTimestamp(),
    };
  }
}
