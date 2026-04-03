class Users {
  final String id_user;
  final String email;
  // final String pass;
  final String fullname;
  final String? phone;
  final String? address;
  final String url_avt;
  final int role;
  final String faculty_id;

  Users({required this.id_user, required this.email, required this.fullname,  this.phone,  this.address, required this.url_avt, required this.role, required this.faculty_id});


}