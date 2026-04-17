/// Model dữ liệu khoa/ngành học trong trường
class Faculty {
  final String id;             // Mã khoa (VD: "TT", "KT")
  final String name_faculty;   // Tên đầy đủ của khoa

  Faculty({required this.id, required this.name_faculty});
}