import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_user/Data/global_state.dart';
// Đảm bảo đường dẫn đến file GlobalState.dart là đúng

class MygroupService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Stream<List<DocumentSnapshot>> getMyGroupsStream() {
    return _firestore
        .collection('Groups')
        // Lọc trên Server: Chỉ lấy các nhóm có status_id = 1
        .where('id_status', isEqualTo: 1)
        .snapshots()
        .map((snapshot) {
          // Lọc trên Client: Kiểm tra trường 'created_by' có chứa ID người dùng
          return snapshot.docs.where((doc) {
            // Lấy dữ liệu document
            final data = doc.data();

            // Kiểm tra xem trường 'created_by' có tồn tại hay không
            if (!data.containsKey('created_by')) {
              return false;
            }

            final createdByRaw = data['created_by'];

            // Logic phòng thủ: Kiểm tra xem dữ liệu có phải là Map không
            // Nếu là String (dữ liệu lỗi), nó sẽ bị bỏ qua thay vì gây crash ứng dụng.
            if (createdByRaw is Map<String, dynamic>) {
              // Nếu đúng là Map, kiểm tra xem ID người dùng hiện tại có là Key không
              return createdByRaw.containsKey(GlobalState.currentUserId);
            }

            // Bỏ qua các document có dữ liệu không hợp lệ (String, null, v.v.)
            return false;
          }).toList();
        });
  }
}
