import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:btl_flutter_nhom6/screens/recipe_detail_screen.dart';

class RecipeSlider extends StatefulWidget {
  const RecipeSlider({super.key});

  @override
  State<RecipeSlider> createState() => _RecipeSliderState();
}

class _RecipeSliderState extends State<RecipeSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  final int maxSlides = 7;
  List<Map<String, dynamic>> recipes = [];

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  Future<void> _fetchRecipes() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('recipes').get();
    List<Map<String, dynamic>> fetched =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    fetched.shuffle();
    if (fetched.length > maxSlides) {
      fetched = fetched.sublist(0, maxSlides);
    }
    setState(() {
      recipes = fetched;
    });
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients && recipes.isNotEmpty) {
        int nextPage = (_currentPage + 1) % recipes.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentPage = nextPage;
        });
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      height: 368,
      width: double.infinity,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: recipes.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 12,
                  ),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  recipe['image'],
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                recipe['title'] ?? '',
                                                style: const TextStyle(
                                                  fontSize: 26,
                                                  fontFamily: 'Tinos',
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                recipe['tags'] ?? '',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: SizedBox(
                                            height: 50,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.pinkAccent,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (
                                                          _,
                                                        ) => RecipeDetailScreen(
                                                          title:
                                                              recipe['title'],
                                                          imageUrl:
                                                              recipe['image'],
                                                          time: recipe['time'],
                                                          difficulty:
                                                              recipe['difficulty'],
                                                          ytVideo:
                                                              recipe['ytVideo'],
                                                          category:
                                                              recipe['category'],
                                                          ingredients: List<
                                                            String
                                                          >.from(
                                                            recipe['ingredients'] ??
                                                                [],
                                                          ),
                                                          instructions: List<
                                                            String
                                                          >.from(
                                                            recipe['instructions'] ??
                                                                [],
                                                          ),
                                                          detail: List<
                                                            String
                                                          >.from(
                                                            recipe['detail'] ??
                                                                [],
                                                          ),
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: const Text(
                                                "Cook\nnow",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            recipes.length,
                            (index) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),
                              child: InkWell(
                                onTap: () {
                                  _pageController.animateToPage(
                                    index,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.ease,
                                  );
                                },
                                child: CircleAvatar(
                                  radius: 4,
                                  backgroundColor:
                                      _currentPage == index
                                          ? Colors.pinkAccent
                                          : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
