import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangedPasswordScreen extends StatefulWidget {
  const ChangedPasswordScreen({super.key});

  @override
  State<ChangedPasswordScreen> createState() => _ChangedPasswordScreenState();
}

class _ChangedPasswordScreenState extends State<ChangedPasswordScreen> {
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  void _changePassword() async {
    try {
      final email = user?.email;
      if (email == null) throw "Không tìm thấy email người dùng";
      final credential = EmailAuthProvider.credential(
        email: email,
        password: _oldPassCtrl.text,
      );
      await user!.reauthenticateWithCredential(credential);
      await user!.updatePassword(_newPassCtrl.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đổi mật khẩu thành công")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đổi Mật Khẩu"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _oldPassCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Mật khẩu hiện tại",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPassCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Mật khẩu mới",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _changePassword,
              child: const Text("Đổi mật khẩu"),
            ),
          ],
        ),
      ),
    );
  }
}
