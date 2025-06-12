import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditRecipeScreen extends StatefulWidget {
  final String recipeId;
  final Map<String, dynamic> initialData;

  const EditRecipeScreen({required this.recipeId, required this.initialData});

  @override
  _EditRecipeScreenState createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialData['title']);
    _descriptionController = TextEditingController(
      text: widget.initialData['description'],
    );
    _imageUrlController = TextEditingController(
      text: widget.initialData['imageUrl'],
    );
  }

  Future<void> _saveChanges() async {
    final updates = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'imageUrl': _imageUrlController.text.trim(),
    };

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('my_recipes')
        .doc(uid)
        .collection('items')
        .doc(widget.recipeId)
        .update(updates);

    await FirebaseFirestore.instance
        .collection('community_recipes')
        .doc(widget.recipeId)
        .update(updates);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Đã lưu thay đổi')));
      Navigator.pop(context);
    }
  }

  Widget _buildImagePreview() {
    final imageUrl = _imageUrlController.text.trim();
    if (imageUrl.isEmpty) return SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child:
            imageUrl.startsWith('assets/')
                ? Image.asset(
                  imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => _buildErrorImage(),
                )
                : Image.network(
                  imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => _buildErrorImage(),
                ),
      ),
    );
  }

  Widget _buildErrorImage() {
    return Container(
      height: 180,
      color: Colors.grey[300],
      child: Center(child: Icon(Icons.broken_image, size: 50)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chỉnh sửa món ăn')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Cập nhật thông tin món ăn',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),

                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Tiêu đề',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Mô tả',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                TextFormField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(
                    labelText: 'Đường dẫn ảnh (assets hoặc URL)',
                    border: OutlineInputBorder(),
                    hintText: 'VD: assets/images/mon1.jpg hoặc https://...',
                  ),
                  onChanged: (_) => setState(() {}), // để cập nhật ảnh preview
                ),

                _buildImagePreview(),

                SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.save, color: Colors.white), // màu icon
                    label: Text('Lưu thay đổi'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      textStyle: TextStyle(fontSize: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white, // <-- MÀU CHỮ
                    ),
                    onPressed: _saveChanges,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
