import 'package:flutter/material.dart';

class RecipeDetailScreen extends StatelessWidget {
  final String title;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> instructions;

  const RecipeDetailScreen({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.ingredients,
    required this.instructions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(backgroundColor: Colors.pinkAccent,foregroundColor: Colors.white,title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child:
                Image.asset(
                  imageUrl,
                  height: 380,
                  width: double.infinity,
                  fit: BoxFit.cover,),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              child: SizedBox(
                width: double.infinity,
                child: ExpansionTile(
                  collapsedBackgroundColor: Colors.pinkAccent,
                  backgroundColor: Colors.pinkAccent,
                  title: const Text('Ingredients', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  children: <Widget>[
                    Column(
                      children: [
                        ...ingredients.map((item) => SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('‣ ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.lightGreenAccent,),
                                ),
                                Expanded(
                                  child: Text(item, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              color: Colors.pinkAccent,
              child: Column(
                children: [
                  Text(
                    'Instructions',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  ...List.generate(instructions.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ' ${index + 1}. ',
                            style: TextStyle(fontSize: 18, color: Colors.lightGreenAccent, fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                            child: Text(
                              ' ${instructions[index]}',
                              style: TextStyle(fontSize: 18, color: Colors.white),

                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            )


          ],
        ),
      ),
    );
  }
}