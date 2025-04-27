import 'package:flutter/material.dart';
import 'package:btl_flutter_nhom6/screens/recipe_detail_screen.dart';

class SquareRecipeCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const SquareRecipeCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final Map<String, IconData> categoryIcons = {
      'All': Icons.menu_book,
      'Entrées': Icons.dinner_dining,
      'Desserts': Icons.bakery_dining,
      'Drinks': Icons.emoji_food_beverage,
    };
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(
              title: item['title'],
              imageUrl: item['image'],
              ytVideo: item['ytVideo'],
              time: item['time'],
              difficulty: item['difficulty'],
              category: item['category'],
              ingredients: item['ingredients'],
              instructions: item['instructions'],
              detail: item['detail'],
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    item['image'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        item['title'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Icon(
                            categoryIcons[item['category']],
                            size: 24,
                          ),
                          Text(item['category'], style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}