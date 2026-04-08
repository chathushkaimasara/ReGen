import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String name,
  }) async {
    try {
      String baseUsername = name.replaceAll(' ', '').toLowerCase();
      String uniqueSuffix = uid.substring(0, 4); 
      String username = '@$baseUsername$uniqueSuffix';

      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'name': name,
        'username': username,
        'bio': 'This is my bio...', 
        'profilePicUrl': '',        
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Failed to save user profile to database: $e");
    }
  }

  Future<void> createPost({
    required String userId,
    required String imageUrl,
    required String title,
    required String prompt,
    required String description,
    required String aiPlatform,
  }) async {
    try {
      await _firestore.collection('posts').add({
        'userId': userId,
        'imageUrl': imageUrl,
        'title': title,
        'prompt': prompt,
        'description': description,
        'aiPlatform': aiPlatform,
        'likes': [], 
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Failed to create post: $e");
    }
  }

  Future<void> createVideoPost({
    required String userId,
    required String videoUrl,
    required String title,
    required String prompt,
    required String description,
    required String aiPlatform,
  }) async {
    try {
      await _firestore.collection('videos').add({
        'userId': userId,
        'videoUrl': videoUrl,
        'title': title,
        'prompt': prompt,
        'description': description,
        'aiPlatform': aiPlatform,
        'likes': [], 
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Failed to save video to database: $e");
    }
  }

  Future<void> toggleLike(String collectionName, String postId, String userId, List<dynamic> currentLikes, String postOwnerId) async {
    try {
      if (currentLikes.contains(userId)) {
        await _firestore.collection(collectionName).doc(postId).update({
          'likes': FieldValue.arrayRemove([userId])
        });
      } else {
        await _firestore.collection(collectionName).doc(postId).update({
          'likes': FieldValue.arrayUnion([userId])
        });
        await sendNotification(toUserId: postOwnerId, fromUserId: userId, type: 'like', postId: postId);
      }
    } catch (e) {
      throw Exception("Error toggling like: $e");
    }
  }

  Future<void> addComment(String collectionName, String postId, String userId, String text, String postOwnerId) async {
    try {
      await _firestore.collection(collectionName).doc(postId).collection('comments').add({
        'userId': userId,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await sendNotification(toUserId: postOwnerId, fromUserId: userId, type: 'comment', postId: postId);
    } catch (e) {
      throw Exception("Error adding comment: $e");
    }
  }

  Future<void> sendNotification({required String toUserId, required String fromUserId, required String type, required String postId}) async {
    if (toUserId == fromUserId) return;
    try {
      await _firestore.collection('users').doc(toUserId).collection('notifications').add({
        'fromUserId': fromUserId,
        'type': type,
        'postId': postId,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    } catch (e) {
      print("Error sending notification: $e");
    }
  }

  Future<void> updateProfileDetails(String userId, String name, String bio) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'name': name,
        'bio': bio,
      });
    } catch (e) {
      throw Exception("Error updating profile: $e");
    }
  }

  Future<void> updateProfilePicture(String userId, String imageUrl) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'profilePicUrl': imageUrl,
      });
    } catch (e) {
      throw Exception("Error updating profile picture: $e");
    }
  }
  
  Future<void> updateProfileBanner(String userId, String imageUrl) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'profileBannerUrl': imageUrl,
      });
    } catch (e) {
      throw Exception("Error updating banner: $e");
    }
  }

}
