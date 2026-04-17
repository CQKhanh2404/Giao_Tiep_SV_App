import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_user/Data/Users.dart';

// Service truy xuất thông tin người dùng từ Firestore
class Userservices {
  final FirebaseFirestore userDB = FirebaseFirestore.instance;

  // Lấy thông tin người dùng theo ID
  Future<Users?> getUserForID(String myID) async {
    try {
      final snap = await userDB
          .collection("Users")
          .doc(myID.trim().toUpperCase())
          .get();

      if (!snap.exists) {
        return null;
      }
      // print("my ${Users.fromMap(snap.data()!)}");
      print("lay usser theo id thanh cong");
      return Users.fromMap(snap.data()!);
    } catch (e) {
      print("loi dl: $e");
      return null;
    }
  }

  //load danh sach nguoi dung
  //real time ds User
  // Stream real-time danh sách tất cả sinh viên (role = 0)
  Stream<List<Users>> streamBuilder() {
    return userDB.collection("Users").where("role", isEqualTo: 0).snapshots().map((
      event,
    ) {
      return event.docs.map((e) {
        final mapData = e.data();
        return Users(
          id_user: e.id,
          email: mapData["email"] ?? "",
          // pass: mapData["pass"] ?? "",
          fullname: mapData["fullname"] ?? "",
          url_avt:
              mapData["avt"] ??
              "https://www.homepaylater.vn/static/091138555b138c04878fa60cea715e28/7b48c/tdc_computer_logo_68b779e149.jpg",
          role: mapData["role"] ?? 0,
          faculty_id: mapData["faculty_id"] ?? "",
        );
      }).toList();
    });
  }
}
