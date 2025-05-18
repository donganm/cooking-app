import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'square_card.dart';

class Category extends StatefulWidget {
  const Category({super.key});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  final List<String> _categories = [
    'Tất cả',
    'Món khai vị',
    'Món chính',
    'Món tráng miệng',
    'Đồ uống', // Nếu có thể thêm mục Đồ uống
  ];
  String _selectedCategory = 'Tất cả';

  final Map<String, IconData> categoryIcons = {
    'Tất cả': Icons.menu_book,
    'Món khai vị': Icons.dinner_dining,
    'Món chính': Icons.fastfood,
    'Món tráng miệng': Icons.bakery_dining,
    'Đồ uống': Icons.emoji_food_beverage,
  };

  @override
  Widget build(BuildContext context) {
    // Truy vấn Firestore, lọc theo category nếu cần
    Query recipeQuery = FirebaseFirestore.instance.collection('recipes');
    if (_selectedCategory != 'Tất cả') {
      recipeQuery = recipeQuery.where('category', isEqualTo: _selectedCategory);
    }

    return Column(
      children: [
        // Thanh chọn danh mục
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
                  margin: const EdgeInsets.symmetric(horizontal: 8),
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

        // Danh sách món ăn theo danh mục (dữ liệu từ Firestore)
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
                child: Center(child: Text('No recipes found')),
              );
            }

            final recipes = snapshot.data!.docs;

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
                final data = recipes[index].data() as Map<String, dynamic>;
                return SquareRecipeCard(item: data);
              },
            );
          },
        ),
      ],
    );
  }
}
