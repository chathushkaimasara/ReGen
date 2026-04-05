import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/main_layout.dart'; 


void main() {
  runApp(const ReGenApp());
}

class ReGenApp extends StatelessWidget {
  const ReGenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReGen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SFPro',
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const MainLayout(),
    );
  }
}
