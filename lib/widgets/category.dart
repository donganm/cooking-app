import 'package:flutter/material.dart';
import 'package:btl_flutter_nhom6/screens/recipe_data.dart';
import 'square_card.dart';

class Category extends StatefulWidget {
  const Category({super.key});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  final List<String> _categories = ['All', 'Entrées', 'Desserts', 'Drinks'];
  String _selectedCategory = 'All';
  final Map<String, IconData> categoryIcons = {
    'All': Icons.menu_book,
    'Entrées': Icons.dinner_dining,
    'Desserts': Icons.bakery_dining,
    'Drinks': Icons.emoji_food_beverage,
  };

  @override
  Widget build(BuildContext context) {

    List<Map<String, dynamic>> filteredCategory = _selectedCategory == 'All'
        ? recipeList
        : recipeList.where((item) {
      return item['category'].contains(_selectedCategory);
    }).toList();

    return Column(
      children: [
        SizedBox(
          height: 50,
          width: double.infinity,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = _selectedCategory == category;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                width: 110,
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
                            color: isSelected ? Colors.white : Colors.black,fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );},
          ),
        ),

        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: filteredCategory.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1, // tạo card vuông
          ),
          itemBuilder: (context, index) {
            final item = filteredCategory[index];
            return SquareRecipeCard(item: item);
          },
        ),
      ],
    );
  }
}
