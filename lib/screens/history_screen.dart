import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Đơn hàng',
      theme: ThemeData(primarySwatch: Colors.deepOrange, fontFamily: 'Roboto'),
      home: OrderPage(),
    );
  }
}

class OrderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Cookpad"),
          centerTitle: true,
          bottom: TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black54,
            tabs: [
              Tab(text: "Tất cả"),
              Tab(text: "Đã lưu"),
              Tab(text: "Món của tôi"),
              Tab(text: "Đánh giá"),
              Tab(text: "Món nháp"),
            ],
          ),
          backgroundColor: Colors.pinkAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          // actions: [IconButton(icon: Icon(Icons.search), onPressed: () {})],
        ),
        body: TabBarView(
          children: List.generate(5, (index) => buildEmptyOrderTab()),
        ),
      ),
    );
  }

  Widget buildEmptyOrderTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 16),
      child: Column(
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.orange),
          SizedBox(height: 16),
          Text(
            "Quên chưa đặt món rồi nè bạn ơi?",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            "Bạn sẽ nhìn thấy các món đang được chuẩn bị hoặc giao đi tại đây để kiểm tra đơn hàng nhanh hơn!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
          SizedBox(height: 30),
          Divider(),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Có thể bạn cũng thích",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 12),
          // buildSuggestedItem(
          //   imageUrl:
          //       'https://via.placeholder.com/60', // thay bằng ảnh thật nếu có
          //   title: 'Hà Anh - Bánh Mì Doner Kebab',
          //   rating: 4.6,
          //   time: '22 phút',
          //   distance: '0.1km',
          // ),
          // buildSuggestedItem(
          //   imageUrl: 'https://via.placeholder.com/60',
          //   title: 'Mr.TukTuk - Trà Sữa Thái Lan - Phố Viên',
          //   rating: 4.8,
          //   time: '22 phút',
          //   distance: '0.1km',
          //   favorite: true,
          // ),
        ],
      ),
    );
  }

  Widget buildSuggestedItem({
    required String imageUrl,
    required String title,
    required double rating,
    required String time,
    required String distance,
    bool favorite = false,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Image.network(
          imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
        title: Text(title),
        subtitle: Row(
          children: [
            Icon(Icons.star, color: Colors.orange, size: 16),
            SizedBox(width: 4),
            Text("$rating"),
            SizedBox(width: 10),
            Text(distance),
            SizedBox(width: 10),
            Text(time),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (favorite)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "Yêu thích",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.redAccent),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "Mã giảm 20%",
                style: TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
