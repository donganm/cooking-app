import 'package:flutter/material.dart';
import 'package:btl_flutter_nhom6/tabs/all_orders_tab.dart';
import 'package:btl_flutter_nhom6/tabs/saved_order_tab.dart';
import 'package:btl_flutter_nhom6/tabs/my_dishes_tab.dart';

import 'package:btl_flutter_nhom6/tabs/drafts_tab.dart';

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

              Tab(text: "Món nháp"),
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
            SavedOrderTab(),
            MyDishesTab(),

            DraftsTab(),
          ],
        ),
      ),
    );
  }
}
