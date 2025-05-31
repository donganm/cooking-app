import 'package:flutter/material.dart';
import 'package:btl_flutter_nhom6/screens/search_screen.dart';
import 'package:btl_flutter_nhom6/screens/shoplist_screen.dart';
import 'package:btl_flutter_nhom6/screens/home_page.dart';
import 'package:btl_flutter_nhom6/screens/history_screen.dart';
import 'package:btl_flutter_nhom6/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const HomePage(),
    SearchScreen(),
    // const ShoplistScreen(),
    OrderPage(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Nền màu trắng sáng
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(
          0xFF1E2A38,
        ), // Màu xanh đen nhạt cho phần được chọn
        unselectedItemColor:
            Colors.grey.shade600, // Màu xám cho phần không được chọn
        showUnselectedLabels:
            true, // Hiển thị nhãn cho các item không được chọn
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        backgroundColor: Colors.white, // Nền của BottomNavigationBar là trắng
        elevation: 10, // Độ nổi của thanh điều hướng
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          // BottomNavigationBarItem(icon: Icon(Icons.shopping_bag),label: 'Món mới'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Kho món'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
        ],
      ),
    );
  }
}
