import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../data/models/post_model.dart';

class CommunityRepository {
  static const String _collection = 'community_posts';
  final FirebaseFirestore _firestore;

  CommunityRepository(this._firestore);

  /// Get public feed stream ordered by timestamp descending
  Stream<List<PostModel>> getPublicFeed() {
    debugPrint('Fetching public feed from collection: $_collection');
    return _firestore
        .collection(_collection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          debugPrint(
            'Snapshot received with ${snapshot.docs.length} documents',
          );
          try {
            return snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              debugPrint('Mapping document: ${doc.id}');
              return PostModel.fromMap(data);
            }).toList();
          } catch (e) {
            debugPrint('Error mapping documents: $e');
            return <PostModel>[];
          }
        })
        .handleError((error) {
          debugPrint('Stream error: $error');
          return <PostModel>[];
        });
  }

  /// Create a new post
  Future<void> createPost(String content, {String? moodTag}) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      debugPrint('WARNING: User not authenticated - cannot create post');
      throw Exception('User not authenticated');
    }

    final uid = currentUser.uid;
    debugPrint('Creating post for authenticated user: $uid');

    try {
      final postId = _firestore.collection(_collection).doc().id;
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final postData = {
        'id': postId,
        'authorId': uid,
        'content': content,
        'timestamp': timestamp,
        'moodTag': moodTag,
        'supportCount': 0,
      };

      debugPrint('Post data payload: authorId=$uid, timestamp=$timestamp');
      await _firestore.collection(_collection).doc(postId).set(postData);
      debugPrint('Post created successfully with ID: $postId');
    } catch (e) {
      debugPrint('Failed to create post: $e');
      throw Exception('Failed to create post: $e');
    }
  }

  /// Increment support count for a post
  Future<void> incrementSupport(String postId) async {
    debugPrint('Incrementing support for post: $postId');
    debugPrint('Using collection: $_collection');
    try {
      await _firestore.collection(_collection).doc(postId).update({
        'supportCount': FieldValue.increment(1),
      });
      debugPrint('Support incremented successfully for post: $postId');
    } catch (e) {
      debugPrint('Failed to increment support for post $postId: $e');
      throw Exception('Failed to increment support: $e');
    }
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw Exception('User not authenticated');
      }

      // Verify the user owns the post before deleting
      final doc = await _firestore.collection(_collection).doc(postId).get();
      if (!doc.exists) {
        throw Exception('Post not found');
      }

      final authorId = doc.data()?['authorId'];
      if (authorId != uid) {
        throw Exception('You can only delete your own posts');
      }

      await _firestore.collection(_collection).doc(postId).delete();
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }
}
