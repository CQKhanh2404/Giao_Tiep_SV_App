import 'package:flutter/material.dart';

class ProfileTextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData icon;
  final bool isReadOnly;

  const ProfileTextFieldWidget({
    super.key,
    required this.controller,
    required this.labelText,
    required this.icon,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          readOnly: isReadOnly,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.blue, size: 40),
            labelText: labelText,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              fontSize: 20,
              color: Colors.black,
            ),
            border: const UnderlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
