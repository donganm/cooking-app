import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:btl_flutter_nhom6/screens/signup_screen.dart';
import 'package:btl_flutter_nhom6/screens/login_screen.dart';
import 'package:btl_flutter_nhom6/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CookUp!',
      debugShowCheckedModeBanner: false,
      initialRoute: '/signup',
      routes: {
        '/signup': (context) => const SignUpScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
