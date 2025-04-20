import 'package:flutter/material.dart';
import 'recipe_data.dart';
import 'recipe_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  State<SearchScreen> createState() => _SearchScreenState();
  }

class _SearchScreenState extends State<SearchScreen>{
  String _searchText = "";
  @override
  @override
  Widget build(BuildContext context) {
    // Lọc danh sách theo từ khóa
    List<Map<String, dynamic>> filteredList = recipeList
        .where((item) => item['title']!
            .toLowerCase()
            .contains(_searchText.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Recipes"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Column(
        children: [
          // 🔍 Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
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
                return ListTile(
                  leading: Image.asset(
                    item['image']!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(item['title']!),
                  onTap: () {
                    //xử lý khi chọn món nếu muốn
                    Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => RecipeDetailScreen(
                          title: item['title'],
                          imageUrl: item['image'],
                          ingredients: item['ingredients'],
                          instructions: item['instructions'],
                        ),
                  ),
                );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

