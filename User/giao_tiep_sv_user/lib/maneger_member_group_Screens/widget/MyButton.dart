import 'package:flutter/material.dart';

class Mybutton extends StatelessWidget {
  final String url_icon;
  final String nameButton;
  final void Function()? ontap;
  const Mybutton({
    super.key,
    required this.url_icon,
    required this.nameButton,
    this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    return createButton();
  }

  Widget createButton() {
    return InkWell(
      onTap: () {
        ontap?.call();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 25,vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Image.asset(url_icon, fit: BoxFit.cover, width: 25, height: 25),
            SizedBox(width: 8),
            //name button
            Text(nameButton, style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
