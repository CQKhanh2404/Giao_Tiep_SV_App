import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_admin/Data/faculty.dart';
import 'package:giao_tiep_sv_admin/FirebaseFirestore/FacultyFirebase.dart';
import 'package:giao_tiep_sv_admin/FirebaseFirestore/UserFirebase.dart.dart';

class CustomAllKhoa extends StatefulWidget {
  final ValueChanged<List<Faculty>>? listKhoa_out;

  const CustomAllKhoa({super.key, this.listKhoa_out});

  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => const CustomAllKhoa(),
    );
  }

  @override
  State<CustomAllKhoa> createState() => CustomAllKhoaState();
}

class CustomAllKhoaState extends State<CustomAllKhoa> {
  final FireStoreServiceFaculty firebaseServiceFaculty = FireStoreServiceFaculty();
  List<Faculty> listSelected = [];
  List<Faculty> dsKhoa = [];
  bool isLoading = true; // ✅ Biến trạng thái loading
  bool isSelectedCafulty = false;
  Map<String, bool> Selected = {};

  @override
  void initState() {
    super.initState();
    fetchFaculty(); // Gọi hàm load dữ liệu
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Chọn khoa:",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // ✅ Hiển thị vòng load hoặc danh sách
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : dsKhoa.isEmpty
                  ? const Center(
                      child: Text(
                        "Không có dữ liệu khoa.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  :
                    //danh sach va truyen check box cua cac user
                    ListView.builder(
                      itemCount: dsKhoa.length,
                      itemBuilder: (context, index) {
                        var valueItem = dsKhoa[index];
                        final nameKhoa = valueItem.name_faculty;
                        final idKhoa = valueItem.id;
                        return customItem(idKhoa, nameKhoa);
                      },
                    ),
            ),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Quay lại",
                    style: TextStyle(color: Colors.black, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    for (var item in dsKhoa) {
                      if (Selected[item.id] == true) {
                        listSelected.add(item);
                      }
                    }
                    // print(listSelected.length);
                    widget.listKhoa_out?.call(listSelected);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Xác nhận",
                    style: TextStyle(color: Colors.black, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget customItem(String idKhoa, String nameKhoa) {
    return InkWell(
      onTap: () {
        setState(() {
          Selected[idKhoa] = !Selected[idKhoa]! ?? false;
        });
      },
      child: Row(
        children: [
          Checkbox(
            activeColor: Colors.blue,
            value: Selected[idKhoa],
            onChanged: (value) {
              setState(() {
                Selected[idKhoa] = value! ?? false;
                print(value);
              });
            },
          ),
          const SizedBox(width: 8),
          Text(
            nameKhoa,
            style: const TextStyle(fontSize: 13, color: Colors.black),
          ),
        ],
      ),
    );
  }

  // lấy dl từ fireabase khoa
  Future<void> fetchFaculty() async {
    try {
      setState(() => isLoading = true);

      firebaseServiceFaculty.streamBuilder().listen(
        (data) {
         
        setState(() {
          dsKhoa = data;

          // Nếu chưa có key thì thêm, tránh reset chọn cũ
          for (var item in dsKhoa) {
            Selected.putIfAbsent(item.id, () => false);
          }
          isLoading = false;
        });
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      debugPrint(" Lỗi khi load Faculty: $e");
    }
  }
}
