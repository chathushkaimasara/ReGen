import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
      ),
      body: currentUserId.isEmpty 
          ? const Center(child: Text("Please log in."))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUserId)
                  .collection('notifications')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 60, color: Theme.of(context).iconTheme.color?.withOpacity(0.3)),
                        const SizedBox(height: 15),
                        Text('No notifications yet', style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5))),
                      ],
                    ),
                  );
                }

                final notifications = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    var data = notifications[index].data() as Map<String, dynamic>;
                    String fromUserId = data['fromUserId'] ?? '';
                    String type = data['type'] ?? 'interaction';

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(fromUserId).get(),
                      builder: (context, userSnap) {
                        if (!userSnap.hasData || !userSnap.data!.exists) return const SizedBox.shrink();
                        
                        var userData = userSnap.data!.data() as Map<String, dynamic>;
                        String username = userData['username'] ?? '@unknown';
                        String profilePic = userData['profilePicUrl'] ?? '';
                        
                        String message = type == 'like' ? 'liked your post.' : 'commented on your post.';
                        IconData iconData = type == 'like' ? Icons.favorite : Icons.chat_bubble;
                        Color iconColor = type == 'like' ? Colors.redAccent : Theme.of(context).colorScheme.primary;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          leading: GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(userId: fromUserId))),
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              backgroundImage: profilePic.isNotEmpty ? NetworkImage(profilePic) : null,
                              child: profilePic.isEmpty ? const Icon(Icons.person, color: Colors.grey) : null,
                            ),
                          ),
                          title: RichText(
                            text: TextSpan(
                              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 14),
                              children: [
                                TextSpan(text: '$username ', style: const TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: message),
                              ],
                            ),
                          ),
                          trailing: Icon(iconData, color: iconColor, size: 20),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
