import 'package:flutter/material.dart';

class Tabs_Member_Approval_Widget extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const Tabs_Member_Approval_Widget({
    Key? key,
    required this.selectedIndex,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildTab('Bài viết', 0, Icons.article),
        _buildTab('Thành viên', 1, Icons.people),
      ],
    );
  }

  Widget _buildTab(String text, int index, IconData icon) {
    final isSelected = index == selectedIndex;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          padding: EdgeInsets.symmetric(vertical: 12),

          decoration: BoxDecoration(
            color: isSelected
                ? Colors.blue.withOpacity(0.1)
                : Colors.grey.shade200,
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.blue : Colors.grey,
              ),
              SizedBox(width: 6),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.blue : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
