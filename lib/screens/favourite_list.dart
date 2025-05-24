import 'package:btl_flutter_nhom6/screens/recipe_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/search_bar.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Map<String, dynamic>> favoriteRecipes = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final favorites = List<String>.from(userDoc.data()?['favorites'] ?? []);

    final recipesSnapshot = await FirebaseFirestore.instance.collection('recipes').get();

    final favs = recipesSnapshot.docs
        .where((doc) => favorites.contains(doc['title']))
        .map((doc) => doc.data())
        .toList();

    setState(() {
      favoriteRecipes = favs;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lọc theo từ khóa tìm kiếm
    final filteredRecipes = favoriteRecipes.where((recipe) {
      final title = recipe['title']?.toLowerCase() ?? '';
      return title.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Món yêu thích", style: TextStyle(fontSize: 24)),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            RecipeSearch(
              controller: _searchController,
              onSearchChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
            Expanded(
              child: filteredRecipes.isEmpty
                  ? const Center(child: Text('Không tìm thấy món phù hợp.'))
                  : ListView.builder(
                itemCount: filteredRecipes.length,
                itemBuilder: (context, index) {
                  final item = filteredRecipes[index];
                  final bool isAsset = !item['image'].startsWith('http');
                  return Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: isAsset
                            ? Image.asset(item['image'], width: 60, height: 60, fit: BoxFit.cover)
                            : Image.network(item['image'], width: 60, height: 60, fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                        ),
                      ),
                      title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.w500)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => removeFromFavorites(item['title']),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeDetailScreen(
                              title: item['title'],
                              imageUrl: item['image'],
                              time: item['time'],
                              difficulty: item['difficulty'],
                              ytVideo: item['ytVideo'],
                              category: item['category'],
                              ingredients: item['ingredients'],
                              instructions: item['instructions'],
                              detail: item['detail'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> removeFromFavorites(String title) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    await docRef.update({
      'favorites': FieldValue.arrayRemove([title])
    });

    setState(() {
      favoriteRecipes.removeWhere((recipe) => recipe['title'] == title);
    });
  }
}
