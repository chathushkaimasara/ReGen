import 'package:flutter/material.dart';
import 'home_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const Center(child: Text('Video Screen Placeholder')),
    const Center(child: Text('Search Screen Placeholder')),
    const Center(child: Text('Profile Screen Placeholder')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _screens[_currentIndex],

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0, left: 40.0, right: 40.0),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        _currentIndex == 0 ? Icons.home : Icons.home_outlined,
                        color: Colors.black,
                        size: 28,
                      ),
                      onPressed: () => setState(() => _currentIndex = 0),
                    ),
                    IconButton(
                      icon: Icon(
                        _currentIndex == 1 ? Icons.ondemand_video : Icons.ondemand_video_outlined,
                        color: Colors.black,
                        size: 28,
                      ),
                      onPressed: () => setState(() => _currentIndex = 1),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.search,
                        color: Colors.black,
                        size: 28,
                      ),
                      onPressed: () => setState(() => _currentIndex = 2),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _currentIndex = 3),
                      child: const CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}