import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/active_post.dart';
import '../config/firebase_config.dart';

class PostProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<ActivePost> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ActivePost> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<ActivePost> get activePosts => 
      _posts.where((post) => post.isActive).toList();

  Future<void> fetchPosts() async {
    _setLoading(true);
    _clearError();

    try {
      final querySnapshot = await _firestore
          .collection(FirebaseConfig.postsCollection)
          .orderBy(FieldPath.documentId)
          .get();

      _posts = querySnapshot.docs
          .map((doc) => ActivePost.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
      
      _setLoading(false);
    } catch (e) {
      _setError('Failed to fetch posts: ${e.toString()}');
      _setLoading(false);
    }
  }

  Future<bool> createPost(String postId, String? thumbnailUrl) async {
    _setLoading(true);
    _clearError();

    try {
      final docRef = await _firestore
          .collection(FirebaseConfig.postsCollection)
          .add({
            'post_id': postId,
            'post_thumbnail_url': thumbnailUrl,
            'is_active': true,
          });

      final newPost = ActivePost(
        id: docRef.id,
        postId: postId,
        postThumbnailUrl: thumbnailUrl,
        isActive: true,
      );
      _posts.add(newPost);
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to create post: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> togglePostStatus(String postId) async {
    _setLoading(true);
    _clearError();

    try {
      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex == -1) {
        _setError('Post not found');
        _setLoading(false);
        return false;
      }

      final currentPost = _posts[postIndex];
      final newStatus = !currentPost.isActive;

      await _firestore
          .collection(FirebaseConfig.postsCollection)
          .doc(postId)
          .update({'is_active': newStatus});

      _posts[postIndex] = currentPost.copyWith(isActive: newStatus);
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to toggle post status: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deletePost(String postId) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestore
          .collection(FirebaseConfig.postsCollection)
          .doc(postId)
          .delete();

      _posts.removeWhere((post) => post.id == postId);
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to delete post: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updatePost(String postId, String newPostId, String? thumbnailUrl) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestore
          .collection(FirebaseConfig.postsCollection)
          .doc(postId)
          .update({
            'post_id': newPostId,
            'post_thumbnail_url': thumbnailUrl,
          });

      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        _posts[postIndex] = _posts[postIndex].copyWith(
          postId: newPostId,
          postThumbnailUrl: thumbnailUrl,
        );
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update post: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
