import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
<<<<<<< Updated upstream

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  void _onEditProfile() {} //them cn sau khi co db
  void _onChangedPassword() {}
  void _onDeleteAccount() {}
  void _onLogout() {}
=======
import 'package:btl_flutter_nhom6/screens/profile_manager/EditProfile_Screen.dart';
import 'package:btl_flutter_nhom6/screens/profile_manager/ChangedPassword_Screen.dart';
import '../widgets/square_card.dart';
import 'favourite_list.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  void _onEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
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

>>>>>>> Stashed changes
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final Color mau = const Color.fromARGB(255, 255, 64, 129);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: mau,
        title: const Text("Trang Profile"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
<<<<<<< Updated upstream
                const CircleAvatar(radius: 50, backgroundColor: Colors.red),
                const SizedBox(height: 10),
                const Text(
                  "Tên người dùng",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
=======
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    "https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/User_icon_2.svg/640px-User_icon_2.svg.png",
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Tên người dùng: ${user != null && user.email != null ? user.email!.split('@')[0] : "Chef"}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
>>>>>>> Stashed changes
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
<<<<<<< Updated upstream
=======

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Yêu thích',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FavoriteScreen()),
                    );
                  },
                  child: Text(
                    'Tất cả',
                    style: TextStyle(color: Colors.blue, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
          const FavoritedWidget(),
          const SizedBox(height: 24),
>>>>>>> Stashed changes
          _buildCard(
            title: "Bảo mật",
            color: Colors.green,
            children: [
<<<<<<< Updated upstream
              _buildTitle(Icons.edit, "Sửa thông tin", _onEditProfile),
              _buildTitle(Icons.lock, "Đổi mật khẩu ", _onChangedPassword),
              _buildTitle(
                Icons.delete_forever,
                "Xóa tài khoản",
                _onDeleteAccount,
              ),
              _buildTitle(Icons.logout, "Đăng xuất", _onLogout),
=======
              _buildTitle(Icons.edit, "Sửa thông tin", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
              }),
              _buildTitle(Icons.lock, "Đổi mật khẩu", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChangedPasswordScreen(),
                  ),
                );
              }),
              _buildTitle(
                Icons.delete_forever,
                "Xóa tài khoản",
                () => _onDeleteAccount(context),
              ),
              _buildTitle(Icons.logout, "Đăng xuất", () => _onLogout(context)),
>>>>>>> Stashed changes
            ],
          ),
          const SizedBox(height: 16),
          _buildCard(
            title: "Sách nấu ăn yêu thích",
            color: Colors.lightBlue,
            children: [
              ListTile(
                leading: Icon(Icons.book, color: Colors.white),
                title: Text("Tiramisu", style: TextStyle(color: Colors.white)),
                trailing: Icon(Icons.favorite, color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildCard(
            title: "Ưu dãi",
            color: const Color.fromARGB(255, 76, 190, 70),
            children: [
              ListTile(
                leading: Icon(Icons.local_offer, color: Colors.white),
                title: Text(
                  "Voucher giảm 100% cho người mới",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ListTile(
                leading: Icon(Icons.local_offer, color: Colors.white),
                title: Text(
                  "Voucher giảm 10% khi nạp vip",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
      title: Text(title, style: TextStyle(color: Colors.white)),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
      onTap: onTap,
    );
  }
}
<<<<<<< Updated upstream
=======

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
      _randomFavorites = allFavorites.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_randomFavorites.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final int displayCount =
        _randomFavorites.length < 3 ? _randomFavorites.length : 3;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(displayCount, (index) {
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
>>>>>>> Stashed changes
