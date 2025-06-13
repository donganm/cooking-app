import 'dart:ui';
import 'package:flutter/material.dart';
import '/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:btl_flutter_nhom6/screens/profile_manager/UploadRecipe.dart';

class CheckRecipeStatus extends StatefulWidget {
  const CheckRecipeStatus({Key? key}) : super(key: key);

  @override
  State<CheckRecipeStatus> createState() => _CheckRecipeStatusState();
}

class _CheckRecipeStatusState extends State<CheckRecipeStatus> {
  late ApiService apiService;

  @override
  void initState() {
    super.initState();
    apiService = ApiService(baseUrl: 'https://apicookapp.onrender.com');
  }

  Stream<Map<String, dynamic>?> recipeStream() async* {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      yield {'error': 'Bạn chưa đăng nhập'};
      return;
    }

    while (true) {
      try {
        final data = await apiService.fetchUserRecipes(user.uid);
        yield data;
      } catch (e) {
        yield {'error': e.toString()};
      }

      await Future.delayed(const Duration(seconds: 5));
    }
  }

  Widget buildRecipeList(List recipes) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    collapsedIconColor: Colors.white,
                    iconColor: Colors.white,
                    collapsedBackgroundColor: Colors.transparent,
                    backgroundColor: Colors.transparent,
                    textColor: Colors.white,
                    collapsedTextColor: Colors.white,
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: recipe['image'] != null && recipe['image'] != ''
                          ? Image.network(
                              recipe['image'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.network(
                                  'https://thumb.ac-illust.com/b1/b170870007dfa419295d949814474ab2_t.jpeg',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          : Image.network(
                              'https://thumb.ac-illust.com/b1/b170870007dfa419295d949814474ab2_t.jpeg',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                    ),
                    title: Text(
                      recipe['title'] ?? 'Không có tiêu đề',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Trạng thái: ${recipe['approved'] == true ? "Chờ duyệt" : "Đã duyệt"}',
                      style: TextStyle(
                        color: recipe['approved'] == true ? Colors.amberAccent : Colors.lightGreenAccent,
                      ),
                    ),
                    children: [
                      if (recipe['category'] != null)
                        Text('• Danh mục: ${recipe['category']}', style: const TextStyle(color: Colors.white70)),
                      if (recipe['difficulty'] != null)
                        Text('• Độ khó: ${recipe['difficulty']}', style: const TextStyle(color: Colors.white70)),
                      if (recipe['time'] != null)
                        Text('• Thời gian: ${recipe['time']}', style: const TextStyle(color: Colors.white70)),
                      if (recipe['tags'] != null && recipe['tags'] is List)
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: List<Widget>.from(recipe['tags'].map((tag) {
                            return Chip(
                              label: Text(tag.toString()),
                              backgroundColor: Colors.white.withOpacity(0.2),
                              labelStyle: const TextStyle(color: Colors.white),
                            );
                          })),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 191, 192, 196),
            Color.fromARGB(255, 15, 53, 129),
            Color.fromARGB(255, 23, 189, 67),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          title: const Text(
            'Đóng góp công thức',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: StreamBuilder<Map<String, dynamic>?>(
          stream: recipeStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }

            final data = snapshot.data!;
            if (data.containsKey('error')) {
              return Center(
                child: Text(
                  'Lỗi: ${data['error']}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            final approvedList = data['approved'] ?? [];
            final waitingList = data['waiting'] ?? [];
            final bool hasRecipes = approvedList.isNotEmpty || waitingList.isNotEmpty;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: hasRecipes
                  ? SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🙆‍♀️ Bài đăng đã duyệt (${approvedList.length})',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          buildRecipeList(approvedList),

                          const SizedBox(height: 24),

                          Text(
                            '🙅‍♂️ Bài đăng chờ duyệt (${waitingList.length})',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          buildRecipeList(waitingList),
                        ],
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Bạn chưa có bài đăng nào.',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const UploadRecipe()),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Đăng bài mới'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}
