import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:btl_flutter_nhom6/widgets/recipes_slider.dart';
import 'package:btl_flutter_nhom6/screens/recipe_detail_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> recipes = [
    {
      'title': 'Risotto',
      'image': 'assets/images/bun_cha.jpg',
      'tags': 'Healthy • Vegetarian • Lunch',
      'category': 'Entrées',
      'time': '30 - 45 min',
      'difficulty': 'Hard',
      'ytVideo': 'https://www.youtube.com/watch?v=NKtR3KpS83w',
      'ingredients': [
        '1 small onion',
        '300g Arborio rice',
        '100ml white wine',
        '1 liter hot chicken/vegetable stock',
        '50g parmesan',
        '30g butter',
        'Salt and pepper',
      ],
      'instructions': [
        'Sauté garlic and onion',
        'Stir the rice',
        'Deglaze with wine',
        'Add stock gradually',
        'Cook risotto completely',
        'Serve with butter and parmesan',
      ],
      'detail': [
        'Heat oil, sauté onion until translucent',
        'Add rice and stir until glossy, about 2 min',
        'Pour in wine and cook until it is absorbed',
        'Stir constantly, adding stock ladle by ladle',
        'Continue until rice is tender but slightly firm',
        'Stir in butter and parmesan. Season to taste and serve',
      ],
    },
    {
      'title': 'Cheesecake',
      'image': 'assets/images/goi_cuon.jpg',
      'tags': 'Dessert • Sweet • Chilled',
      'category': 'Desserts',
      'time': '1 hours',
      'difficulty': 'Medium',
      'ytVideo': 'https://www.youtube.com/watch?v=wNLxiRcNsPg',
      'ingredients': [
        '200g crushed digestive biscuits',
        '100g melted butter',
        '600g cream cheese',
        '100g powdered sugar',
        '1 tsp vanilla extract',
        '200ml heavy cream',
      ],
      'instructions': [
        'Prepare biscuit base',
        'Mix cheesecake filling',
        'Whip and fold cream',
        'Assemble the cheesecake',
        'Chill the cheesecake',
        'Decorate and serve',
      ],
      'detail': [
        'Mix crushed biscuits with melted butter. Press into a springform pan. Chill for 30 min',
        'Beat cream cheese, sugar, and vanilla until smooth',
        'Whip heavy cream separately, then gently fold into the cream cheese mixture',
        'Pour the filling onto the chilled base and smooth the top',
        'Refrigerate for at least 4 hours or overnight',
        'Optionally top with fruits, sauces, or chocolate',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink.shade300, // Changed color
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 21,
                  backgroundImage: AssetImage('assets/images/profile.jpg'),
                ),
                const SizedBox(width: 15),
                Text(
                  "Hello, ${user?.email?.split('@')[0] ?? "Chef"}!",
                  style: const TextStyle(
                    fontSize: 22, // Adjusted font size
                    fontWeight: FontWeight.w600, // Adjusted font weight
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 26),
            const Text(
              "What are we cooking \ntoday?",
              style: TextStyle(
                fontSize: 30, // Increased font size
                fontWeight: FontWeight.bold,
                fontFamily: 'PlaywriteAUSA',
              ),
            ),
            const RecipeSlider(),
            const SizedBox(height: 24),
            const Text(
              "Categories",
              style: TextStyle(
                fontSize: 22, // Increased font size
                fontWeight: FontWeight.bold,
                fontFamily: 'PlaywriteAUSA',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                CategoryIcon(icon: Icons.all_inclusive, label: "All"),
                CategoryIcon(icon: Icons.soup_kitchen, label: "Soups"),
                CategoryIcon(icon: Icons.fastfood, label: "Desserts"),
                CategoryIcon(icon: Icons.local_drink, label: "Drinks"),
              ],
            ),
            const SizedBox(height: 24),
            // Hiển thị các recipe từ danh sách
            ...List.generate((recipes.length / 2).ceil(), (i) {
              final first = recipes[i * 2];
              final second =
                  (i * 2 + 1 < recipes.length) ? recipes[i * 2 + 1] : null;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Expanded(child: RecipeCard(data: first)),
                    const SizedBox(width: 12),
                    Expanded(
                      child:
                          second != null
                              ? RecipeCard(data: second)
                              : const SizedBox(),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class CategoryIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const CategoryIcon({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50, // Kích thước cố định cho ảnh
          height: 50, // Kích thước cố định cho ảnh
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade200,
          ),
          child: Icon(
            icon,
            color: Colors.pinkAccent,
            size: 28,
          ), // Điều chỉnh kích thước icon bên trong
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class RecipeCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const RecipeCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => RecipeDetailScreen(
                  title: data['title'],
                  imageUrl: data['image'],
                  time: data['time'],
                  difficulty: data['difficulty'],
                  ytVideo: data['ytVideo'],
                  category: data['category'],
                  ingredients: List<String>.from(data['ingredients']),
                  instructions: List<String>.from(data['instructions']),
                  detail: List<String>.from(data['detail']),
                ),
          ),
        );
      },
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16), // Bo góc mềm mại
            child: Container(
              height: 120, // Chiều cao cố định
              width: double.infinity, // Đảm bảo ảnh chiếm đầy không gian
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(data['image']),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data['title'],
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
