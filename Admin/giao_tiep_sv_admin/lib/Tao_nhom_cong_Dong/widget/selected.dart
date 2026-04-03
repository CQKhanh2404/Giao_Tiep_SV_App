import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_admin/Data/Users.dart';
import 'package:giao_tiep_sv_admin/Data/faculty.dart';

class CustomSlected extends StatefulWidget {
  final int Throws;
  final List<Users> listmember;
  final List<Faculty> listFaculty;
  const CustomSlected({
    super.key,
    required this.listmember,
    required this.listFaculty, required this.Throws,
  });

  @override
  State<CustomSlected> createState() => _CustomSlectedState();
}

class _CustomSlectedState extends State<CustomSlected> {
  @override
  Widget build(BuildContext context) {
    final faculties = widget.listFaculty;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        
        children: [
        Text(
          (widget.Throws==1)?"Người được ủy quyền: ":"Người được gửi: ",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        listmemberselec(),

        SizedBox(height: 15,),
         Text(
          "Khoa được chọn:",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        listfacultySelected(faculties)
        
        
        ])
      ,
    );
  }

  Widget listmemberselec() {
    return Wrap(
      spacing: 8,
      runSpacing: 5,
      children: [
        SizedBox(width: 4),
        ...widget.listmember.map((e) {
          return Text("${e.fullname} - ${e.email}, ", style: TextStyle(fontSize: 14));
        }).toList(),
      ],
    );

  }

  Widget listfacultySelected(List<Faculty> faculties) {
    return Wrap(
      spacing: 8,
      runSpacing: 5,
      children: [
        SizedBox(width: 4),
        ...faculties.map((e) {
          return Text("${e.name_faculty}, ", style: TextStyle(fontSize: 14));
        }).toList(),
      ],
    );
  }

  
}
