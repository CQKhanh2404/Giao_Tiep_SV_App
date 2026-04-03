import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_admin/Admin/duyet_nhom_admin/model/duyet_nhom_model.dart';

class GroupCard extends StatelessWidget {
  final DuyetNhomAdminModel group;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const GroupCard({
    Key? key,
    required this.group,
    required this.onApprove,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
        border: Border.all(color: _getStatusColor(group.status), width: 2),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin nhóm
            Row(
              children: [
                // Avatar nhóm
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.grey[200],
                  ),
                  child: group.avt.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.network(
                            group.avt,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.group, color: Colors.grey[600]);
                            },
                          ),
                        )
                      : Icon(Icons.group, color: Colors.grey[600]),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      SizedBox(height: 4),

                      // Người tạo
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 16,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Người tạo: ${group.creator}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 2),
                      // Khoa
                      Row(
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 16,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Khoa: ${group.facultyName}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 2),

                      // Thời gian tạo
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Thời gian tạo: ${group.createdAtFormatted}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(group.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _getStatusColor(group.status)),
                  ),
                  child: Text(
                    _getStatusText(group.status),
                    style: TextStyle(
                      color: _getStatusColor(group.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // Mô tả nhóm
            if (group.description.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mô tả:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    group.description,
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                  SizedBox(height: 8),
                ],
              ),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: Icons.check_circle,
                  label: 'Duyệt',
                  color: Colors.green,
                  onTap: onApprove,
                  isEnabled: group.status == GroupStatus.pending,
                ),
                _buildActionButton(
                  icon: Icons.cancel,
                  label: 'Từ chối',
                  color: Colors.red,
                  onTap: onReject,
                  isEnabled: group.status == GroupStatus.pending,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isEnabled,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Column(
        children: [
          Container(
            width: 100,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isEnabled
                  ? color.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              shape: BoxShape.rectangle,
              border: Border.all(color: isEnabled ? color : Colors.grey),
            ),
            child: Icon(icon, color: isEnabled ? color : Colors.grey, size: 24),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isEnabled ? color : Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(GroupStatus status) {
    switch (status) {
      case GroupStatus.pending:
        return Colors.orange;
      case GroupStatus.approved:
        return Colors.green;
      case GroupStatus.rejected:
        return Colors.red;
    }
  }

  String _getStatusText(GroupStatus status) {
    switch (status) {
      case GroupStatus.pending:
        return 'Chờ duyệt';
      case GroupStatus.approved:
        return 'Đã duyệt';
      case GroupStatus.rejected:
        return 'Từ chối';
    }
  }

  String _formatMembers(List<String> members) {
    if (members.isEmpty) return 'Không có thành viên';
    if (members.length == 1) return members.first;
    return '${members.first} và ${members.length - 1} người khác';
  }
}
