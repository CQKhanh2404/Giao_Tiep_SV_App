// saved_item_card_widget.dart
import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Widget/post_image_gallery.dart';
import '../models/saved_item_model.dart';
import 'more_options_button_widget.dart';

class SavedItemCardWidget extends StatefulWidget {
  final SavedItemModel item;
  final Function(String) onDelete;
  final int index;

  const SavedItemCardWidget({
    super.key,
    required this.item,
    required this.onDelete,
    required this.index,
  });

  @override
  State<SavedItemCardWidget> createState() => _SavedItemCardWidgetState();
}

class _SavedItemCardWidgetState extends State<SavedItemCardWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isExpanded ? Colors.deepPurpleAccent : Colors.grey.shade300,
          width: _isExpanded ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_isExpanded ? 0.2 : 0.08),
            blurRadius: _isExpanded ? 16 : 8,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildThumbnail(),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.blueAccent,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Nhóm: ${widget.item.groupName}",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.item.title,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Đã lưu: ${_formatDate(widget.item.savedAt)}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        MoreOptionsButtonWidget(
                          itemTitle: widget.item.title,
                          postId: widget.item.id,
                          onDelete: widget.onDelete,
                        ),
                        const SizedBox(height: 30),
                        AnimatedRotation(
                          turns: _isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 100),
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Phần mở rộng
              if (_isExpanded)
                Container(
                  constraints: const BoxConstraints(
                    maxHeight: 600, // Tối đa 600px, quá thì cuộn
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDFDFD),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Ảnh lớn (hỗ trợ rất nhiều ảnh)
                        if (widget.item.images.isNotEmpty) ...[
                          _buildExpandedImages(),
                          const SizedBox(height: 16),
                        ],

                        // Nội dung bài viết
                        Text(
                          widget.item.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Thời gian lưu chi tiết
                        Row(
                          children: [
                            const Icon(
                              Icons.bookmark_added,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Đã lưu: ${_formatFullDate(widget.item.savedAt)}",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Divider(color: Colors.grey[300], height: 1),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedImages() {
    return SizedBox(
      height: 300,
      child: PostImageGallery(imageUrls: widget.item.images),
    );
  }

  // hình thu nhỏ
  Widget _buildThumbnail() {
    if (widget.item.images.isEmpty) {
      return _placeholder(90, 90);
    }
    // nếu có 1 ảnh
    if (widget.item.images.length == 1) {
      return Image.network(
        widget.item.images[0],
        width: 90,
        height: 90,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(90, 90),
      );
    }
    // nếu > 2 ảnh hiển thị thêm ảnh nhỏ
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[300],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              widget.item.images[0],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(90, 90),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.item.images[1],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, size: 30),
                ),
              ),
            ),
          ),
          if (widget.item.images.length >= 2)
            Positioned(
              right: 4,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "+${widget.item.images.length - 1}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Placeholder khi không có ảnh
  Widget _placeholder(double w, double h) {
    return Container(
      width: w,
      height: h,
      color: Colors.grey[300],
      child: Icon(Icons.image, color: Colors.grey[600], size: 36),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Không rõ";
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return "Hôm nay";
    if (diff.inDays == 1) return "Hôm qua";
    if (diff.inDays < 7) return "${diff.inDays} ngày trước";
    return "${date.day}/${date.month}/${date.year}";
  }

  String _formatFullDate(DateTime? date) {
    if (date == null) return "Không rõ thời gian";
    return "${date.day} tháng ${date.month}, ${date.year} lúc ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}
