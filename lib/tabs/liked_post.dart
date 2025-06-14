import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'comments_screen.dart';

class LikedPost extends StatelessWidget {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bài đã thích')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: StreamBuilder<QuerySnapshot>(
          stream:
          FirebaseFirestore.instance
              .collection('community_recipes')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            // Lọc bài viết mà user đã like
            final likedDocs = snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final likes = List<String>.from(data['likes'] ?? []);
              return likes.contains(currentUserId);
            }).toList();

            if (likedDocs.isEmpty) {
              return Center(child: Text('Bạn chưa like công thức nào.'));
            }

            return ListView.builder(
              itemCount: likedDocs.length,
              itemBuilder: (context, index) {
                final doc = likedDocs[index];
                final data = doc.data() as Map<String, dynamic>;

                final recipeId = doc.id;
                final title = data['title'] ?? 'Không có tiêu đề';
                final description = data['description'] ?? '';
                final imageUrl = data['imageUrl'] ?? '';
                final likes = List<String>.from(data['likes'] ?? []);
                final commentsCount = data['commentsCount'] ?? 0;
                final isLiked = likes.contains(currentUserId);
                final ownerId = data['userId'] ?? '';

                Widget? imageWidget;

                if (imageUrl.startsWith('assets/')) {
                  imageWidget = Image.asset(
                    imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return SizedBox.shrink(); // ✅ Trả về widget hợp lệ
                    },
                  );
                } else if (imageUrl.isNotEmpty) {
                  imageWidget = Image.network(
                    imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        height: 180,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return SizedBox.shrink(); // ✅ Không trả về null
                    },
                  );
                }

                return Card(
                  elevation: 8,
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance.collection('users').doc(data['createdBy']).get(),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.connectionState == ConnectionState.waiting) {
                                  return SizedBox();
                                }
                                final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
                                final userEmail = userData?['email'] ?? 'Không rõ email';
                                final userName = userData?['fullname'] ?? 'Chef';
                                return Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 21,
                                      backgroundImage: NetworkImage(
                                        "https://hoseiki.vn/wp-content/uploads/2025/03/avatar-mac-dinh-5.jpg",
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '   $userName',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '  $userEmail',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontStyle: FontStyle.italic,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                            SizedBox(height: 10),
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ExpandableText(text: description),
                          ],
                        ),
                      ),
                      if (imageWidget != null) imageWidget,
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
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
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    isLiked
                                        ? Icon(Icons.thumb_up, size: 25, color: Colors.red)
                                        : Icon(Icons.thumb_up_outlined, size: 25, color: Colors.grey[600]),
                                    SizedBox(width: 4),
                                    Text('${likes.length}', style: TextStyle(fontSize: 18)),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: GestureDetector(
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
                                child: Center(
                                  child: Icon(
                                    Icons.comment,
                                    color: Colors.grey[600],
                                    size: 25,
                                  ),
                                ),
                              ),
                            ),
                            // SizedBox(width: 4),
                            // Text('$commentsCount'),
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