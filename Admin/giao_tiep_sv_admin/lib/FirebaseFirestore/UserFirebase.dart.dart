import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_admin/Data/Users.dart';

/// Service tương tác với Firestore collection "Users"
class FirestoreServiceUser{
  final FirebaseFirestore dbUser = FirebaseFirestore.instance;

  /// Lắng nghe danh sách tất cả người dùng theo thời gian thực (real-time stream)
  Stream<List<Users>> streamBuilder(){
    return dbUser.collection("Users").snapshots().map((event) {
      return event.docs.map((e) {
        final mapData = e.data();
        print("lay danh sach user thanh cong");
        return Users(
        id_user: e.id,
        email: mapData["email"] ?? "",
        // pass: mapData["pass"] ?? "",
        fullname: mapData["fullname"] ?? "",
        url_avt: mapData["avt"] ?? "",
        role: mapData["role"] ?? 0,
        faculty_id: mapData["faculty_id"] ?? "",
      );
      },).toList();
      
    },);
  }
}