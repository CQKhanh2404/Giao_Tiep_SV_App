/// Model dữ liệu người dùng trong hệ thống
class Users {
  final String id_user;   // Mã định danh người dùng (document ID)
  final String email;
  // final String pass;
  final String fullname;
  final String? phone;
  final String? address;
  final String url_avt;   // URL ảnh đại diện
  final int role;         // Vai trò: 0 = sinh viên, 1 = admin
  final String faculty_id; // Mã khoa

  Users({required this.id_user, required this.email, required this.fullname,  this.phone,  this.address, required this.url_avt, required this.role, required this.faculty_id});


}