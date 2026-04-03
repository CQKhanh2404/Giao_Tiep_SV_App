// File: user_card.dart (ĐÃ SỬA LỖI BOX CONSTRAINTS VÀ BO GÓC)

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback? onTap;
  final Function(Map<String, dynamic> user)? onMessagePressed;

  const UserCard({
    super.key,
    required this.user,
    this.onTap,
    this.onMessagePressed,
  });

  @override
  Widget build(BuildContext context) {
    const double borderRadiusValue = 8.0;

    // Quan trọng: Sử dụng ClipRRect để đảm bảo Slidable và Card bo góc
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadiusValue),
      child: Slidable(
        key: ValueKey(user["id"] ?? UniqueKey()),

        // Loại bỏ padding xung quanh SlidableAction, thay vào đó tạo margin
        // ở Card hoặc sử dụng SizedBox để cách ly các mục ListView.

        // Hành động bên phải (vuốt sang trái)
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          // Đặt extentRatio nhỏ (ví dụ 0.25)
          extentRatio: 0.25,

          children: [
            SlidableAction(
              onPressed: (context) {
                if (onMessagePressed != null) {
                  onMessagePressed!(user);
                }
              },
              backgroundColor: const Color(0xFF7BC043),
              foregroundColor: Colors.white,
              icon: Icons.message,
              label: 'Nhắn tin',
              // Border Radius chỉ nên được thiết lập nếu Slidable không nằm trong ClipRRect
            ),
          ],
        ),

        // Nội dung chính của Slidable (ListTile được bọc trong Card)
        // **LƯU Ý: ĐÃ XÓA MARGIN DỌC KHỎI CARD để tránh xung đột với Slidable.**
        // Thay vào đó, chúng ta sẽ thêm một khoảng trống (padding) bên ngoài UserCard.
        child: Card(
          // Đã loại bỏ margin (hoặc đặt margin: EdgeInsets.zero)
          margin: EdgeInsets.zero,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusValue),
          ),
          child: ListTile(
            onTap: onTap,
            leading: CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(
                user["avatar"] ?? "https://default-avatar-url.jpg",
              ),
            ),
            title: Text(
              user["fullname"] ?? "Ẩn danh",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              user["email"] ?? user["faculty_id"] ?? "Không rõ thông tin",
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
