import 'package:btl_flutter_nhom6/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/list_holder.dart';
import 'square_card.dart';

class Category extends StatefulWidget {
  const Category({super.key});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  String _selectedCategory = 'Tất cả';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Query recipeQuery = FirebaseFirestore.instance.collection('recipes');
    if (_selectedCategory != 'Tất cả') {
      recipeQuery = recipeQuery.where('category', isEqualTo: _selectedCategory);
    }

    return Column(
      children: [
        // Thanh chọn danh mục
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = _selectedCategory == category;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                    _searchQuery = '';
                    _searchController.clear(); // Xóa ô tìm kiếm khi đổi danh mục
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 140,
                  child: Card(
                    elevation: 6,
                    color: isSelected ? Colors.pinkAccent : Colors.white,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            categoryIcons[category],
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        // Thanh tìm kiếm
        RecipeSearch(
          controller: _searchController,
          onSearchChanged: (query) {
            setState(() {
              _searchQuery = query;
            });
          },
        ),

        // Danh sách món ăn
        StreamBuilder<QuerySnapshot>(
          stream: recipeQuery.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text('Không tìm thấy công thức')),
              );
            }

            final recipes = snapshot.data!.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .where((data) {
              final title = (data['title'] ?? '').toString().toLowerCase();
              final category = (data['category'] ?? '').toString().toLowerCase();
              return title.contains(_searchQuery.toLowerCase()) ||
                  category.contains(_searchQuery.toLowerCase());
            })
                .toList();

            if (recipes.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text('Không tìm thấy công thức')),
              );
            }

            return GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: recipes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final data = recipes[index];
                return SquareRecipeCard(item: data);
              },
            );
          },
        ),
      ],
    );
  }
}
