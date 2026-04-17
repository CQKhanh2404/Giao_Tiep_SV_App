import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_admin/Data/faculty.dart';

/// Service tương tác với Firestore collection "Faculty"
class FireStoreServiceFaculty {
  final FirebaseFirestore dbFaculty = FirebaseFirestore.instance;

  /// Lắng nghe danh sách khoa theo thời gian thực
  Stream<List<Faculty>> streamBuilder() {
    return dbFaculty.collection("Faculty").snapshots().map((event) {
      return event.docs.map((e) {
        final mapData = e.data();
        return Faculty(id: e["id"], name_faculty: mapData["name"]);
      }).toList();
    });
  }
}
