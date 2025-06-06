import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'create_recipe_screen.dart';

class MyDishesTab extends StatefulWidget {
  @override
  _MyDishesTabState createState() => _MyDishesTabState();
}

class _MyDishesTabState extends State<MyDishesTab> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  void _confirmDelete(BuildContext context, String recipeId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Xóa bài viết'),
            content: Text('Bạn có chắc muốn xóa bài viết này không?'),
            actions: [
              TextButton(
                child: Text('Hủy'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text('Xóa', style: TextStyle(color: Colors.red)),
                onPressed: () async {
                  Navigator.of(context).pop(); // Đóng dialog
                  await _deleteRecipe(recipeId);
                },
              ),
            ],
          ),
    );
  }

  Future<void> _deleteRecipe(String recipeId) async {
    final myRecipesRef = FirebaseFirestore.instance
        .collection('my_recipes')
        .doc(uid)
        .collection('items')
        .doc(recipeId);

    final communityRecipesRef = FirebaseFirestore.instance
        .collection('community_recipes')
        .doc(recipeId);

    final savedRecipesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('saved_recipes')
        .doc(recipeId);

    try {
      await myRecipesRef.delete();
      await communityRecipesRef.delete();
      await savedRecipesRef.delete();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Xóa bài viết thành công')));
      }
    } catch (e) {
      print('Lỗi khi xóa bài viết: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi xóa bài viết')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Món của tôi')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('my_recipes')
                .doc(uid)
                .collection('items')
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(child: Text('Bạn chưa đăng món nào.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final myRecipeData = docs[index].data() as Map<String, dynamic>;
              final recipeId = docs[index].id;
              final title = myRecipeData['title'] ?? 'Không có tiêu đề';
              final description = myRecipeData['description'] ?? '';
              final imageAssetPath = myRecipeData['imageUrl'] ?? '';

              return StreamBuilder<DocumentSnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('community_recipes')
                        .doc(recipeId)
                        .snapshots(),
                builder: (context, communitySnapshot) {
                  if (!communitySnapshot.hasData) {
                    return SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final communityData =
                      communitySnapshot.data!.data() as Map<String, dynamic>? ??
                      {};

                  final commentsCount = communityData['commentsCount'] ?? 0;
                  final likes = List<String>.from(communityData['likes'] ?? []);
                  final bool isLikedByUser = likes.contains(uid);

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (imageAssetPath.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.asset(
                              imageAssetPath,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 180,
                                  color: Colors.grey[300],
                                  child: Center(
                                    child: Icon(Icons.broken_image, size: 50),
                                  ),
                                );
                              },
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.favorite,
                                        color:
                                            isLikedByUser
                                                ? Colors.red
                                                : Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 4),
                                      Text('${likes.length}'),
                                      SizedBox(width: 16),
                                      Icon(
                                        Icons.comment,
                                        color: Colors.grey[600],
                                        size: 20,
                                      ),
                                      SizedBox(width: 4),
                                      Text('$commentsCount'),
                                    ],
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed:
                                        () => _confirmDelete(context, recipeId),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateRecipeScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
