import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';

class CommentsSheet extends StatefulWidget {
  final String collectionName; 
  final String postId;
  final String postOwnerId;
  
  const CommentsSheet({super.key, required this.collectionName, required this.postId, required this.postOwnerId});

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  void _postComment() async {
    if (_commentController.text.trim().isEmpty) return;

    await DatabaseService().addComment(
      widget.collectionName, 
      widget.postId, 
      currentUserId, 
      _commentController.text.trim(),
      widget.postOwnerId
    );
    
    _commentController.clear(); 
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6, 
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Container(height: 5, width: 50, decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 15),
            const Text('Comments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(widget.collectionName) 
                    .doc(widget.postId)
                    .collection('comments')
                    .orderBy('createdAt', descending: true) 
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No comments yet. Start the conversation!', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5))));
                  }

                  final comments = snapshot.data!.docs;

                  return ListView.builder(
                    reverse: true, 
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      var commentData = comments[index].data() as Map<String, dynamic>;
                      String userId = commentData['userId'] ?? '';
                      String text = commentData['text'] ?? '';

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                        builder: (context, userSnapshot) {
                          String username = '@unknown';
                          String profilePic = '';
                          if (userSnapshot.hasData && userSnapshot.data!.exists) {
                            username = userSnapshot.data!['username'];
                            profilePic = userSnapshot.data!['profilePicUrl'] ?? '';
                          }

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              backgroundImage: profilePic.isNotEmpty ? NetworkImage(profilePic) : null,
                              child: profilePic.isEmpty ? const Icon(Icons.person, size: 20, color: Colors.grey) : null,
                            ),
                            title: Text(username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text(text, style: const TextStyle(fontSize: 14)),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -4), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.secondary,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                    child: IconButton(
                      icon: Icon(Icons.arrow_upward, color: Theme.of(context).scaffoldBackgroundColor),
                      onPressed: _postComment,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
