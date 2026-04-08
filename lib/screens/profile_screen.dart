import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'upload_screen.dart';
import 'settings_screen.dart';
import 'notification_screen.dart';
import '../services/storage_service.dart';
import '../services/database_service.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId; 
  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String targetUserId;
  bool isMe = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    targetUserId = widget.userId ?? currentUid ?? '';
    isMe = targetUserId == currentUid;
  }

  Future<void> _updateMedia(bool isBanner) async {
    if (!isMe || _isUploading) return;
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _isUploading = true);
        String imageUrl = await StorageService().uploadPostImage(File(pickedFile.path), targetUserId);
        if (isBanner) {
          await DatabaseService().updateProfileBanner(targetUserId, imageUrl);
        } else {
          await DatabaseService().updateProfilePicture(targetUserId, imageUrl);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text('ReGen', style: TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.bold, fontSize: 26)),
        actions: [
          if (isMe) ...[
            IconButton(icon: const Icon(Icons.add), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UploadScreen()))),
            IconButton(icon: const Icon(Icons.notifications_none), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()))),
            IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()))),
          ],
          const SizedBox(width: 10),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(targetUserId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) return const Center(child: CircularProgressIndicator());

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          String profilePic = userData['profilePicUrl'] ?? '';
          String bannerUrl = userData['profileBannerUrl'] ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      GestureDetector(
                        onTap: () => _updateMedia(true),
                        child: Container(
                          height: 140,
                          width: double.infinity,
                          color: Theme.of(context).colorScheme.secondary,
                          child: bannerUrl.isNotEmpty ? Image.network(bannerUrl, fit: BoxFit.cover) : null,
                        ),
                      ),
                      Positioned(
                        top: 90,
                        child: GestureDetector(
                          onTap: () => _updateMedia(false),
                          child: CircleAvatar(
                            radius: 54,
                            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              backgroundImage: profilePic.isNotEmpty ? NetworkImage(profilePic) : null,
                              child: profilePic.isEmpty ? const Icon(Icons.person, size: 40) : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(userData['name'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text(userData['username'] ?? '', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6))),
                const SizedBox(height: 10),
                Text(userData['bio'] ?? '', style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 20),
                
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('posts').where('userId', isEqualTo: targetUserId).snapshots(),
                  builder: (context, postSnap) {
                    if (!postSnap.hasData) return const CircularProgressIndicator();
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
                      itemCount: postSnap.data!.docs.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(postSnap.data!.docs[index]['imageUrl'], fit: BoxFit.cover),
                        );
                      },
                    );
                  }
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
