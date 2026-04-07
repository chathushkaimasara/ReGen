import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'upload_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the currently logged-in user's ID
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6),
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: const Text(
          'ReGen',
          style: TextStyle(
            fontFamily: 'SFPro',
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UploadScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 26),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      // StreamBuilder listens to the specific user's document in Firestore
      body: currentUserId == null 
        ? const Center(child: Text("Not logged in"))
        : StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(currentUserId).snapshots(),
            builder: (context, snapshot) {
              
              // 1. Show a loading state while fetching data
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // 2. Handle errors or missing data
              if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text("Error loading profile"));
              }

              // 3. Extract the user data from the snapshot
              var userData = snapshot.data!.data() as Map<String, dynamic>;
              String name = userData['name'] ?? 'Unknown User';
              String username = userData['username'] ?? '@username';
              String bio = userData['bio'] ?? 'This is my bio.....';
              String profilePicUrl = userData['profilePicUrl'] ?? '';

              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  children: [
                    SizedBox(
                      height: 190, 
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Container(
                            height: 130,
                            width: double.infinity,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          Positioned(
                            top: 70,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 4), 
                              ),
                              child: CircleAvatar(
                                radius: 56,
                                backgroundColor: Theme.of(context).colorScheme.secondary,
                                // If they have a profile pic URL, show it. Otherwise, show the default icon.
                                backgroundImage: profilePicUrl.isNotEmpty ? NetworkImage(profilePicUrl) : null,
                                child: profilePicUrl.isEmpty 
                                    ? const Icon(Icons.person, size: 40, color: Colors.grey)
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Display Real Name
                    Text(
                      name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    
                    // Display Real Username
                    Text(
                      username,
                      style: TextStyle(
                        fontSize: 14, 
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Display Real Bio
                    Text(
                      bio,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 30),

                    // Placeholder for user's uploaded images
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: GridView.builder(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(), 
                        shrinkWrap: true, 
                        itemCount: 6, 
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, 
                          crossAxisSpacing: 10, 
                          mainAxisSpacing: 10, 
                          childAspectRatio: 0.8, 
                        ),
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(15),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }
}

