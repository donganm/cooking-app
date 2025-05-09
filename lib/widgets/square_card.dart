import 'package:flutter/material.dart';
import 'package:btl_flutter_nhom6/screens/recipe_detail_screen.dart';

class SquareRecipeCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const SquareRecipeCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // Danh mục và icon tương ứng
    final Map<String, IconData> categoryIcons = {
      'Tất cả': Icons.menu_book,
      'Món khai vị': Icons.dinner_dining,
      'Món chính': Icons.fastfood,
      'Món tráng miệng': Icons.cake,
      'Đồ uống': Icons.local_drink,
    };

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
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 3,
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
                      flex: 2,
                      child: Column(
                        children: [
                          Icon(icon, size: 24),
                          Text(category, style: const TextStyle(fontSize: 12)),
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
