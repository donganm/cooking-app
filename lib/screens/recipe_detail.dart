import 'package:flutter/material.dart';

class RecipeDetailPage extends StatelessWidget {
  final String title;
  final String image;

  const RecipeDetailPage({super.key, required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Quay lại trang trước
          },
        ),
        title: const Text('Creamy Funghi Risotto'),
        centerTitle: true,
        actions: const [Icon(Icons.favorite_border), SizedBox(width: 16)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time, Difficulty, Serving
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _InfoCard(icon: Icons.timer, text: "30 min"),
                _InfoCard(icon: Icons.emoji_emotions, text: "Easy"),
                _InfoCard(icon: Icons.restaurant, text: "4 servings"),
              ],
            ),
            const SizedBox(height: 20),
            // Image with Play button
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    'assets/images/risotto.jpg',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const CircleAvatar(
                  backgroundColor: Colors.white70,
                  child: Icon(Icons.play_arrow, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Ingredients Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ingredients',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        '4 servings',
                        style: TextStyle(color: Colors.pinkAccent),
                      ),
                      Icon(Icons.add, size: 16, color: Colors.pinkAccent),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _IngredientList(),
            const SizedBox(height: 30),
            // Preparation Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Preparation',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Text(
                    '10 min',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _PreparationSteps(),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoCard({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.pinkAccent),
        const SizedBox(height: 8),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

class _IngredientList extends StatelessWidget {
  final List<Map<String, String>> ingredients = const [
    {'name': 'Arborio rice', 'amount': '250g'},
    {'name': 'Chicken stock', 'amount': '1L'},
    {'name': 'Minced garlic', 'amount': '20g'},
    {'name': 'Yellow onion', 'amount': '20g'},
    {'name': 'White mushrooms', 'amount': '150g'},
    {'name': 'Parmigiano cheese', 'amount': '10g'},
    {'name': 'Olive oil', 'amount': '100ml'},
  ];

  const _IngredientList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          ingredients.map((ingredient) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ingredient['name']!,
                    style: const TextStyle(fontSize: 15),
                  ),
                  Text(
                    ingredient['amount']!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}

class _PreparationSteps extends StatefulWidget {
  const _PreparationSteps();

  @override
  State<_PreparationSteps> createState() => _PreparationStepsState();
}

class _PreparationStepsState extends State<_PreparationSteps> {
  final List<Map<String, String>> steps = const [
    {
      'title': 'In a small pot, heat up oil.',
      'details':
          'Use medium heat and stir occasionally until the oil is evenly heated.',
    },
    {
      'title': 'Add chopped onion and garlic.',
      'details':
          'Sauté until fragrant and onions are translucent, about 3-4 minutes.',
    },
    {
      'title': 'Pour in the chicken broth.',
      'details':
          'Gradually add broth while stirring continuously to avoid lumps.',
    },
    {
      'title': 'Stir until absorbed.',
      'details':
          'Keep stirring gently until the broth is fully absorbed by the rice.',
    },
  ];

  late List<bool> isExpanded;

  @override
  void initState() {
    super.initState();
    isExpanded = List.filled(steps.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            initiallyExpanded: isExpanded[index],
            onExpansionChanged: (expanded) {
              setState(() {
                isExpanded[index] = expanded;
              });
            },
            leading: CircleAvatar(
              backgroundColor: Colors.pinkAccent,
              child: Text(
                '${index + 1}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(step['title']!),
            trailing:
                isExpanded[index]
                    ? const Icon(Icons.keyboard_arrow_up)
                    : const Icon(Icons.play_arrow),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(step['details']!),
              ),
            ],
          ),
        );
      }),
    );
  }
}
