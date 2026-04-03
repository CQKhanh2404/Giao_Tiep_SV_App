// member_approval_widget.dart
import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/duyet_Nguoi_Dung/models/MemberApprovalModel.dart';

class MemberApprovalWidget extends StatelessWidget {
  final MemberApprovalModel user;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const MemberApprovalWidget({
    Key? key,
    required this.user,
    required this.onApprove,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: user.avatar.isNotEmpty
                      ? NetworkImage(user.avatar)
                      : NetworkImage(
                          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user.fullName)}&background=0D8ABC&color=fff&bold=true',
                        ),
                ),

                const SizedBox(width: 14),

                // Nội dung
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Hàng tên + trạng thái + menu
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              user.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16.5,
                                color: Colors.black87,
                              ),
                            ),
                          ),

                          if (_buildStatusBadge(user.status) != null) ...[
                            const SizedBox(width: 8),
                            _buildStatusBadge(user.status)!,
                          ],

                          if (user.status == 'rejected') ...[
                            const SizedBox(width: 4),
                            PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.more_vert,
                                size: 20,
                                color: Colors.grey[700],
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              onSelected: (_) => onApprove(),
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: 'reapprove',
                                  height: 42,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline,
                                        color: Colors.green,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Duyệt lại',
                                        style: TextStyle(color: Colors.green),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Khoa
                      Row(
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 16,
                            color: Colors.blueGrey[600],
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Khoa: ${user.faculty ?? 'Chưa rõ'}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Ngày tham gia
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 15,
                            color: Colors.blueGrey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Tham gia: ${_formatDate(user.joinedAt)}",
                            style: TextStyle(
                              fontSize: 13.5,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),

                      // Action buttons
                      if (user.status == 'pending') ...[
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(
                              'Từ chối',
                              const Color(0xFFE53935),
                              onReject,
                            ),
                            _buildActionButton(
                              'Duyệt',
                              const Color(0xFF1E8E3E),
                              onApprove,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    switch (status) {
      case 'approved':
        color = Colors.green;
        text = 'Đã duyệt';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Từ chối';
        break;
      default:
        color = Colors.orange;
        text = 'Chờ duyệt';
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
