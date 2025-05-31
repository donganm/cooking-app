import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateRecipeScreenWithDraft extends StatefulWidget {
  final String? draftId; // Có thể null nếu tạo mới, không chỉnh sửa nháp
  final String? initialTitle;
  final String? initialDescription;

  CreateRecipeScreenWithDraft({
    this.draftId,
    this.initialTitle,
    this.initialDescription,
  });

  @override
  _CreateRecipeScreenWithDraftState createState() =>
      _CreateRecipeScreenWithDraftState();
}

class _CreateRecipeScreenWithDraftState
    extends State<CreateRecipeScreenWithDraft> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;

  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    if (widget.initialTitle != null) {
      _titleController.text = widget.initialTitle!;
    }
    if (widget.initialDescription != null) {
      _descController.text = widget.initialDescription!;
    }
  }

  Future<void> _submitRecipe() async {
    final title = _titleController.text.trim();
    final description = _descController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng nhập đầy đủ tiêu đề và mô tả.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final recipeData = {
      'title': title,
      'description': description,
      'imageUrl': '',
      'createdBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'likes': [],
      'commentsCount': 0,
    };

    try {
      // Lưu vào community_recipes
      final communityRef = await FirebaseFirestore.instance
          .collection('community_recipes')
          .add(recipeData);

      // Lưu vào my_recipes/<uid>/items
      await FirebaseFirestore.instance
          .collection('my_recipes')
          .doc(uid)
          .collection('items')
          .doc(communityRef.id)
          .set(recipeData);

      // Nếu bài viết này được tạo từ nháp, xóa nháp đi
      if (widget.draftId != null) {
        await FirebaseFirestore.instance
            .collection('drafts')
            .doc(uid)
            .collection('items')
            .doc(widget.draftId)
            .delete();
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Đăng bài thành công')));

      Navigator.pop(context); // Quay lại màn hình trước
    } catch (e) {
      print('Lỗi đăng bài: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Đã xảy ra lỗi khi đăng bài.")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveDraft() async {
    final title = _titleController.text.trim();
    final description = _descController.text.trim();

    if (title.isEmpty && description.isEmpty) {
      // Không lưu draft nếu cả 2 đều trống
      return;
    }

    setState(() => _isLoading = true);

    final draftData = {
      'title': title,
      'description': description,
      'savedAt': FieldValue.serverTimestamp(),
    };

    try {
      final draftsCollection = FirebaseFirestore.instance
          .collection('drafts')
          .doc(uid)
          .collection('items');

      if (widget.draftId != null) {
        // Cập nhật draft hiện tại
        await draftsCollection.doc(widget.draftId).set(draftData);
      } else {
        // Tạo mới draft
        await draftsCollection.add(draftData);
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Đã lưu nháp')));
    } catch (e) {
      print('Lỗi lưu nháp: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi lưu nháp')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _onWillPop() async {
    // Khi bấm nút back (hoặc hủy), hỏi có muốn lưu nháp không
    if (_titleController.text.trim().isEmpty &&
        _descController.text.trim().isEmpty) {
      // Nếu cả 2 trống thì không lưu, thoát luôn
      return true;
    }

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Lưu nháp'),
            content: Text('Bạn có muốn lưu món này làm nháp không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Không'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Có'),
              ),
            ],
          ),
    );

    if (result == true) {
      await _saveDraft();
      return true; // thoát sau khi lưu
    } else {
      return true; // thoát mà không lưu
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.draftId == null ? 'Tạo món mới' : 'Chỉnh sửa nháp',
          ),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : _submitRecipe,
              child: Text(
                'Đăng bài',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Tiêu đề'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _descController,
                decoration: InputDecoration(labelText: 'Mô tả'),
                maxLines: 5,
              ),
              SizedBox(height: 20),
              if (_isLoading) CircularProgressIndicator(),
              if (!_isLoading)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final wantSave = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: Text('Lưu nháp'),
                                content: Text(
                                  'Bạn có muốn lưu món này làm nháp không?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(false),
                                    child: Text('Không'),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(true),
                                    child: Text('Có'),
                                  ),
                                ],
                              ),
                        );
                        if (wantSave == true) {
                          await _saveDraft();
                          Navigator.pop(context);
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Hủy'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _submitRecipe,
                      child: Text('Đăng bài'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
