import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:giao_tiep_sv_admin/Data/Group.dart';
import 'package:giao_tiep_sv_admin/Data/GroupMember.dart';
import 'package:uuid/uuid.dart';

class Groupsfirebase {
  final FirebaseFirestore groupDb = FirebaseFirestore.instance;
  final imagFireStore = FirebaseStorage.instance;

  //lay hinh anh dua len storage
  Future<String?> uploadImageGroupChat(String namefile, File imageFile) async {
    try {
      final putImage = imagFireStore.ref().child("groups/$namefile");

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

  
  //tao nhom dua len firebase
  Future<void> createGroupAdmin(Group group, Groupmember groupMember) async {
    try {
      await groupDb.collection("Groups").doc(group.id).set(group.tomap());
      String id = Uuid().v4();
      await groupDb.collection("Groups_members").doc(id).set(groupMember.toMap());
      print("tao nhom oke");
    } catch (e) {
      print("tao nhom loi : $e");
      rethrow;
    }
  }
}