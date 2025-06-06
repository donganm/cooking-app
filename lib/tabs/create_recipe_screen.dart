import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateRecipeScreen extends StatefulWidget {
  @override
  _CreateRecipeScreenState createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _imageUrlController = TextEditingController();
  bool _isLoading = false;

  void _submitRecipe() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
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

      Navigator.pop(context);
    } catch (e) {
      print('Lỗi: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Đã xảy ra lỗi khi đăng bài.")));
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveDraft() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final title = _titleController.text.trim();
    final description = _descController.text.trim();
    final imageUrl = _imageUrlController.text.trim();

    if (title.isEmpty && description.isEmpty && imageUrl.isEmpty) {
      // Nếu nháp trống, không lưu mà thoát luôn
      Navigator.pop(context);
      return;
    }

    setState(() => _isLoading = true);

    final draftData = {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'createdBy': uid,
      'savedAt': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('drafts')
          .doc(uid)
          .collection('items')
          .add(draftData);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Đã lưu nháp.")));
      Navigator.pop(context);
    } catch (e) {
      print('Lỗi lưu nháp: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi khi lưu nháp.")));
    }

    setState(() => _isLoading = false);
  }

  Future<bool> _onWillPop() async {
    if (_titleController.text.isEmpty &&
        _descController.text.isEmpty &&
        _imageUrlController.text.isEmpty) {
      return true; // không có gì để lưu, thoát luôn
    }
    final shouldSave = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Lưu nháp?'),
            content: Text('Bạn có muốn lưu nháp bài viết không?'),
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
    if (shouldSave == true) {
      await _saveDraft();
      return false; // đã lưu xong, không thoát nữa vì _saveDraft gọi Navigator.pop()
    }
    return true; // không lưu, thoát luôn
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Đăng món mới',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop) Navigator.pop(context);
            },
          ),
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
                  maxLines: 1,
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
                  maxLines: 1,
                  onChanged: (value) => setState(() {}),
                ),

                SizedBox(height: 30),
                _isLoading
                    ? CircularProgressIndicator()
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _submitRecipe,
                            icon: Icon(Icons.send),
                            label: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Text(
                                'Đăng bài',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[700],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _saveDraft,
                            icon: Icon(Icons.save_alt),
                            label: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Text(
                                'Lưu nháp',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink[300],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
      ),
      style: TextStyle(fontSize: 16),
    );
  }
}
