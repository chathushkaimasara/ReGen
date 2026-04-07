import 'dart:ui';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'video_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const VideoScreen(),
    const SearchScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We use Stack to float the nav bar over the screens
      body: Stack(
        children: [
          _screens[_currentIndex],
          
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0, left: 40.0, right: 40.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(
                            _currentIndex == 0 ? Icons.home : Icons.home_outlined,
                            size: 28,
                          ),
                          onPressed: () => setState(() => _currentIndex = 0),
                        ),
                        IconButton(
                          icon: Icon(
                            _currentIndex == 1 ? Icons.ondemand_video : Icons.ondemand_video_outlined,
                            size: 28,
                          ),
                          onPressed: () => setState(() => _currentIndex = 1),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search, size: 28),
                          onPressed: () => setState(() => _currentIndex = 2),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _currentIndex = 3),
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            child: const Icon(Icons.person, size: 18, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
