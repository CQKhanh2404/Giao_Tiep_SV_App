import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_admin/Data/Users.dart';


class CustommemberUyQuyen extends StatefulWidget {
  final Users user;
  final ValueChanged<bool>? ontap;
  final bool selectedMember;
  const CustommemberUyQuyen({
    super.key,
    this.ontap, required this.user, required this.selectedMember,
  });

  @override
  State<CustommemberUyQuyen> createState() => _CustommemberUyQuyen();
}

class _CustommemberUyQuyen extends State<CustommemberUyQuyen> {
  bool ischecked = false;
  //trang thai selected cac member


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
       widget.ontap?.call(!widget.selectedMember);
      },
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                //create img avatar
                ClipOval(
                  child: Image.network(
                    widget.user.url_avt,
                    fit: BoxFit.fill,
                    height: 40,
                    width: 40,
                  ),
                ),
                SizedBox(width: 15),
                //name
                Text(
                  widget.user.fullname,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            Checkbox(
              value: widget.selectedMember,
              activeColor: Colors.blue,
              onChanged: (value) {
                setState(() {
                  ischecked = value!;
                  widget.ontap?.call(value);

                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
