import 'package:cloud_firestore/cloud_firestore.dart';

final List<Map<String, dynamic>> recipeList = [
  {
    'title': 'Phở Bò',
    'image': 'assets/images/pho_bo.jpg',
    'tags': 'Lành mạnh • Bò • Bữa trưa',
    'category': 'Món chính',
    'time': '1.5 - 2 giờ',
    'difficulty': 'Trung bình',
    'ytVideo': 'https://www.youtube.com/watch?v=QYP47Kl4Z5g',
    'ingredients': [
      '500g bắp bò hoặc thịt bò',
      '300g xương bò',
      '2 củ hành tây',
      '1 củ gừng',
      '1 nhánh hoa hồi',
      '2 thanh quế',
      '3 hạt đinh hương',
      '1 muỗng cà phê hạt thìa là',
      '500g bánh phở',
      'Rau thơm (húng quế, ngò)',
      'Chanh, ớt, giá đỗ, hoisin và nước mắm để ăn kèm',
    ],
    'instructions': [
      'Nấu nước dùng',
      'Chần xương và thịt bò',
      'Nấu nước dùng với gia vị',
      'Luộc bánh phở',
      'Chuẩn bị tô phở',
      'Dùng với rau thơm và gia vị',
    ],
    'detail': [
      'Rửa xương bò và thịt bò, chần qua nước sôi rồi nấu với hành tây, gừng và gia vị trong 1–1.5 giờ',
      'Vớt thịt và lọc nước dùng, sau đó nấu lại nước dùng trong 30 phút nữa',
      'Luộc bánh phở theo hướng dẫn và rửa lại với nước lạnh',
      'Thái thịt bò mỏng và xếp vào tô, đổ nước dùng nóng lên trên',
      'Thêm rau thơm, giá đỗ, chanh, ớt và hoisin để ăn kèm',
    ],
  },
  {
    'title': 'Bánh Xèo',
    'image': 'assets/images/banh_xeo.jpg',
    'tags': 'Lành mạnh • Mặn • Món ăn vặt',
    'category': 'Món khai vị',
    'time': '1 giờ',
    'difficulty': 'Trung bình',
    'ytVideo': 'https://www.youtube.com/watch?v=Yhp5qY9_ZT8',
    'ingredients': [
      '200g bột gạo',
      '100ml nước cốt dừa',
      '300g thịt ba chỉ hoặc tôm',
      '1 củ hành tây, thái mỏng',
      '100g giá đỗ',
      'Rau thơm (húng quế, ngò)',
      'Lá xà lách',
      'Nước mắm để chấm',
    ],
    'instructions': [
      'Làm bột bánh',
      'Nấu thịt hoặc tôm',
      'Chiên bánh',
      'Ăn kèm với rau thơm',
    ],
    'detail': [
      'Trộn bột gạo với nước và nước cốt dừa thành bột mịn',
      'Nấu thịt hoặc tôm cho vàng và thơm, rồi để riêng',
      'Làm nóng chảo, đổ bột vào chiên đến khi bánh giòn, sau đó cho thịt hoặc tôm và giá đỗ vào',
      'Gập đôi bánh và dùng kèm với rau sống, chấm nước mắm',
    ],
  },
  {
    'title': 'Bún Chả',
    'image': 'assets/images/bun_cha.jpg',
    'tags': 'Lành mạnh • Thịt lợn • Bữa trưa',
    'category': 'Món chính',
    'time': '1 giờ',
    'difficulty': 'Trung bình',
    'ytVideo': 'https://www.youtube.com/watch?v=Oj5FvsD9DC0',
    'ingredients': [
      '300g thịt lợn xay',
      '200g thịt ba chỉ',
      '100g bún tươi',
      '2 tép tỏi',
      '2 muỗng canh nước mắm',
      '1 muỗng canh đường',
      '1 muỗng canh giấm',
      'Rau thơm (húng quế, ngò)',
      'Dưa món (cà rốt, củ cải)',
    ],
    'instructions': [
      'Ướp thịt',
      'Nướng thịt ba chỉ và viên thịt lợn',
      'Làm nước mắm chấm',
      'Ăn kèm với bún',
    ],
    'detail': [
      'Trộn thịt lợn xay với tỏi, nước mắm, đường và gia vị, tạo thành những viên thịt',
      'Nướng thịt ba chỉ và viên thịt cho đến khi chín và vàng',
      'Làm nước mắm bằng cách pha nước mắm, đường, giấm và nước, thêm dưa món',
      'Dùng bún với thịt nướng, rau thơm và nước mắm để chấm',
    ],
  },
  {
    'title': 'Gỏi Cuốn',
    'image': 'assets/images/goi_cuon.jpg',
    'tags': 'Lành mạnh • Tươi • Món ăn vặt',
    'category': 'Món khai vị',
    'time': '30 phút',
    'difficulty': 'Dễ',
    'ytVideo': 'https://www.youtube.com/watch?v=zr-8d-jPfbY',
    'ingredients': [
      'Bánh tráng',
      '100g tôm, luộc và bóc vỏ',
      '100g bún tươi',
      'Rau sống (húng quế, ngò)',
      'Cà rốt, thái sợi',
      'Dưa leo, thái sợi',
      'Nước chấm đậu phộng',
    ],
    'instructions': [
      'Chuẩn bị nguyên liệu',
      'Ngâm bánh tráng',
      'Cuốn gỏi',
      'Ăn kèm với nước chấm',
    ],
    'detail': [
      'Luộc tôm và thái nhỏ',
      'Ngâm bánh tráng vào nước ấm cho mềm',
      'Xếp rau sống, bún, cà rốt, dưa leo và tôm lên bánh tráng rồi cuốn chặt lại',
      'Dùng gỏi cuốn với nước chấm đậu phộng hoặc nước mắm chua ngọt',
    ],
  },
  {
    'title': 'Chè Ba Màu',
    'image': 'assets/images/che_ba_mau.jpg',
    'tags': 'Món tráng miệng • Ngọt • Mát lạnh',
    'category': 'Món tráng miệng',
    'time': '1 giờ',
    'difficulty': 'Trung bình',
    'ytVideo': 'https://www.youtube.com/watch?v=Hg74JmjOG2s',
    'ingredients': [
      'Đậu xanh',
      'Đậu đỏ',
      'Nước cốt dừa',
      'Thạch (bột agar hoặc bột rau câu)',
      'Đường',
      'Đá viên',
    ],
    'instructions': ['Nấu đậu xanh', 'Nấu đậu đỏ', 'Làm thạch', 'Xếp chè'],
    'detail': [
      'Nấu đậu xanh mềm và xay nhuyễn thành một lớp mịn',
      'Nấu đậu đỏ đến khi mềm và thêm đường cho ngọt',
      'Làm thạch bằng cách hòa tan bột agar với nước và đun sôi, để nguội rồi cắt thành miếng nhỏ',
      'Xếp các lớp đậu xanh, đậu đỏ, thạch và nước cốt dừa vào cốc, thêm đá viên và thưởng thức',
    ],
  },

  // Thêm các món khác nếu muốn
];

Future<void> uploadRecipesToFirestore() async {
  final CollectionReference recipesRef = FirebaseFirestore.instance.collection(
    'recipes',
  );

  for (var recipe in recipeList) {
    await recipesRef.add(recipe);
  }

  print('✅ Dữ liệu đã được upload thành công lên Firestore!');
}
