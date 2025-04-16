import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            const SizedBox(height: 12),
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(
                    'assets/images/profile.jpg',
                  ), // ảnh avatar demo
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Hello, ${user?.email?.split('@')[0] ?? "Chef"}!",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "What are we cooking today?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Ex: Veggie Burger',
                suffixIcon: const Icon(Icons.tune),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Recipe of the day",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset('assets/images/risotto.jpg'), // ảnh demo
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Creamy Fungi Risotto 🍄",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text("Healthy • Vegetarian • Lunch"),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text("Cook now"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Categories",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          child: Icon(icon, color: Colors.green),
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
    return Column(
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
    );
  }
}
