import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'create_recipe_screen_with_draft.dart';

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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CreateRecipeScreenWithDraft(
              draftId: draftDoc.id,
              initialTitle: draftDoc['title'],
              initialDescription: draftDoc['description'],
              initialImageUrl: draftDoc['imageUrl'] ?? '',
            ),
      ),
    ).then((value) {
      setState(() {}); // Cập nhật lại khi quay về
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
              final imageUrl = draft['imageUrl'] ?? '';

              Widget leadingImage;

              if (imageUrl.startsWith('http')) {
                leadingImage = Image.network(
                  imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(Icons.broken_image),
                );
              } else if (imageUrl.startsWith('assets/')) {
                leadingImage = Image.asset(
                  imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                );
              } else {
                leadingImage = Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: Icon(Icons.image),
                );
              }

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: leadingImage,
                  ),
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
