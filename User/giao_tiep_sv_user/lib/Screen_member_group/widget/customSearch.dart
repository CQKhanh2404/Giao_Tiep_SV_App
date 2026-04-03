import 'package:flutter/material.dart';

class Customsearch extends StatelessWidget {
  final ValueChanged<String>? onTap;

  Customsearch({super.key, this.onTap});

    TextEditingController controller_search = TextEditingController();

  

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 25,),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.black),
        ),
        child: Row(
          children: [
            Expanded(child: TextField(
          controller: controller_search,
          // onChanged: (value) => onChanged?.call(value),
          decoration: InputDecoration(
            hint: Text(
              "Tìm kiếm user",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.withOpacity(0.7),
              ),
            ),

            border: InputBorder.none,

            // suffixIcon: Icon(Icons.search), //icon ben phai
          ),
        ),
        ),
        IconButton(onPressed: () {
          onTap?.call(controller_search.text);
          print(controller_search.text);
        }, icon: Icon(Icons.search))
          ],
        )
      ),
    );
  }
}
