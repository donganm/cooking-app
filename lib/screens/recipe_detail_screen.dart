import 'package:flutter/material.dart';
import 'package:btl_flutter_nhom6/widgets/youtube_video.dart';

class RecipeDetailScreen extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String time;
  final String difficulty;
  final String ytVideo;
  final String category;
  final List<String> ingredients;
  final List<String> instructions;
  final List<String> detail;

  const RecipeDetailScreen({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.time,
    required this.difficulty,
    required this.ytVideo,
    required this.category,
    required this.ingredients,
    required this.instructions,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(title, style: TextStyle(fontSize: 28)),
        centerTitle: true,
        actions: [Icon(Icons.favorite_border), SizedBox(width: 16)],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Row(
                    children: [
                      SizedBox(height: 10),
                      Expanded(
                          flex: 1,
                          child: Column(
                              children: [
                                Icon(Icons.restaurant, size: 30),
                                Text(category, style: TextStyle(fontSize: 15)),
                              ]
                          )
                      ),
                      Expanded(
                          flex: 1,
                          child: Column(
                              children: [
                                Icon(Icons.timer, size: 30),
                                Text(time, style: TextStyle(fontSize: 15)),
                              ]
                          )
                      ),
                      Expanded(
                          flex: 1,
                          child: Column(
                              children: [
                                Icon(Icons.local_fire_department, size: 30),
                                Text(difficulty, style: TextStyle(fontSize: 15)),
                              ]
                          )
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  YoutubeVideoPlayer(videoUrl: ytVideo),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Ingredients', style: TextStyle(fontSize: 25, color: Colors.pinkAccent, fontWeight: FontWeight.bold, fontFamily: 'PlaywriteAUSA')),
                ],
              ),
            ),
            Column(
              children:[
                ...List.generate(ingredients.length, (index) {
                  final backgroundColor = index.isEven ? Colors.grey[200] : Colors.white;
                  return Container(
                    color: backgroundColor,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              ' ${ingredients[index]}',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ]
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Instructions', style: TextStyle(fontSize: 25, color: Colors.pinkAccent, fontWeight: FontWeight.bold, fontFamily: 'PlaywriteAUSA')),
                  ...List.generate(instructions.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Card(
                        elevation: 8,
                        child: InstructionTile(
                          title: '${index + 1}. ${instructions[index]}',
                          detail: detail[index],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InstructionTile extends StatefulWidget {
  final String title;
  final String detail;

  const InstructionTile({super.key, required this.title, required this.detail});

  @override
  State<InstructionTile> createState() => _InstructionTileState();
}

class _InstructionTileState extends State<InstructionTile> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: isExpanded ? Colors.pinkAccent : Colors.white,
      collapsedBackgroundColor: Colors.white,
      onExpansionChanged: (expanded) {
        setState(() {
          isExpanded = expanded;
        });
      },
      title: Text(
        widget.title,
        style: TextStyle(
          fontSize: 20,
          color: isExpanded ? Colors.white : Colors.black,
        ),
      ),
      children: [
        Container(
          padding: EdgeInsets.all(16),
          alignment: Alignment.centerLeft,
          child: Text(
            widget.detail,
            style: TextStyle(
              color: isExpanded ? Colors.white : Colors.black,
              fontSize: 18
            ),
          ),
        ),
      ],
    );
  }
}