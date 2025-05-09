import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:btl_flutter_nhom6/widgets/recipe_card.dart';
import 'package:btl_flutter_nhom6/screens/recipe_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchText = ""; // Biến lưu trữ từ khóa tìm kiếm

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tìm kiếm công thức"),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔍 Thanh tìm kiếm
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Ví dụ: Burger rau củ',
                  suffixIcon: const Icon(Icons.tune),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchText = value; // Cập nhật từ khóa tìm kiếm
                  });
                },
              ),
            ),

            // 📃 Danh sách kết quả tìm kiếm
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection(
                          'recipes',
                        ) // Lấy dữ liệu từ collection 'recipes'
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Có lỗi xảy ra!'));
                  }

                  final recipes =
                      snapshot.data!.docs; // Danh sách tài liệu từ Firestore
                  // Lọc các công thức theo từ khóa tìm kiếm
                  final filteredRecipes =
                      recipes.where((recipe) {
                        final title = recipe['title'].toString().toLowerCase();
                        return title.contains(_searchText.toLowerCase());
                      }).toList();

                  if (filteredRecipes.isEmpty) {
                    return const Center(
                      child: Text('Không tìm thấy công thức nào.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final item =
                          filteredRecipes[index].data() as Map<String, dynamic>;
                      return RecipeCard(
                        item: item,
                      ); // Hiển thị công thức tìm được
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
