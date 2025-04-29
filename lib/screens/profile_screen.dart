import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  void _onEditProfile() {} //them cn sau khi co db
  void _onChangedPassword() {}
  void _onDeleteAccount() {}
  void _onLogout() {}
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
                const CircleAvatar(radius: 50, backgroundColor: Colors.red),
                const SizedBox(height: 10),
                const Text(
                  "Tên người dùng", //có db tương ứng tên người dùng đăng ký
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildCard(
            title: "Bảo mật",
            color: Colors.green,
            children: [
              _buildTitle(Icons.edit, "Sửa thông tin", _onEditProfile),
              _buildTitle(Icons.lock, "Đổi mật khẩu ", _onChangedPassword),
              _buildTitle(
                Icons.delete_forever,
                "Xóa tài khoản",
                _onDeleteAccount,
              ),
              _buildTitle(Icons.logout, "Đăng xuất", _onLogout),
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
