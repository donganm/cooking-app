import 'package:btl_flutter_nhom6/tabs/liked_post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:btl_flutter_nhom6/tabs/all_orders_tab.dart';
import 'package:btl_flutter_nhom6/tabs/saved_order_tab.dart';
import 'package:btl_flutter_nhom6/tabs/my_dishes_tab.dart';
import 'package:btl_flutter_nhom6/tabs/drafts_tab.dart';
import 'login_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nhóm',
      theme: ThemeData(primarySwatch: Colors.deepOrange, fontFamily: 'Roboto'),
      home: OrderPage(),
    );
  }
}

class OrderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Trang profile"), centerTitle: true, backgroundColor: Colors.pink),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
            },
            child: const Text("Đăng nhập để tiếp tục"),
          ),
        ),
      );
    }
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
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(width: 3.0, color: Colors.white),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(child: Text("Tất cả", style: TextStyle(fontSize: 17))),
              Tab(child: Text("Đã thích", style: TextStyle(fontSize: 17))),
              Tab(child: Text("Bài đăng", style: TextStyle(fontSize: 17))),
              Tab(child: Text("Nháp", style: TextStyle(fontSize: 17))),
            ],
          ),
          backgroundColor: Colors.pinkAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          // actions: [IconButton(icon: Icon(Icons.search), onPressed: () {})],
        ),
        body: TabBarView(
          children: [
            AllOrdersTab(),
            LikedPost(),
            MyDishesTab(),
            DraftsTab(),
          ],
        ),
      ),
    );
  }
}
