import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // This function is called immediately after a successful Sign Up
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String name,
  }) async {
    try {
      // Creates a unique auto-generated username (e.g., @jakelol7f8a)
      String baseUsername = name.replaceAll(' ', '').toLowerCase();
      String uniqueSuffix = uid.substring(0, 4); 
      String username = '@$baseUsername$uniqueSuffix';

      // Save all this data to the 'users' collection in Firestore
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'name': name,
        'username': username,
        'bio': 'This is my bio...', // Default bio
        'profilePicUrl': '',        // Empty string until they upload an image
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Failed to save user profile to database: $e");
    }
  }
}