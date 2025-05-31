import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Giả sử bạn có màn hình chỉnh sửa nháp (hoặc đăng bài) để chuyển sang chỉnh sửa
// Nếu không có, bạn có thể sửa lại tùy theo project.
import 'create_recipe_screen_with_draft.dart'; // hoặc file chỉnh sửa recipe

class DraftsTab extends StatefulWidget {
  @override
  _DraftsTabState createState() => _DraftsTabState();
}

class _DraftsTabState extends State<DraftsTab> {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _deleteDraft(String draftId) async {
    try {
      await FirebaseFirestore.instance
          .collection('drafts')
          .doc(uid)
          .collection('items')
          .doc(draftId)
          .delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Đã xóa nháp')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi xóa nháp')));
    }
  }

  void _editDraft(DocumentSnapshot draftDoc) {
    // Bạn có thể sửa lại màn hình CreateRecipeScreen để nhận dữ liệu nháp và chỉnh sửa.
    // Ở đây ví dụ truyền dữ liệu nháp sang màn hình chỉnh sửa:
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CreateRecipeScreenWithDraft(
              draftId: draftDoc.id,
              initialTitle: draftDoc['title'],
              initialDescription: draftDoc['description'],
            ),
      ),
    ).then((value) {
      // Refresh lại khi quay về (nếu cần)
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final draftsRef = FirebaseFirestore.instance
        .collection('drafts')
        .doc(uid)
        .collection('items')
        .orderBy('savedAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: Text('Món nháp')),
      body: StreamBuilder<QuerySnapshot>(
        stream: draftsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải dữ liệu'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(child: Text('Chưa có món nháp nào'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final draft = docs[index];
              final title = draft['title'] ?? 'Không có tiêu đề';
              final description = draft['description'] ?? '';

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  title: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: Text('Xác nhận'),
                              content: Text('Bạn có chắc muốn xóa nháp này?'),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(false),
                                  child: Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(true),
                                  child: Text('Xóa'),
                                ),
                              ],
                            ),
                      );
                      if (confirm == true) {
                        _deleteDraft(draft.id);
                      }
                    },
                  ),
                  onTap: () => _editDraft(draft),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
