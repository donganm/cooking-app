import 'dart:ui';
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

  final CollectionReference recipeWaitCollection =
      FirebaseFirestore.instance.collection('recipe_wait');

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
        'tags': tags,
        'ingredients': ingredients
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'instructions': instructions
            .split('.')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'detail': detail
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'createdAt': FieldValue.serverTimestamp(),
        'approved': true,
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

  Widget _glassTextField({
    required String hint,
    required Function(String) onChanged,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: TextFormField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.white70),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                border: InputBorder.none,
                errorStyle: const TextStyle(color: Colors.redAccent),
              ),
              maxLines: maxLines,
              onChanged: onChanged,
              validator: validator,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Đăng món ăn mới'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f2027), Color(0xFF203a43), Color(0xFF2c5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(20, kToolbarHeight + 30, 20, 20),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _glassTextField(
                    hint: 'Tiêu đề món ăn',
                    onChanged: (val) => title = val,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Vui lòng nhập tiêu đề' : null,
                  ),
                  _glassTextField(
                    hint: 'Danh mục (vd: Món chính, Tráng miệng...)',
                    onChanged: (val) => category = val,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Vui lòng nhập danh mục' : null,
                  ),
                  _glassTextField(
                    hint: 'Ảnh URL',
                    onChanged: (val) => imageUrl = val,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Vui lòng nhập ảnh URL' : null,
                  ),
                  _glassTextField(
                    hint: 'Thời gian (vd: 1 giờ, 30 phút)',
                    onChanged: (val) => time = val,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Vui lòng nhập thời gian' : null,
                  ),
                  _glassTextField(
                    hint: 'Độ khó (vd: Dễ, Trung bình, Khó)',
                    onChanged: (val) => difficulty = val,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Vui lòng nhập độ khó' : null,
                  ),
                  _glassTextField(
                    hint: 'YouTube Video Link',
                    onChanged: (val) => ytVideo = val,
                  ),
                  _glassTextField(
                    hint: 'Tags (chỉ một chuỗi, vd: Món ngon Hà Nội)',
                    onChanged: (val) => tags = val,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Vui lòng nhập tags' : null,
                  ),
                  _glassTextField(
                    hint: 'Nguyên liệu (ngăn cách bởi dấu phẩy ,)',
                    onChanged: (val) => ingredients = val,
                    maxLines: 2,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Vui lòng nhập nguyên liệu' : null,
                  ),
                  _glassTextField(
                    hint: 'Hướng dẫn (ngăn cách bởi dấu chấm .)',
                    onChanged: (val) => instructions = val,
                    maxLines: 3,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Vui lòng nhập hướng dẫn' : null,
                  ),
                  _glassTextField(
                    hint: 'Chi tiết thêm (nếu có, cách nhau bởi dấu phẩy ,)',
                    onChanged: (val) => detail = val,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),
                  _isSubmitting
                      ? const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white))
                      : ElevatedButton(
                          onPressed: _submitRecipe,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            'Gửi bài',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
