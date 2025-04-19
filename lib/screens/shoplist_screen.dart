import 'package:flutter/material.dart';
import 'recipe_data.dart';
import 'recipe_detail_screen.dart';

class ShoplistScreen extends StatelessWidget {
  const ShoplistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping list'),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      backgroundColor: Colors.grey[200],
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: recipeList.length,
        itemBuilder: (context, index) {
          final item = recipeList[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: const EdgeInsets.symmetric(vertical: 10),

            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(item['image']!, width: 60, height: 60, fit: BoxFit.cover),
              ),
              title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailScreen(
                      title: item['title'],
                      imageUrl: item['image'],
                      ingredients: item['ingredients'],
                      instructions: item['instructions'],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
