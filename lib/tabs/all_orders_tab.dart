import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AllOrdersTab extends StatelessWidget {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Group Recipes')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('community_recipes')
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(child: Text('Chưa có công thức nào.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final recipeId = doc.id;
              final title = data['title'] ?? 'Không có tiêu đề';
              final description = data['description'] ?? '';
              final imageUrl = data['imageUrl'] ?? '';
              final likes = List<String>.from(data['likes'] ?? []);
              final commentsCount = data['commentsCount'] ?? 0;
              final isLiked = likes.contains(currentUserId);

              Widget? imageWidget;

              if (imageUrl.startsWith('assets/')) {
                imageWidget = ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.asset(
                    imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return SizedBox.shrink(); // ✅ Trả về widget hợp lệ
                    },
                  ),
                );
              } else if (imageUrl.isNotEmpty) {
                imageWidget = ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 180,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return SizedBox.shrink(); // ✅ Không trả về null
                    },
                  ),
                );
              }

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imageWidget != null) imageWidget,
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
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  final recipeRef = FirebaseFirestore.instance
                                      .collection('community_recipes')
                                      .doc(recipeId);
                                  final savedRef = FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(currentUserId)
                                      .collection('saved_recipes')
                                      .doc(recipeId);

                                  if (isLiked) {
                                    await recipeRef.update({
                                      'likes': FieldValue.arrayRemove([
                                        currentUserId,
                                      ]),
                                    });
                                    await savedRef.delete();
                                  } else {
                                    await recipeRef.update({
                                      'likes': FieldValue.arrayUnion([
                                        currentUserId,
                                      ]),
                                    });
                                    await savedRef.set({
                                      'title': title,
                                      'description': description,
                                      'imageUrl': imageUrl,
                                      'savedAt': FieldValue.serverTimestamp(),
                                    });
                                  }
                                },
                                child: Icon(
                                  isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.red,
                                  size: 20,
                                ),
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
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
