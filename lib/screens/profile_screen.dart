import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:btl_flutter_nhom6/screens/profile_manager/EditProfile_Screen.dart';
import 'package:btl_flutter_nhom6/screens/profile_manager/ChangedPassword_Screen.dart';
import 'package:btl_flutter_nhom6/screens/profile_manager/CheckRecipeStatus.dart';
import 'package:btl_flutter_nhom6/screens/profile_manager/UploadRecipe.dart';
import 'package:btl_flutter_nhom6/screens/login_screen.dart';
import 'package:btl_flutter_nhom6/services/user_auth_service.dart';
import 'package:btl_flutter_nhom6/screens/favourite_list.dart';
import '../widgets/square_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String displayName = "Chef";
  final AuthService _authService = AuthService();
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await _authService.getUserData();
    if (userData != null &&
        userData['fullname'] != null &&
        userData['fullname'].toString().isNotEmpty) {
      setState(() {
        displayName = userData['fullname'];
      });
    }
  }

  Future<void> _onEditProfile(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
    await _loadUserData();
  }

  void _onChangedPassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChangedPasswordScreen()),
    );
  }

  void _onDeleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Xóa tài khoản"),
            content: Text(
              "Bạn có chắc chắn muốn xóa tài khoản email:\n${user?.email}?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text("Hủy"),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text("Xóa"),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    try {
      await user?.delete();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } on FirebaseAuthException catch (e) {
      String message = "Đã xảy ra lỗi.";
      if (e.code == 'requires-recent-login') {
        message = "Vui lòng đăng nhập lại trước khi xóa tài khoản.";
      }

      showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text("Lỗi"),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    }
  }

  void _onPost(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UploadRecipe()),
    );
  }

  void _recipeStatus(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CheckRecipeStatus()),
    );
  }

  void _onLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Xác nhận đăng xuất"),
            content: const Text("Bạn có chắc chắn muốn đăng xuất không?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text("Hủy"),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text("Đăng xuất"),
              ),
            ],
          ),
    );
    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final backgroundGradient =
        isDarkMode
            ? const LinearGradient(
              colors: [
                Color.fromARGB(255, 5, 6, 6),
                Color.fromARGB(255, 70, 38, 135),
                Color.fromARGB(255, 157, 113, 113),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
            : const LinearGradient(
              colors: [
                Color.fromARGB(255, 72, 163, 116),
                Color.fromARGB(255, 153, 98, 156),
                Color.fromARGB(255, 81, 72, 3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            );

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Trang profile",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.pink,
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
            child: const Text("Đăng nhập để tiếp tục"),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: const Text(
          "Trang Profile",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        "https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/User_icon_2.svg/640px-User_icon_2.svg.png",
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Tên người dùng: $displayName",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _glassCard(
                child: Column(
                  children: [
                    _sectionTitle(
                      "Yêu thích",
                      action: "Tất cả",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FavoriteScreen(),
                          ),
                        );
                      },
                    ),
                    const FavoritedWidget(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _glassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Bảo mật"),
                    _buildTile(
                      Icons.edit,
                      "Sửa thông tin",
                      () => _onEditProfile(context),
                    ),
                    _buildTile(
                      Icons.lock,
                      "Đổi mật khẩu",
                      () => _onChangedPassword(context),
                    ),
                    _buildTile(
                      Icons.delete_forever,
                      "Xóa tài khoản",
                      () => _onDeleteAccount(context),
                    ),
                    _buildTile(
                      Icons.logout,
                      "Đăng xuất",
                      () => _onLogout(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _glassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Bài đăng"),
                    _buildTile(
                      Icons.post_add,
                      "Đăng bài mới",
                      () => _onPost(context),
                    ),
                    _buildTile(
                      Icons.visibility,
                      "Trạng thái bài đăng",
                      () => _recipeStatus(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _glassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Admin/Kiểm duyệt viên"),
                    ListTile(
                      leading: const Icon(
                        Icons.book,
                        color: Color.fromARGB(255, 0, 168, 89),
                      ),
                      title: const Text(
                        "Quản lý bài đăng",
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () async {
                        final url = Uri.parse(
                          "https://apicookapp.onrender.com",
                        );
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isDarkMode = !isDarkMode;
                    });
                  },
                  child: Text(
                    isDarkMode
                        ? "Chuyển sang Rgb light mode"
                        : "Chuyển sang Pro Mode",
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          padding: const EdgeInsets.all(12),
          child: child,
        ),
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color.fromARGB(255, 4, 192, 32)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _sectionTitle(String title, {String? action, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (action != null && onTap != null)
            GestureDetector(
              onTap: onTap,
              child: Text(
                action,
                style: const TextStyle(color: Colors.blue, fontSize: 15),
              ),
            ),
        ],
      ),
    );
  }
}

class FavoritedWidget extends StatefulWidget {
  const FavoritedWidget({super.key});

  @override
  State<FavoritedWidget> createState() => _FavoritedWidgetState();
}

class _FavoritedWidgetState extends State<FavoritedWidget> {
  List<Map<String, dynamic>> _randomFavorites = [];

  @override
  void initState() {
    super.initState();
    loadRandomFavorites();
  }

  Future<void> loadRandomFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    final favorites = List<String>.from(userDoc.data()?['favorites'] ?? []);

    if (favorites.isEmpty) return;

    final allRecipesSnapshot =
        await FirebaseFirestore.instance.collection('recipes').get();
    final allFavorites =
        allRecipesSnapshot.docs
            .where((doc) => favorites.contains(doc['title']))
            .map((doc) => doc.data())
            .toList();

    allFavorites.shuffle();
    setState(() {
      _randomFavorites = allFavorites.take(3).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_randomFavorites.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_randomFavorites.length, (index) {
        final item = _randomFavorites[index];
        return Expanded(
          child: Container(
            height: 150,
            margin: const EdgeInsets.all(3),
            child: SquareRecipeCard(item: item),
          ),
        );
      }),
    );
  }
}
