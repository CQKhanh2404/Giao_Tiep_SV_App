import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_user/Data/global_state.dart';

class ReportDialog extends StatefulWidget {
  final String postId;
  final String postTitle;
  final String recipientUserId;

  const ReportDialog({
    super.key,
    required this.postId,
    required this.postTitle,
    required this.recipientUserId,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submitReport() async {
    if (_formKey.currentState!.validate()) {
      final reportTitle = _titleController.text;
      final reportContent = _contentController.text;

      final currentUserId = GlobalState.currentUserId;

      if (currentUserId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lỗi: Không tìm thấy ID người dùng.")),
        );
        return;
      }

      final reportData = {
        'title': reportTitle,
        'content': reportContent,
        'type_notify': 0,
        'id_post': widget.postId,
        'id_user': currentUserId,
        'user_recipient_id': widget.recipientUserId,
        'created_at': FieldValue.serverTimestamp(),
        'id_status': 0,
      };

      try {
        await FirebaseFirestore.instance
            .collection('Notifycations')
            .add(reportData);

        Navigator.of(context).pop(true);
      } catch (e) {
        print("Lỗi khi gửi báo cáo lên Firestore: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lỗi hệ thống: Không thể gửi báo cáo.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Báo cáo Bài viết"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Bài viết: ${widget.postTitle}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Divider(),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Tiêu đề Báo cáo",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tiêu đề báo cáo.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: "Nội dung/Lý do báo cáo",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng mô tả lý do báo cáo.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Hủy"),
        ),
        ElevatedButton.icon(
          onPressed: _submitReport,
          icon: const Icon(Icons.send),
          label: const Text("Gửi Báo cáo"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
