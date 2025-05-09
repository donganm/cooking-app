import 'package:flutter/material.dart';
import 'package:btl_flutter_nhom6/widgets/youtube_video.dart';

class RecipeDetailScreen extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String time;
  final String difficulty;
  final String ytVideo;
  final String category;
  final List<dynamic> ingredients;
  final List<dynamic> instructions;
  final List<dynamic> detail;

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
    final int stepCount = instructions.length.clamp(0, detail.length);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
        title: Text(title, style: const TextStyle(fontSize: 24)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [Icon(Icons.favorite_border), SizedBox(width: 16)],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Banner
            ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child:
                  imageUrl.startsWith('http')
                      ? Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 80),
                      )
                      : Image.asset(
                        imageUrl,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                      ),
            ),

            // Info section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InfoIcon(label: category, icon: Icons.restaurant),
                  InfoIcon(label: time, icon: Icons.timer),
                  InfoIcon(
                    label: difficulty,
                    icon: Icons.local_fire_department,
                  ),
                ],
              ),
            ),

            // YouTube video section
            if (ytVideo.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: YoutubeVideoPlayer(videoUrl: ytVideo),
              ),

            const SizedBox(height: 24),

            // Ingredients
            SectionTitle(title: 'Nguyên liệu'),
            ...ingredients.map((item) {
              return ListTile(
                leading: const Icon(Icons.circle, size: 10),
                title: Text(item, style: const TextStyle(fontSize: 16)),
              );
            }).toList(),

            const SizedBox(height: 24),

            // Instructions
            SectionTitle(title: 'Cách làm'),
            ...List.generate(stepCount, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InstructionTile(
                    title: '${index + 1}. ${instructions[index]}',
                    detail: detail[index],
                  ),
                ),
              );
            }),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class InfoIcon extends StatelessWidget {
  final String label;
  final IconData icon;

  const InfoIcon({super.key, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.pink),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.pinkAccent,
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
      title: Text(
        widget.title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: isExpanded ? Colors.pink : Colors.black,
        ),
      ),
      trailing: Icon(
        isExpanded ? Icons.expand_less : Icons.expand_more,
        color: isExpanded ? Colors.pink : Colors.black,
      ),
      onExpansionChanged: (expanded) {
        setState(() {
          isExpanded = expanded;
        });
      },
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(widget.detail, style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}
