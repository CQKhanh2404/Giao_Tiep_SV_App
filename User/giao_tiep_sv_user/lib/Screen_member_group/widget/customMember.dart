import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Screen_member_group/data/DataPicked.dart';

class CustommemberWidget extends StatefulWidget {
  final String id;
  final String url;
  final String fullname;
  final ValueChanged<Datapicked?>? ontap;
  const CustommemberWidget({
    super.key,
    required this.id,
    required this.url,
    required this.fullname,
    this.ontap,
  });

  @override
  State<CustommemberWidget> createState() => _CustommemberWidgetState();
}

class _CustommemberWidgetState extends State<CustommemberWidget> {
  bool ischecked = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          ischecked = !ischecked;
          widget.ontap?.call(Datapicked(idUser: widget.id, picked: ischecked));
        });
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
                    widget.url,
                    fit: BoxFit.fill,
                    height: 40,
                    width: 40,
                  ),
                ),
                SizedBox(width: 15),
                //name
                Text(
                  "${widget.fullname}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            Checkbox(
              value: ischecked,
              activeColor: Colors.blue,
              onChanged: (value) {
                setState(() {
                  ischecked = value!;
                            widget.ontap?.call(Datapicked(idUser: widget.id, picked: ischecked));
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
