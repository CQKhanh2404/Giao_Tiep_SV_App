import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Data/Users.dart';

class Headerwidget extends StatelessWidget {
  final Users myUs;
  final double width;
  final Widget? chucnang;
  const Headerwidget({super.key, this.chucnang, required this.width, required this.myUs});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: double.infinity,
      child: Center(
        child: createHeader(),
      ),
    );
  }

  Widget createHeader(){
    String idUS = myUs.email.split('@')[0];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          children: [
            //custom avatar and info
            ClipOval(
              child: Image.network(myUs.url_avt,fit: BoxFit.fill,width: 45,height: 45,),
            ),

            SizedBox(width: 15,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${myUs.fullname}",style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),),

                Text("${idUS}",style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),),
              ],
            )
          ],
        ),

        if(chucnang!=null) chucnang!,
        
      ],

      
    );
  }
}