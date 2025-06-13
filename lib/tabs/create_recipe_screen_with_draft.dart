import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateRecipeScreenWithDraft extends StatefulWidget {
  final String? draftId;
  final String? initialTitle;
  final String? initialDescription;
  final String? initialImageUrl;

  CreateRecipeScreenWithDraft({
    this.draftId,
    this.initialTitle,
    this.initialDescription,
    this.initialImageUrl,
  });

  @override
  _CreateRecipeScreenWithDraftState createState() =>
      _CreateRecipeScreenWithDraftState();
}

class _CreateRecipeScreenWithDraftState
    extends State<CreateRecipeScreenWithDraft> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _imageUrlController = TextEditingController();
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
    if (widget.initialImageUrl != null) {
      _imageUrlController.text = widget.initialImageUrl!;
    }
  }

  Future<void> _submitRecipe() async {
    final title = _titleController.text.trim();
    final description = _descController.text.trim();
    final imageUrl = _imageUrlController.text.trim();

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
      'imageUrl': imageUrl,
      'createdBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'likes': [],
      'commentsCount': 0,
    };

    try {
      final communityRef = await FirebaseFirestore.instance
          .collection('community_recipes')
          .add(recipeData);

      await FirebaseFirestore.instance
          .collection('my_recipes')
          .doc(uid)
          .collection('items')
          .doc(communityRef.id)
          .set(recipeData);

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
      Navigator.pop(context);
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
    final imageUrl = _imageUrlController.text.trim();

    if (title.isEmpty && description.isEmpty && imageUrl.isEmpty) {
      return;
    }

    setState(() => _isLoading = true);

    final draftData = {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'savedAt': FieldValue.serverTimestamp(),
    };

    try {
      final draftsCollection = FirebaseFirestore.instance
          .collection('drafts')
          .doc(uid)
          .collection('items');

      if (widget.draftId != null) {
        await draftsCollection.doc(widget.draftId).set(draftData);
      } else {
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
    if (_titleController.text.trim().isEmpty &&
        _descController.text.trim().isEmpty &&
        _imageUrlController.text.trim().isEmpty) {
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
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.draftId == null ? 'Tạo món mới' : 'Chỉnh sửa nháp',
            style: TextStyle(fontWeight: FontWeight.bold),
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
          centerTitle: true,
          elevation: 2,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(
                  controller: _titleController,
                  label: 'Tiêu đề',
                  icon: Icons.title,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _descController,
                  label: 'Mô tả',
                  icon: Icons.description,
                  maxLines: 5,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _imageUrlController,
                  label: 'URL ảnh (nếu có)',
                  icon: Icons.image,
                  keyboardType: TextInputType.url,
                  onChanged: (value) => setState(() {}),
                ),

                SizedBox(height: 24),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Không hỏi, thoát luôn
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[700],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text('Hủy', style: TextStyle(fontSize: 16)),
                        ),
                      ),

                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _submitRecipe,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink[300],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            'Đăng bài',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey[700]) : null,
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
        ),
      ),
    );
  }
}
