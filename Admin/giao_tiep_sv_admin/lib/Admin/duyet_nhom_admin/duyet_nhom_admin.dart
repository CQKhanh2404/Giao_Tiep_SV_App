import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_admin/Admin/duyet_nhom_admin/model/duyet_nhom_model.dart';
import 'package:giao_tiep_sv_admin/Admin/duyet_nhom_admin/widget/groups_card.dart';

class DuyetNhomAdminScreen extends StatefulWidget {
  @override
  _DuyetNhomAdminScreenState createState() => _DuyetNhomAdminScreenState();
}

class _DuyetNhomAdminScreenState extends State<DuyetNhomAdminScreen> {
  List<DuyetNhomAdminModel> groups = [];
  StreamSubscription<QuerySnapshot>? _groupSubscription;

  GroupFilterType _currentFilter = GroupFilterType.all;

  // true = mới nhất trước, false = cũ nhất trước
  bool _sortDescending = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  void _loadGroups() {
    _groupSubscription?.cancel();

    Query query = FirebaseFirestore.instance.collection('Groups');

    // Sắp xếp ngay từ Firestore để tối ưu
    query = query.orderBy('created_at', descending: _sortDescending);

    _groupSubscription = query.snapshots().listen(
      (snapshot) {
        final List<DuyetNhomAdminModel> loadedGroups = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return DuyetNhomAdminModel.fromMap(data);
        }).toList();

        if (mounted) {
          setState(() {
            groups = loadedGroups;
          });
        }
      },
      onError: (error) {
        print('Lỗi: $error');
        if (mounted) _showSnackBar('Lỗi kết nối mạng');
      },
    );
  }

  void _toggleSort() {
    setState(() {
      _sortDescending = !_sortDescending;
    });
    _loadGroups(); // Tải lại theo thứ tự mới
  }

  @override
  void dispose() {
    _groupSubscription?.cancel();
    super.dispose();
  }

  void _duyetNhom(String groupId, String groupName) {
    FirebaseFirestore.instance
        .collection('Groups')
        .doc(groupId)
        .update({'id_status': 1})
        .then((_) {
          _showSnackBar('Đã duyệt nhóm "$groupName"');
        })
        .catchError((e) => _showSnackBar('Lỗi: $e'));
  }

  void _tuChoiNhom(String groupId, String groupName) {
    FirebaseFirestore.instance
        .collection('Groups')
        .doc(groupId)
        .update({'id_status': 2})
        .then((_) {
          _showSnackBar('Đã từ chối nhóm "$groupName"');
        })
        .catchError((e) => _showSnackBar('Lỗi: $e'));
  }

  void _showSnackBar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Chỉ lọc trạng thái + sắp xếp thời gian
  List<DuyetNhomAdminModel> get filteredGroups {
    var result = groups;

    // Lọc trạng thái
    switch (_currentFilter) {
      case GroupFilterType.pending:
        result = result.where((g) => g.status == GroupStatus.pending).toList();
        break;
      case GroupFilterType.approved:
        result = result.where((g) => g.status == GroupStatus.approved).toList();
        break;
      case GroupFilterType.rejected:
        result = result.where((g) => g.status == GroupStatus.rejected).toList();
        break;
      case GroupFilterType.all:
        break;
    }

    // Sắp xếp lại cho chắc (dù Firestore đã orderBy)
    result.sort((a, b) {
      if (a.createdAt == null) return 1;
      if (b.createdAt == null) return -1;
      return _sortDescending
          ? b.createdAt!.compareTo(a.createdAt!)
          : a.createdAt!.compareTo(b.createdAt!);
    });

    return result;
  }

  int get pendingCount =>
      groups.where((g) => g.status == GroupStatus.pending).length;
  int get approvedCount =>
      groups.where((g) => g.status == GroupStatus.approved).length;
  int get rejectedCount =>
      groups.where((g) => g.status == GroupStatus.rejected).length;

  @override
  Widget build(BuildContext context) {
    final list = filteredGroups;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Duyệt nhóm',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      // lọc
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 170,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: DropdownButton<GroupFilterType>(
                                value: _currentFilter,
                                onChanged: (v) =>
                                    setState(() => _currentFilter = v!),
                                isExpanded: true,
                                underline: SizedBox(),
                                icon: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.grey[700],
                                ),

                                items: [
                                  DropdownMenuItem(
                                    value: GroupFilterType.all,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.filter_list,
                                          size: 18,
                                          color: Colors.black54,
                                        ),
                                        SizedBox(width: 6),
                                        Text('Tất cả (${groups.length})'),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: GroupFilterType.pending,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.hourglass_empty_outlined,
                                          size: 18,
                                          color: Colors.orange,
                                        ),
                                        SizedBox(width: 6),
                                        Text('Chờ duyệt ($pendingCount)'),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: GroupFilterType.approved,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline,
                                          size: 18,
                                          color: Colors.green,
                                        ),
                                        SizedBox(width: 6),
                                        Text('Đã duyệt ($approvedCount)'),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: GroupFilterType.rejected,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.cancel_outlined,
                                          size: 18,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 6),
                                        Text('Từ chối ($rejectedCount)'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // nút sắp xếp
                    SizedBox(width: 30),
                    OutlinedButton.icon(
                      onPressed: _toggleSort,
                      icon: Icon(
                        _sortDescending
                            ? Icons.trending_up
                            : Icons.trending_down,
                        size: 20,
                      ),
                      label: Text(
                        _sortDescending ? "Mới nhất" : "Cũ nhất",
                        style: TextStyle(fontSize: 14),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _sortDescending
                            ? Colors.deepPurple
                            : const Color.fromARGB(255, 204, 211, 7),
                        side: BorderSide(
                          color: _sortDescending
                              ? Colors.deepPurple
                              : const Color.fromARGB(255, 204, 211, 7),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
                // Dòng hiển thị tổng số nhóm và nút sắp xếp
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hiển thị ${list.length} nhóm',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Danh sách
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.group_outlined,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 20),
                        Text(
                          groups.isEmpty
                              ? 'Chưa có nhóm nào được tạo'
                              : 'Không có nhóm nào phù hợp',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final group = list[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: GroupCard(
                          group: group,
                          onApprove: () => _duyetNhom(group.id, group.name),
                          onReject: () => _tuChoiNhom(group.id, group.name),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

enum GroupFilterType { all, pending, approved, rejected }
