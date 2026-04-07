import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/theme_provider.dart';
import 'screens/auth_gate.dart'; // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const ReGenApp(),
    ),
  );
}

class ReGenApp extends StatelessWidget {
  const ReGenApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'ReGen',
      debugShowCheckedModeBanner: false,
      
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        fontFamily: 'SFPro',
        scaffoldBackgroundColor: Colors.white,
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black, 
        ),
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          secondary: Color(0xFFF5F5F5), 
        ),
      ),

      darkTheme: ThemeData(
        fontFamily: 'SFPro',
        scaffoldBackgroundColor: const Color(0xFF121212), 
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          foregroundColor: Colors.white, 
        ),
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Color(0xFF2C2C2C), 
        ),
      ),

      // CHANGE THIS LINE: Set home to AuthGate
      home: const AuthGate(),
    );
  }
}
