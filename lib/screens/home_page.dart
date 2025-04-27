import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:btl_flutter_nhom6/widgets/recipes_slider.dart';
import 'package:btl_flutter_nhom6/screens/recipe_detail.dart'; // Đảm bảo đường dẫn đúng

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'PlaywriteAUSA'
              ),
            ),
            const SizedBox(height: 17),
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                hintText: 'Ex: Veggie Burger',
                suffixIcon: const Icon(Icons.tune),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const RecipeSlider(),

            const SizedBox(height: 24),
            const Text(
              "Categories",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'PlaywriteAUSA'
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
            Row(
              children: const [
                Expanded(
                  child: RecipeCard(
                    title: "New York Cheesecake",
                    image: 'assets/images/cheesecake.jpg',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: RecipeCard(
                    title: "Autumn Pecan Pie",
                    image: 'assets/images/pecan_pie.jpg',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: const [
                Expanded(
                  child: RecipeCard(
                    title: "Vegan Tiramisu 🍰",
                    image: 'assets/images/tiramisu.jpg',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: RecipeCard(
                    title: "Raspberry Cake",
                    image: 'assets/images/raspberry_cake.jpg',
                  ),
                ),
              ],
            ),
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
        CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          child: Icon(icon, color: Colors.pinkAccent),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class RecipeCard extends StatelessWidget {
  final String title;
  final String image;

  const RecipeCard({super.key, required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailPage(title: title, image: image),
          ),
        );
      },
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(image, height: 100, fit: BoxFit.cover),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
