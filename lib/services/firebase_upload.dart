import 'package:cloud_firestore/cloud_firestore.dart';

final List<Map<String, dynamic>> recipeList = [
  {
    "title": "Canh chua cá",
    "description": "Một món ăn dân dã miền Tây, ngon và dễ làm.",
    "createdBy": "user_abc123",
    "createdAt": {"_seconds": 1716950000, "_nanoseconds": 0},
    "imageUrl": "https://your-storage-url.com/image1.jpg",
    "likes": ["user_123", "user_456"],
    "commentsCount": 2,
  },
  {
    "title": "Bún bò Huế",
    "description": "Món ăn đậm đà hương vị Huế, thơm ngon và cay nhẹ.",
    "createdBy": "user_xyz789",
    "createdAt": {"_seconds": 1716950050, "_nanoseconds": 0},
    "imageUrl": "https://your-storage-url.com/image2.jpg",
    "likes": ["user_123"],
    "commentsCount": 5,
  },
  {
    "title": "Chè bưởi",
    "description": "Món chè thanh mát, thích hợp cho ngày hè.",
    "createdBy": "user_mno456",
    "createdAt": {"_seconds": 1716950100, "_nanoseconds": 0},
    "imageUrl": "https://your-storage-url.com/image3.jpg",
    "likes": [],
    "commentsCount": 0,
  },

  // Thêm các món khác nếu muốn
];

Future<void> uploadRecipesToFirestore() async {
  final CollectionReference recipesRef = FirebaseFirestore.instance.collection(
    'community_recipes',
  );

  for (var recipe in recipeList) {
    await recipesRef.add(recipe);
  }

  print('✅ Dữ liệu đã được upload thành công lên Firestore!');
}
