import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SavedOrderTab extends StatelessWidget {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Món đã lưu')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(currentUserId)
                .collection('saved_recipes')
                .orderBy('savedAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(child: Text('Bạn chưa lưu món ăn nào.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              final recipeId = docs[index].id;
              final title = data['title'] ?? 'Không có tiêu đề';
              final description = data['description'] ?? '';
              final imageAssetPath = data['imageUrl'] ?? '';

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
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () async {
                                try {
                                  final batch =
                                      FirebaseFirestore.instance.batch();

                                  final savedRef = FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(currentUserId)
                                      .collection('saved_recipes')
                                      .doc(recipeId);

                                  final recipeRef = FirebaseFirestore.instance
                                      .collection('community_recipes')
                                      .doc(recipeId);

                                  batch.delete(savedRef);

                                  batch.update(recipeRef, {
                                    'likes': FieldValue.arrayRemove([
                                      currentUserId,
                                    ]),
                                  });

                                  await batch.commit();
                                } catch (e) {
                                  print('Lỗi khi bỏ lưu: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Có lỗi xảy ra khi bỏ lưu'),
                                    ),
                                  );
                                }
                              },
                              icon: Icon(Icons.delete, color: Colors.red),
                              label: Text(
                                'Bỏ lưu',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
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
