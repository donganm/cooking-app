import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UploadRecipe extends StatefulWidget {
  const UploadRecipe({Key? key}) : super(key: key);

  @override
  State<UploadRecipe> createState() => _UploadRecipeState();
}

class _UploadRecipeState extends State<UploadRecipe> {
  final _formKey = GlobalKey<FormState>();

  String title = '';
  String category = '';
  String imageUrl = '';
  String time = '';
  String difficulty = '';
  String ytVideo = '';
  String tags = '';
  String ingredients = '';
  String instructions = '';
  String detail = '';

  bool _isSubmitting = false;

  final CollectionReference recipeWaitCollection = FirebaseFirestore.instance.collection('recipe_wait');

  Future<void> _submitRecipe() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần đăng nhập để đăng bài.')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await recipeWaitCollection.add({
        'title': title,
        'category': category,
        'image': imageUrl,
        'time': time,
        'difficulty': difficulty,
        'ytVideo': ytVideo,
        'tags': tags.split('•').map((e) => e.trim()).toList(),
        'ingredients': ingredients.split(',').map((e) => e.trim()).toList(),
        'instructions': instructions.split('.').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        'detail': detail.split(',').map((e) => e.trim()).toList(),
        'createdAt': FieldValue.serverTimestamp(),
        'approved': false,
        'userId': user.uid,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bài đăng đã được gửi, chờ duyệt!')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi gửi bài: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _buildTextField(String label, Function(String) onChanged, {String? Function(String?)? validator, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        maxLines: maxLines,
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng bài nấu ăn mới'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('Tiêu đề', (val) => title = val, validator: (v) => v == null || v.isEmpty ? 'Nhập tiêu đề' : null),
              _buildTextField('Danh mục', (val) => category = val, validator: (v) => v == null || v.isEmpty ? 'Nhập danh mục' : null),
              _buildTextField('Ảnh (URL)', (val) => imageUrl = val),
              _buildTextField('Thời gian', (val) => time = val),
              _buildTextField('Độ khó', (val) => difficulty = val),
              _buildTextField('Video YouTube', (val) => ytVideo = val),
              _buildTextField('Tags (cách nhau bằng dấu •)', (val) => tags = val),
              _buildTextField('Nguyên liệu (phân cách bằng dấu ,)', (val) => ingredients = val, validator: (v) => v == null || v.isEmpty ? 'Nhập nguyên liệu' : null, maxLines: 2),
              _buildTextField('Hướng dẫn (phân cách bằng dấu .)', (val) => instructions = val, validator: (v) => v == null || v.isEmpty ? 'Nhập hướng dẫn' : null, maxLines: 3),
              _buildTextField('Chi tiết (phân cách bằng dấu ,)', (val) => detail = val, maxLines: 2),
              const SizedBox(height: 20),
              _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitRecipe,
                      child: const Text('Gửi bài'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
