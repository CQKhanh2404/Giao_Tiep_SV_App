import 'package:flutter/material.dart';

class CustommemberWidget extends StatefulWidget {
  final String id;
  final String url;
  final String fullname;
  final ValueChanged<bool?>? ontap;
  const CustommemberWidget({super.key, required this.id, required this.url, required this.fullname, this.ontap});

  @override
  State<CustommemberWidget> createState() => _CustommemberWidgetState();
}

class _CustommemberWidgetState extends State<CustommemberWidget> {
  bool ischecked = false;
  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(10)
    ,child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            //create img avatar
        ClipOval(
          child: Image.asset(widget.url,fit: BoxFit.fill,height: 40,width: 40,),
        ),
        SizedBox(width: 15,),
        //name
        Text(widget.fullname,style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold
        ),),
          ],
        ),

        Checkbox(value: ischecked,
        activeColor: Colors.blue,
         onChanged: (value) {
         setState(() {
            ischecked=value!;
          widget.ontap;
         });
        },)

      ],
    ),);
  }
}