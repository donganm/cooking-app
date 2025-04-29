import 'package:flutter/material.dart';
import 'recipe_data.dart';
import 'recipe_detail_screen.dart';
import 'package:btl_flutter_nhom6/widgets/recipe_card.dart';
import 'package:btl_flutter_nhom6/widgets/category.dart';

class ShoplistScreen extends StatelessWidget {
  const ShoplistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping list'),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.all(15.0), child: Category()),
      ),
    );
  }
}
