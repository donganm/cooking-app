import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:btl_flutter_nhom6/widgets/youtube_video.dart';
import 'list_holder.dart';

class RecipeDetailScreen extends StatefulWidget {
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
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> with SingleTickerProviderStateMixin {
  bool isFavorite = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    checkIfFavorite();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> checkIfFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final favorites = List<String>.from(doc.data()?['favorites'] ?? []);
    setState(() {
      isFavorite = favorites.contains(widget.title);
    });
  }

  Future<void> toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    if (isFavorite) {
      await docRef.update({
        'favorites': FieldValue.arrayRemove([widget.title])
      });
    } else {
      await docRef.set({
        'favorites': FieldValue.arrayUnion([widget.title])
      }, SetOptions(merge: true));
    }

    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    final int stepCount = widget.instructions.length.clamp(0, widget.detail.length);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
        title: Text(widget.title, style: const TextStyle(fontSize: 24)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: toggleFavorite,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: widget.imageUrl.startsWith('http')
                      ? Image.network(
                    widget.imageUrl,
                    width: double.infinity,
                    height: 170,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 80),
                  )
                      : Image.asset(
                    widget.imageUrl,
                    width: double.infinity,
                    height: 170,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(0.0),
                        ],
                        stops: [0.0, 0.4],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InfoIcon(label: widget.category, icon: categoryIcons[widget.category] ?? Icons.restaurant),
                  InfoIcon(label: widget.time, icon: Icons.timer),
                  InfoIcon(label: widget.difficulty, icon: Icons.local_fire_department),
                ],
              ),
            ),

            if (widget.ytVideo.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: YoutubeVideoPlayer(videoUrl: widget.ytVideo),
              ),

            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                controller: _tabController,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 3.0, color: Colors.pinkAccent),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.pinkAccent,
                unselectedLabelColor: Colors.black,
                tabs: const [
                  Tab(child: Text('Nguyên liệu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'PlaywriteAUSA',))),
                  Tab(child: Text('Cách làm', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'PlaywriteAUSA',))),
                ],
              ),
            ),

            SizedBox(
              height: 400,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Ingredients List
                  ListView.builder(
                    itemCount: widget.ingredients.length,
                    itemBuilder: (context, index) {
                      final bgColor = index.isEven ? Colors.grey[200] : Colors.white;
                      return Container(
                        color: bgColor,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Text(
                          widget.ingredients[index],
                          style: const TextStyle(fontSize: 18),
                        ),
                      );
                    },
                  ),

                  // Instructions List
                  ListView.builder(
                    itemCount: stepCount,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InstructionTile(
                            step: 'Bước ${index + 1}: ${widget.instructions[index]}',
                            detail: widget.detail[index],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
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

class InstructionTile extends StatefulWidget {
  final String step;
  final String detail;

  const InstructionTile({super.key, required this.step, required this.detail});

  @override
  State<InstructionTile> createState() => _InstructionTileState();
}

class _InstructionTileState extends State<InstructionTile> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: Colors.pinkAccent,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Text(
              widget.step,
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Text(
              widget.detail,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ]
      ),
    );
  }
}