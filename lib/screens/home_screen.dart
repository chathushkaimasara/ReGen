import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_screen.dart';
import 'upload_screen.dart';
import 'profile_screen.dart';
import 'comments_sheet.dart';
import '../services/database_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text('ReGen', style: TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.bold, fontSize: 26)),
        actions: [
          IconButton(icon: const Icon(Icons.add, size: 28), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UploadScreen()))),
          IconButton(icon: const Icon(Icons.notifications_none, size: 28), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()))),
          const SizedBox(width: 10),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('No posts yet.'));
          
          final posts = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 100),
            itemCount: posts.length, 
            itemBuilder: (context, index) {
              return PostCard(postData: posts[index].data() as Map<String, dynamic>, postId: posts[index].id);
            },
          );
        },
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final Map<String, dynamic> postData;
  final String postId;

  const PostCard({super.key, required this.postData, required this.postId});

  @override
  Widget build(BuildContext context) {
    String imageUrl = postData['imageUrl'] ?? '';
    String title = postData['title'] ?? 'Untitled';
    String userId = postData['userId'] ?? '';
    List<dynamic> likes = postData['likes'] is List ? postData['likes'] : [];
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    bool isLiked = likes.contains(currentUserId);

    return Container(
      margin: const EdgeInsets.only(bottom: 25.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: imageUrl.isNotEmpty 
              ? Image.network(imageUrl, width: double.infinity, fit: BoxFit.fitWidth)
              : Container(height: 300, color: Theme.of(context).colorScheme.secondary),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (userId.isNotEmpty) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(userId: userId)));
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                          builder: (context, userSnap) {
                            String username = '@unknown';
                            if (userSnap.connectionState == ConnectionState.waiting) {
                              username = '@loading...';
                            } else if (userSnap.hasData && userSnap.data!.exists) {
                              var data = userSnap.data!.data() as Map<String, dynamic>?;
                              username = data?['username'] ?? '@unknown';
                            }
                            return Text(username, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6), fontSize: 13));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : null),
                      onPressed: () => DatabaseService().toggleLike('posts', postId, currentUserId, likes, userId), 
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.only(right: 15),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline),
                      onPressed: () => showModalBottomSheet(
                        context: context, 
                        isScrollControlled: true, 
                        backgroundColor: Colors.transparent, 
                        builder: (context) => CommentsSheet(collectionName: 'posts', postId: postId, postOwnerId: userId)
                      ),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
