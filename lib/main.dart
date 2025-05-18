import 'package:btl_flutter_nhom6/screens/history_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/firebase_upload.dart'; // Gọi file bạn mới tạo
import 'package:btl_flutter_nhom6/screens/signup_screen.dart';
import 'package:btl_flutter_nhom6/screens/login_screen.dart';
import 'package:btl_flutter_nhom6/screens/home_screen.dart';
import 'package:btl_flutter_nhom6/screens/cooking_step.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await uploadRecipesToFirestore();
  // try {
  //   await uploadRecipesToFirestore();
  // } catch (e) {
  //   print("Lỗi khi upload dữ liệu: $e");
  // }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CookUp!',
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      routes: {
        '/signup': (context) => const SignUpScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/cooking_step': (context) => const CookingStepPage(),
        '/order': (context) => OrderPage(),
      },
    );
  }
}
