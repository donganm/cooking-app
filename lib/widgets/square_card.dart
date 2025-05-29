import 'package:flutter/material.dart';
import 'package:btl_flutter_nhom6/screens/recipe_detail_screen.dart';
import '../screens/list_holder.dart';

class SquareRecipeCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const SquareRecipeCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {

    // Lấy danh mục và icon
    String category = item['category'] ?? 'Tất cả';
    IconData icon = categoryIcons[category] ?? Icons.fastfood;

    // Lấy đường dẫn ảnh và xác định là từ assets hay từ URL
    final String imagePath = item['image'] ?? '';
    final bool isAsset = !imagePath.startsWith('http');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => RecipeDetailScreen(
                  title: item['title'] ?? '',
                  imageUrl: item['image'] ?? '',
                  ytVideo: item['ytVideo'] ?? '',
                  time: item['time'] ?? '',
                  difficulty: item['difficulty'] ?? '',
                  category: item['category'] ?? '',
                  ingredients: item['ingredients'] ?? '',
                  instructions: item['instructions'] ?? '',
                  detail: item['detail'] ?? '',
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
                  child:
                    isAsset
                    ? Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                    : Image.network(
                      imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              const Icon(Icons.broken_image),
                    ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text(
                        item['title'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          SizedBox(height: 4),
                          Icon(icon, size: 24),
                          SizedBox(height: 2),
                          Text(category, style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis,),
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
