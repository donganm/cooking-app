import 'package:flutter/material.dart';

class CookingStepPage extends StatefulWidget {
  const CookingStepPage({super.key});

  @override
  State<CookingStepPage> createState() => _CookingStepPageState();
}

class _CookingStepPageState extends State<CookingStepPage> {
  int currentStep = 2; // Bắt đầu ở Step 3 (index = 2)

  final List<Map<String, dynamic>> steps = [
    {
      'title': 'Step 1',
      'description':
          'Prepare all ingredients: Parmigiano cheese, unsalted butter, black pepper, kosher salt, mushrooms, and chicken broth.',
      'image': 'assets/images/cheesecake.jpg',
    },
    {
      'title': 'Step 2',
      'description':
          'Heat the medium pot and melt a bit of butter. Add mushrooms and cook until soft.',
      'image': 'assets/images/pecan_pie.jpg',
    },
    {
      'title': 'Step 3',
      'description':
          'Once the chicken broth is absorbed, add Kosher salt and black pepper and stir it with rice and mushrooms. Slowly add grated Parmigiano cheese and stir until well combined. Add small block of butter to enhance the texture of risotto.',
      'image': 'assets/images/risotto.jpg',
    },
    {
      'title': 'Step 4',
      'description':
          'Taste and adjust seasoning if needed. Continue stirring until risotto reaches creamy consistency.',
      'image': 'assets/images/raspberry_cake.jpg',
    },
    {
      'title': 'Step 5',
      'description':
          'Serve hot, garnish with extra cheese and freshly ground black pepper. Enjoy!',
      'image': 'assets/images/tiramisu.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Back button
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(
                      context,
                    ); // Quay về trang trước (Recipe Detail)
                  },
                ),
              ],
            ),
            // Image with Play button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      steps[currentStep]['image'],
                      height: 180,
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
            ),
            const SizedBox(height: 16),
            // Ingredients and Tools
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.restaurant_menu),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Parmigiano cheese, Unsalted butter, Black pepper, Kosher salt',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.kitchen),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Medium pot, Wooden spoon, Cheese grater',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Step description
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      steps[currentStep]['title'],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      steps[currentStep]['description'],
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Page Indicator
                        Row(
                          children: List.generate(5, (index) {
                            bool isActive = (index == currentStep);
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    currentStep = index;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:
                                        isActive
                                            ? Colors.lightGreen
                                            : Colors.white,
                                    border: Border.all(
                                      color: Colors.lightGreen,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color:
                                          isActive
                                              ? Colors.white
                                              : Colors.black,
                                      fontWeight:
                                          isActive
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        // Proceed button
                        TextButton(
                          onPressed: () {
                            setState(() {
                              if (currentStep < 4) {
                                currentStep++;
                              }
                            });
                          },
                          child: const Row(
                            children: [
                              Text('Proceed'),
                              SizedBox(width: 5),
                              Icon(Icons.arrow_forward),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
