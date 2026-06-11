import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../data/models/user_model.dart';

class UserRepository {
  static const String _collection = 'users';
  final FirebaseFirestore _firestore;

  UserRepository(this._firestore);

  /// Save user profile to Firestore at /users/{uid}
  Future<void> saveUserProfile(UserModel user) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      debugPrint('WARNING: User not authenticated - cannot save profile');
      throw Exception('User not authenticated');
    }

    final uid = currentUser.uid;
    debugPrint('Saving user profile for authenticated user: $uid');

    try {
      await _firestore.collection(_collection).doc(uid).set(user.toMap());
      debugPrint('User profile saved successfully for UID: $uid');
    } catch (e) {
      debugPrint('Failed to save user profile: $e');
      throw Exception('Failed to save user profile: $e');
    }
  }

  /// Get user profile stream for the current authenticated user
  Stream<UserModel?> getUserProfileStream() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      debugPrint('WARNING: User not authenticated - cannot fetch profile');
      return Stream.value(null);
    }

    final uid = currentUser.uid;
    debugPrint('Fetching user profile stream for UID: $uid');

    return _firestore
        .collection(_collection)
        .doc(uid)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) {
            debugPrint('User profile document does not exist for UID: $uid');
            return null;
          }

          try {
            final data = snapshot.data();
            if (data != null) {
              debugPrint('Successfully mapped user profile for UID: $uid');
              return UserModel.fromFirestore(data, snapshot.id);
            }
            return null;
          } catch (e) {
            debugPrint('Error mapping user profile document: $e');
            return null;
          }
        })
        .handleError((error) {
          debugPrint('User profile stream error: $error');
          return null;
        });
  }

  /// Get user profile once (Future) for the current authenticated user
  Future<UserModel?> getUserProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      debugPrint('WARNING: User not authenticated - cannot fetch profile');
      return null;
    }

    final uid = currentUser.uid;
    debugPrint('Fetching user profile for UID: $uid');

    try {
      final snapshot = await _firestore.collection(_collection).doc(uid).get();
      if (!snapshot.exists) {
        debugPrint('User profile document does not exist for UID: $uid');
        return null;
      }

      final data = snapshot.data();
      if (data != null) {
        debugPrint('Successfully fetched user profile for UID: $uid');
        return UserModel.fromFirestore(data, snapshot.id);
      }
      return null;
    } catch (e) {
      debugPrint('Failed to fetch user profile: $e');
      return null;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      debugPrint('WARNING: User not authenticated - cannot update profile');
      throw Exception('User not authenticated');
    }

    final uid = currentUser.uid;
    if (uid != user.uid) {
      debugPrint('WARNING: UID mismatch - cannot update another user profile');
      throw Exception('Cannot update another user profile');
    }

    debugPrint('Updating user profile for UID: $uid');

    try {
      await _firestore.collection(_collection).doc(uid).update(user.toMap());
      debugPrint('User profile updated successfully for UID: $uid');
    } catch (e) {
      debugPrint('Failed to update user profile: $e');
      throw Exception('Failed to update user profile: $e');
    }
  }
}
