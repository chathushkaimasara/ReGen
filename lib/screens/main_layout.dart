import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  final List<Widget> _screens = const [
    HomeScreen(),
    VideoScreen(),
    SearchScreen(),
    ProfileScreen(),
  ];

  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      extendBody: true, 
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 65, 
          margin: const EdgeInsets.only(left: 20, right: 20, bottom: 15), 
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.85),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ]
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildNavItem(Icons.home_outlined, Icons.home, 0),
                  _buildNavItem(Icons.ondemand_video, Icons.smart_display, 1),
                  _buildNavItem(Icons.search, Icons.search, 2),
                  _buildProfileNavItem(3), 
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData outlineIcon, IconData solidIcon, int index) {
    bool isActive = _currentIndex == index;
    Color iconColor = isActive 
        ? Theme.of(context).colorScheme.primary 
        : (Theme.of(context).iconTheme.color?.withOpacity(0.5) ?? Colors.grey);

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque, 
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Icon(
          isActive ? solidIcon : outlineIcon,
          color: iconColor,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildProfileNavItem(int index) {
    bool isActive = _currentIndex == index;

    Color iconColor = isActive 
        ? Theme.of(context).colorScheme.primary 
        : (Theme.of(context).iconTheme.color?.withOpacity(0.5) ?? Colors.grey);

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: currentUserId == null
            ? Icon(isActive ? Icons.person : Icons.person_outline, color: iconColor, size: 28)
            : StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(currentUserId).snapshots(),
                builder: (context, snapshot) {
                  String profilePicUrl = '';
                  if (snapshot.hasData && snapshot.data!.exists) {
                    profilePicUrl = snapshot.data!['profilePicUrl'] ?? '';
                  }

                  if (profilePicUrl.isEmpty) {
                    return Icon(isActive ? Icons.person : Icons.person_outline, color: iconColor, size: 28);
                  }

                  return Container(
                    width: 30, 
                    height: 30, 
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isActive ? Theme.of(context).colorScheme.primary : Colors.transparent,
                        width: 2,
                      ),
                      image: DecorationImage(
                        image: NetworkImage(profilePicUrl),
                        fit: BoxFit.cover,
                      )
                    ),
                  );
                },
              ),
      ),
    );
  }
}
