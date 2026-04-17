import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:giao_tiep_sv_user/Data/message.dart';
import 'package:giao_tiep_sv_user/Data/room_chat.dart';

// Service quản lý tin nhắn: gửi tin, tải danh sách phòng chat, quản lý thành viên
class MessageService {
  final FirebaseFirestore messDB = FirebaseFirestore.instance;

  //xu ly dua anh len storage
  final FirebaseStorage ref = FirebaseStorage.instance;

  //dua hinh anh len storage
  Future<String?> uploadImageGroupChat(String namefile, File imageFile) async {
    try {
      final putImage = ref.ref().child("chats/group/$namefile");

      await putImage.putFile(imageFile!);
      //lay url img
      final imgUrl = await putImage.getDownloadURL();
      print("url anh nhom");
      return imgUrl;
    } catch (e) {
      print("loi khi up anh: $e");
      return null;
    }
  }

  //gui tin nhan anh 
   Future<void> sendImageMessage({
    required String roomId,
    required String senderId,
    required String senderName,
    required String senderAvatar,
    required File imageFile,
  }) async {
    try {
      // upload ảnh lên Firebase Storage
      final String? imageUrl = await uploadImageGroupChat(
        "${DateTime.now().millisecondsSinceEpoch}_${senderId}.jpg",
        imageFile,
      );

      if (imageUrl == null) throw Exception("Upload ảnh thất bại");

      // tạo id message
      final docRef = messDB
          .collection("ChatRooms")
          .doc(roomId)
          .collection("Message")
          .doc();

      // tạo model Message
      final message = Message(
        id_message: docRef.id,
        sender_id: senderId,
        content: "", // không có nội dung text
        media_url: imageUrl,
        isread: false,
        sender_name: senderName,
        sender_avatar: senderAvatar,
        create_at: DateTime.now(),
      );

      // lưu vào Firestore
      await docRef.set(message.toMap());

      // cập nhật lastMessage cho phòng chat
      await messDB.collection("ChatRooms").doc(roomId).update({
        "lastMessage": "📷 Ảnh",
        "lastTime": FieldValue.serverTimestamp(),
      });

      print(" Gửi ảnh thành công: $imageUrl");
    } catch (e) {
      print(" Lỗi khi gửi ảnh: $e");
    }
  }

  //lay danh sách tin nhan
  // Lấy danh sách tất cả phòng chat của người dùng (một lần)
  Future<List<ChatRoom>> listChat(String myID) async {
    try {
      final querySnap = await messDB
          .collection("ChatRooms")
          .where("users", arrayContains: myID.toUpperCase())
          .orderBy("lastTime", descending: true)
          .get();

      if (querySnap.docs.isEmpty) {
        print("Không có phòng chat nào cả");
        return [];
      }

      List<ChatRoom> roomsChat = querySnap.docs.map((e) {
        final data = e.data();
        data["roomId"] = e.id;
        return ChatRoom.fromFirestore(e);
      }).toList();

      return roomsChat;
    } catch (e) {
      print("Lỗi lấy danh sách chat: $e");
      return [];
    }
  }

  // Stream realtime để load lai danh sách tin nhắn
  // Stream real-time danh sách phòng chat (ựng dụng sẽ tự động cập nhật khi có tin mới)
  Stream<List<ChatRoom>> streamChatRooms(String myID) {
    return messDB
        .collection("ChatRooms")
        .where("users", arrayContains: myID.toUpperCase().trim())
        .orderBy("lastTime", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data["roomId"] = doc.id;
            print(myID.toUpperCase());
            return ChatRoom.fromFirestore(doc);
          }).toList(),
        );
  }

  //stream real time load các tin nhắn
  // Stream real-time các tin nhắn bên trong một phòng chat
  Stream<List<Message>> streamMessage(String idRoomChat) {
    return messDB
        .collection("ChatRooms")
        .doc(idRoomChat)
        .collection("Message")
        .orderBy("create_at", descending: false)
        .snapshots()
        .map((event) {
          return event.docs.map((doc) {
            return Message.fromFirestore(doc);
          }).toList();
        });
  }

  //gui tin nhan
  // Gửi tin nhắn văn bản hoặc media vào phòng chat, cập nhật lastMessage của phòng
  Future<Message?> sendMessage({
    required String roomId,
    required String senderID,
    required String avt_sender,
    required String name_sender,
    String? content,
    String? mediaUrl,
  }) async {
    try {
      final messRef = messDB
          .collection("ChatRooms")
          .doc(roomId)
          .collection("Message")
          .doc();
      final message = Message(
        isread: false,
        id_message: messRef.id,
        content: content ?? "null roi",
        sender_id: senderID,
        sender_avatar: avt_sender,
        sender_name: name_sender,
        media_url: mediaUrl ?? "",
        create_at: DateTime.now(),
      );

      await messRef.set(message.toMap());
      print("gui tin nhan thanh cong");

      //cap nhat lai phong chat
      await messDB.collection("ChatRooms").doc(roomId).update({
        "lastMessage": content ?? "",
        "lastTime": FieldValue.serverTimestamp(),
      });
      return message;
    } catch (e) {
      print("loi khi gui tin nhan $e");
      return null;
    }
  }

  //tao nhom chats
  // Tạo phòng chat mới trên Firestore
  Future<void> createChatRooms(ChatRoom chatroom) async {
    try {
      await messDB
          .collection("ChatRooms")
          .doc(chatroom.roomId)
          .set(chatroom.toMap());
      print("tao nhom chat thanh cong");
    } catch (e) {
      print("loi khi tao nhom: $e");
    }
  }

  //lay danh sách các user của nhóm
  // Lấy danh sách ID của các thành viên trong phòng chat (stream real-time)
  Stream<List<String>> getListIdUser(String idGroup){
    print("hiep: $idGroup");
    return messDB.collection("ChatRooms").doc(idGroup).snapshots().map((event) {
      if(event.exists){
        final data = event.data() as Map<String,dynamic>;
        // Kiểm tra và lấy mảng users
          if (data.containsKey('users') && data['users'] != null) {
            // Ép kiểu an toàn từ List<dynamic> sang List<String>
            return List<String>.from(data['users']);
          }
      }
      print("khong co du lieu danh sacsh user");
      return [];
    },);
  }


  //them danh sach thanh vien vao nhom chat
  // Thêm nhiều thành viên vào phòng chat nhóm
  Future<void> addMembersToChatRoom(String roomId, List<String> userIds) async {
  try {
    await messDB.collection("ChatRooms").doc(roomId).update({
      "users": FieldValue.arrayUnion(userIds),
    });

    print("Thêm danh sách thành viên thành công!");
  } catch (e) {
    print("Lỗi khi thêm danh sách thành viên: $e");
  }
}

  //thanh vien roi nhom 
  // Xóa thành viên khỏi phòng chat (rời nhóm)
   Future<void> removeMembersToChatRoom(String roomId, String idUs) async {
  try {

    List<String> listMemberRemove = [idUs];
    await messDB.collection("ChatRooms").doc(roomId).update({
      "users": FieldValue.arrayRemove(listMemberRemove),
    });

    print("Thêm danh sách thành viên thành công!");
  } catch (e) {
    print("Lỗi khi thêm danh sách thành viên: $e");
  }
}

}
