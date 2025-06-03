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
  bool isLoading = true;
  Map<String, dynamic>? data;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    apiService = ApiService(baseUrl: 'https://apicookapp.onrender.com');
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          errorMessage = 'Bạn chưa đăng nhập';
          isLoading = false;
        });
        return;
      }
      final result = await apiService.fetchUserRecipes(user.uid);
      setState(() {
        data = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Widget buildRecipeList(List recipes) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: ExpansionTile(
            leading: recipe['image'] != null && recipe['image'] != ''
                ? Image.network(recipe['image'], width: 60, height: 60, fit: BoxFit.cover)
                : const Icon(Icons.food_bank),
            title: Text(recipe['title'] ?? 'Không có tiêu đề'),
            subtitle: Text('Trạng thái: ${recipe['approved'] == false ? "Đã duyệt" : "Chờ duyệt"}'),
            childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              if (recipe['category'] != null)
                Text('Danh mục: ${recipe['category']}'),
              if (recipe['difficulty'] != null)
                Text('Độ khó: ${recipe['difficulty']}'),
              if (recipe['time'] != null)
                Text('Thời gian: ${recipe['time']} phút'),
              if (recipe['tags'] != null && recipe['tags'] is List)
                Text('Tag của bài viết: ${recipe['tags']}')
            ],
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(child: Text('Lỗi: $errorMessage')),
      );
    }

    final approvedList = data?['approved'] ?? [];
    final waitingList = data?['waiting'] ?? [];

    final bool hasRecipes = approvedList.isNotEmpty || waitingList.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Trạng thái bài đăng của bạn')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: hasRecipes
            ? SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bài đăng đã duyệt (${approvedList.length}):',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    buildRecipeList(approvedList),

                    const SizedBox(height: 20),

                    Text(
                      'Bài đăng chờ duyệt (${waitingList.length}):',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    buildRecipeList(waitingList),
                  ],
                ),
              )
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Bạn chưa có bài đăng',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const UploadRecipe()),
                        );
                      },
                      child: const Text('Đăng bài mới'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
