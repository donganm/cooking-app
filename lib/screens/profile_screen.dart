import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:btl_flutter_nhom6/screens/profile_manager/EditProfile_Screen.dart';
import 'package:btl_flutter_nhom6/screens/profile_manager/ChangedPassword_Screen.dart';
import 'package:btl_flutter_nhom6/screens/profile_manager/CheckRecipeStatus.dart';
import 'package:btl_flutter_nhom6/services/user_auth_service.dart';
import 'package:btl_flutter_nhom6/screens/profile_manager/UploadRecipe.dart';
import 'package:btl_flutter_nhom6/screens/login_screen.dart';
import '../widgets/square_card.dart';
import 'favourite_list.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String displayName = "Chef";
  final AuthService _authService = AuthService();

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
      MaterialPageRoute(builder: (_) => const CheckRecipeStatus())
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
    final Color mau = const Color.fromARGB(255, 255, 64, 129);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Trang cá nhân"),
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: mau,
        title: const Text("Trang Profile"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
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
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Yêu thích',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FavoriteScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Tất cả',
                    style: TextStyle(color: Colors.blue, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
          const FavoritedWidget(),
          const SizedBox(height: 24),

          _buildCard(
            title: "Bảo mật",
            color: Colors.green,
            children: [
              _buildTitle(
                Icons.edit,
                "Sửa thông tin",
                () => _onEditProfile(context),
              ),
              _buildTitle(
                Icons.lock,
                "Đổi mật khẩu",
                () => _onChangedPassword(context),
              ),
              _buildTitle(
                Icons.delete_forever,
                "Xóa tài khoản",
                () => _onDeleteAccount(context),
              ),
              _buildTitle(Icons.logout, "Đăng xuất", () => _onLogout(context)),
            ],
          ),

          const SizedBox(height: 16),
          _buildCard(
            title: "Bài đăng",
            color: Colors.deepPurple,
            children: [
              _buildTitle(
                Icons.post_add,
                "Đăng bài mới",
                () => _onPost(context),
              ),
              _buildTitle(Icons.post_add,
               "Trạng thái bài đăng", 
               () => _recipeStatus(context))
            ],
          ),
          const SizedBox(height: 16),
          _buildCard(
            title: "Nếu bạn là Admin/Kiểm duyệt viên",
            color: Colors.lightBlue,
            children: [
              ListTile(
                leading: const Icon(Icons.book, color: Colors.white),
                title: const Text(
                  "Quản lý bài đăng",
                  style: TextStyle(color: Colors.white),
                ),
                trailing: const Icon(Icons.favorite, color: Colors.blue),
                onTap: () async {
                  final url = Uri.parse("https://apicookapp.onrender.com");
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    throw 'Không mở được liên kết $url';
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 9)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTitle(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.yellow),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white,
        size: 16,
      ),
      onTap: onTap,
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
