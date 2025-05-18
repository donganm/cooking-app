import 'package:flutter/material.dart';
import 'package:btl_flutter_nhom6/screens/recipe_detail_screen.dart';

class RecipeCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const RecipeCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 15,
        ),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            item['image'],
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          item['title'],
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => RecipeDetailScreen(
                    title: item['title'],
                    imageUrl: item['image'],
                    time: item['time'],
                    difficulty: item['difficulty'],
                    ytVideo: item['ytVideo'],
                    category: item['category'],
                    ingredients: List<String>.from(item['ingredients']),
                    instructions: List<String>.from(item['instructions']),
                    detail: List<String>.from(item['detail']),
                  ),
            ),
          );
        },
      ),
    );
  }
}
