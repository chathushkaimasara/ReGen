import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen.dart';
import 'comments_sheet.dart';
import '../services/database_service.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text('ReGen', style: TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.bold, fontSize: 26)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('videos').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final videos = snapshot.data!.docs;
          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: videos.length, 
            itemBuilder: (context, index) {
              return VideoPlayerItem(videoData: videos[index].data() as Map<String, dynamic>, videoId: videos[index].id);
            },
          );
        },
      ),
    );
  }
}

class VideoPlayerItem extends StatefulWidget {
  final Map<String, dynamic> videoData;
  final String videoId;
  const VideoPlayerItem({super.key, required this.videoData, required this.videoId});

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoData['videoUrl']))
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _isInitialized = true);
          _controller.play();
          _controller.setLooping(true);
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String userId = widget.videoData['userId'] ?? '';
    List<dynamic> likes = widget.videoData['likes'] is List ? widget.videoData['likes'] : [];
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    bool isLiked = likes.contains(currentUserId);

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 100, top: 10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _isInitialized ? VideoPlayer(_controller) : const Center(child: CircularProgressIndicator(color: Colors.white)),
            Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black.withOpacity(0.7), Colors.transparent], begin: Alignment.bottomCenter, end: Alignment.center))),
            Positioned(
              bottom: 20, left: 20, right: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (userId.isNotEmpty) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(userId: userId)));
                      }
                    },
                    child: FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                      builder: (context, userSnap) {
                        // FIX: Safely check if the document actually exists!
                        String username = '@unknown';
                        if (userSnap.connectionState == ConnectionState.waiting) {
                          username = '@loading...';
                        } else if (userSnap.hasData && userSnap.data!.exists) {
                          var data = userSnap.data!.data() as Map<String, dynamic>?;
                          username = data?['username'] ?? '@unknown';
                        }
                        return Text(username, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16));
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(widget.videoData['title'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(widget.videoData['prompt'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            Positioned(
              right: 15, bottom: 30,
              child: Column(
                children: [
                  IconButton(
                    icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.white, size: 35), 
                    // ADDED userId at the end of toggleLike
                    onPressed: () => DatabaseService().toggleLike('videos', widget.videoId, currentUserId, likes, userId)
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 35),
                    onPressed: () => showModalBottomSheet(
                      context: context, 
                      isScrollControlled: true, 
                      backgroundColor: Colors.transparent, 
                      // ADDED postOwnerId parameter here
                      builder: (context) => CommentsSheet(collectionName: 'videos', postId: widget.videoId, postOwnerId: userId)
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
