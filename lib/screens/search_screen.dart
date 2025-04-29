import 'package:flutter/material.dart';
import 'recipe_data.dart';
import 'recipe_detail_screen.dart';
import 'package:btl_flutter_nhom6/widgets/recipe_card.dart';

class SearchScreen extends StatefulWidget {
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchText = "";
  @override
  Widget build(BuildContext context) {
    // Lọc danh sách theo từ khóa
    List<Map<String, dynamic>> filteredList =
        recipeList
            .where(
              (item) => item['title']!.toLowerCase().contains(
                _searchText.toLowerCase(),
              ),
            )
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Recipes"),
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
                  hintText: 'Ex: Veggie Burger',
                  suffixIcon: const Icon(Icons.tune),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
              ),
            ),

            // 📃 Danh sách kết quả
            Expanded(
              child: ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final item = filteredList[index];
                  return RecipeCard(item: item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
