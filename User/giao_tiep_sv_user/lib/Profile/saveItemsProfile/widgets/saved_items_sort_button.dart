import 'package:flutter/material.dart';

class SavedItemsSortButton extends StatelessWidget {
  final bool sortDescending;
  final VoidCallback onToggle;

  const SavedItemsSortButton({
    Key? key,
    required this.sortDescending,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: OutlinedButton.icon(
          onPressed: onToggle,
          icon: Icon(
            sortDescending ? Icons.trending_up : Icons.trending_down,
            size: 22,
          ),
          label: Text(
            sortDescending ? "Mới nhất" : "Cũ nhất",
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: sortDescending
                ? Colors.deepPurple
                : Colors.amber[800],
            side: BorderSide(
              width: 1.5,
              color: sortDescending ? Colors.deepPurple : Colors.amber[800]!,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
    );
  }
}
