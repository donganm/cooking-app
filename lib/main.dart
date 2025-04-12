import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(child: Scaffold(body: MyApp())),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Hello world",
        style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),
      ),
    );
  }
}
