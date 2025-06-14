import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'create_recipe_screen.dart';
import 'edit_recipe_screen.dart';
import 'comments_screen.dart';

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
                  Navigator.of(context).pop();
                  await _deleteRecipe(recipeId);
                },
              ),
            ],
          ),
    );
  }

  Future<void> _deleteRecipe(String recipeId) async {
    try {
      await FirebaseFirestore.instance
          .collection('my_recipes')
          .doc(uid)
          .collection('items')
          .doc(recipeId)
          .delete();

      await FirebaseFirestore.instance
          .collection('community_recipes')
          .doc(recipeId)
          .delete();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('saved_recipes')
          .doc(recipeId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Xóa bài viết thành công')));
      }
    } catch (e) {
      print('Lỗi khi xóa: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi xóa bài viết')));
      }
    }
  }

  Future<void> _toggleLike(String recipeId, bool isLiked) async {
    final recipeRef = FirebaseFirestore.instance
        .collection('community_recipes')
        .doc(recipeId);
    final snapshot = await recipeRef.get();
    final data = snapshot.data() as Map<String, dynamic>? ?? {};
    final likes = List<String>.from(data['likes'] ?? []);

    if (isLiked) {
      likes.remove(uid);
    } else {
      likes.add(uid);
    }

    await recipeRef.update({'likes': likes});
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
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

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
              final imageUrl = myRecipeData['imageUrl'] ?? '';
              final ownerId = myRecipeData['userId'] ?? uid;

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
                  final isLiked = likes.contains(uid);

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (imageUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.network(
                              imageUrl,
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
                              ExpandableText(text: description),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap:
                                            () =>
                                                _toggleLike(recipeId, isLiked),
                                        child: Icon(
                                          Icons.favorite,
                                          color:
                                              isLiked
                                                  ? Colors.red
                                                  : Colors.grey,
                                          size: 20,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Text('${likes.length}'),
                                      SizedBox(width: 16),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => CommentsScreen(
                                                    recipeId: recipeId,
                                                    recipeOwnerId: ownerId,
                                                  ),
                                            ),
                                          );
                                        },
                                        child: Icon(
                                          Icons.comment,
                                          color: Colors.grey[600],
                                          size: 20,
                                        ),
                                      ),
                                      // SizedBox(width: 4),
                                      // Text('$commentsCount'),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => EditRecipeScreen(
                                                    recipeId: recipeId,
                                                    initialData: myRecipeData,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed:
                                            () => _confirmDelete(
                                              context,
                                              recipeId,
                                            ),
                                      ),
                                    ],
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

class ExpandableText extends StatefulWidget {
  final String text;

  const ExpandableText({required this.text});

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;
  bool _showMoreButton = false;

  final TextStyle _textStyle = TextStyle(
    fontSize: 15,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkTextOverflow());
  }

  void _checkTextOverflow() {
    final textSpan = TextSpan(text: widget.text, style: _textStyle);
    final tp = TextPainter(
      text: textSpan,
      maxLines: 2,
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: context.size!.width);

    if (tp.didExceedMaxLines) {
      setState(() => _showMoreButton = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxLines = _expanded ? null : 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          style: _textStyle,
          maxLines: maxLines,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        if (_showMoreButton)
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _expanded ? 'Thu gọn ▲' : 'Xem thêm ▼',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}