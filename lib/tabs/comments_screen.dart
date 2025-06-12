import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentsScreen extends StatefulWidget {
  final String recipeId;
  final String recipeOwnerId;
  const CommentsScreen({required this.recipeId, required this.recipeOwnerId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<DocumentSnapshot> _comments = [];
  DocumentSnapshot? _lastDoc;
  bool _isLoading = false;
  bool _hasMore = true;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _loadComments();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading) {
        _loadComments();
      }
    });
  }

  Future<void> _loadComments() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    Query query = FirebaseFirestore.instance
        .collection('community_recipes')
        .doc(widget.recipeId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .limit(_limit);

    if (_lastDoc != null) {
      query = query.startAfterDocument(_lastDoc!);
    }

    final snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      _lastDoc = snapshot.docs.last;
    }

    setState(() {
      _comments.addAll(snapshot.docs);
      _isLoading = false;
      if (snapshot.docs.length < _limit) _hasMore = false;
    });
  }

  Future<Map<String, String>> _getUserInfo(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final data = userDoc.data() ?? {};
    return {
      'displayName': data['displayName'] ?? 'Người dùng',
      'photoUrl': data['photoUrl'] ?? '',
    };
  }

  Future<void> _sendComment(String text, {String? parentId}) async {
    if (text.trim().isEmpty) return;
    await FirebaseFirestore.instance
        .collection('community_recipes')
        .doc(widget.recipeId)
        .collection('comments')
        .add({
          'text': text,
          'userId': currentUser.uid,
          'createdAt': FieldValue.serverTimestamp(),
          if (parentId != null) 'parentId': parentId,
        });
    _commentController.clear();
    setState(() {
      _comments.clear();
      _lastDoc = null;
      _hasMore = true;
    });
    _loadComments();
  }

  Future<void> _deleteComment(String commentId) async {
    await FirebaseFirestore.instance
        .collection('community_recipes')
        .doc(widget.recipeId)
        .collection('comments')
        .doc(commentId)
        .delete();

    setState(() {
      _comments.removeWhere((doc) => doc.id == commentId);
    });
  }

  Future<void> _editComment(String commentId, String currentText) async {
    final controller = TextEditingController(text: currentText);
    final newText = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Sửa bình luận'),
            content: TextField(controller: controller, maxLines: 4),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: Text('Lưu'),
              ),
            ],
          ),
    );

    if (newText != null &&
        newText.trim().isNotEmpty &&
        newText != currentText) {
      await FirebaseFirestore.instance
          .collection('community_recipes')
          .doc(widget.recipeId)
          .collection('comments')
          .doc(commentId)
          .update({'text': newText});

      setState(() {
        final index = _comments.indexWhere((doc) => doc.id == commentId);
        if (index != -1) _comments[index] = _comments[index];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final parentComments =
        _comments.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['parentId'] == null;
        }).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Bình luận')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: parentComments.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == parentComments.length) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final doc = parentComments[index];
                final data = doc.data() as Map<String, dynamic>;
                final text = data['text'] ?? '';
                final userId = data['userId'] ?? '';
                final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
                final isMine = userId == currentUser.uid;
                final timeString =
                    createdAt != null ? timeago.format(createdAt) : '';

                return FutureBuilder<Map<String, String>>(
                  future: _getUserInfo(userId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return SizedBox();
                    final user = snapshot.data!;
                    final name = user['displayName']!;
                    final avatarUrl = user['photoUrl']!;

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  avatarUrl.isNotEmpty
                                      ? NetworkImage(avatarUrl)
                                      : null,
                              child:
                                  avatarUrl.isEmpty ? Icon(Icons.person) : null,
                            ),
                            title: Text(text),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  timeString,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            trailing:
                                isMine
                                    ? PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _editComment(doc.id, text);
                                        } else if (value == 'delete') {
                                          _deleteComment(doc.id);
                                        }
                                      },
                                      itemBuilder:
                                          (context) => [
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: Text('Sửa'),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Text('Xóa'),
                                            ),
                                          ],
                                    )
                                    : null,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: TextButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (_) {
                                    final replyController =
                                        TextEditingController();
                                    return Padding(
                                      padding:
                                          MediaQuery.of(context).viewInsets,
                                      child: Container(
                                        padding: EdgeInsets.all(12),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller: replyController,
                                              decoration: InputDecoration(
                                                hintText:
                                                    'Trả lời bình luận...',
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                  await _sendComment(
                                                    replyController.text,
                                                    parentId: doc.id,
                                                  );
                                                },
                                                child: Text('Gửi'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Text('Phản hồi'),
                            ),
                          ),
                          ..._comments
                              .where((replyDoc) {
                                final replyData =
                                    replyDoc.data() as Map<String, dynamic>;
                                return replyData['parentId'] == doc.id;
                              })
                              .map((replyDoc) {
                                final replyData =
                                    replyDoc.data() as Map<String, dynamic>;
                                final replyText = replyData['text'] ?? '';
                                final replyUserId = replyData['userId'] ?? '';
                                final replyCreatedAt =
                                    (replyData['createdAt'] as Timestamp?)
                                        ?.toDate();
                                final isReplyMine =
                                    replyUserId == currentUser.uid;
                                final replyTime =
                                    replyCreatedAt != null
                                        ? timeago.format(replyCreatedAt)
                                        : '';

                                return FutureBuilder<Map<String, String>>(
                                  future: _getUserInfo(replyUserId),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) return SizedBox();
                                    final replyUser = snapshot.data!;
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        left: 40,
                                        right: 8,
                                        top: 4,
                                        bottom: 4,
                                      ),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage:
                                              replyUser['photoUrl']!.isNotEmpty
                                                  ? NetworkImage(
                                                    replyUser['photoUrl']!,
                                                  )
                                                  : null,
                                          child:
                                              replyUser['photoUrl']!.isEmpty
                                                  ? Icon(Icons.person)
                                                  : null,
                                        ),
                                        title: Text(replyText),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              replyUser['displayName']!,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              replyTime,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing:
                                            isReplyMine
                                                ? PopupMenuButton<String>(
                                                  onSelected: (value) {
                                                    if (value == 'edit') {
                                                      _editComment(
                                                        replyDoc.id,
                                                        replyText,
                                                      );
                                                    } else if (value ==
                                                        'delete') {
                                                      _deleteComment(
                                                        replyDoc.id,
                                                      );
                                                    }
                                                  },
                                                  itemBuilder:
                                                      (context) => [
                                                        PopupMenuItem(
                                                          value: 'edit',
                                                          child: Text('Sửa'),
                                                        ),
                                                        PopupMenuItem(
                                                          value: 'delete',
                                                          child: Text('Xóa'),
                                                        ),
                                                      ],
                                                )
                                                : null,
                                      ),
                                    );
                                  },
                                );
                              })
                              .toList(),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Viết bình luận...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
                  onPressed: () => _sendComment(_commentController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
