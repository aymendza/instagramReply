import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import '../models/comment.dart';
import '../config/firebase_config.dart';

class CommentProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<Comment> _comments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Comment> get pendingComments => 
      _comments.where((comment) => comment.status == 'pending').toList();

  Future<void> fetchPendingComments() async {
    _setLoading(true);
    _clearError();

    try {
      final querySnapshot = await _firestore
          .collection(FirebaseConfig.commentsCollection)
          .where('status', isEqualTo: 'pending')
          .orderBy('created_at', descending: true)
          .get();

      _comments = querySnapshot.docs
          .map((doc) => Comment.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
      
      _setLoading(false);
    } catch (e) {
      _setError('Failed to fetch comments: ${e.toString()}');
      _setLoading(false);
    }
  }

  Future<bool> approveComment(String commentId, String replyText) async {
    _setLoading(true);
    _clearError();

    try {
      // Update comment status and reply text in Firestore
      await _firestore
          .collection(FirebaseConfig.commentsCollection)
          .doc(commentId)
          .update({
            'status': 'approved',
            'reply_text': replyText,
          });

      // Call n8n webhook to execute the reply
      final success = await _callN8nWebhook(commentId);
      
      if (success) {
        // Update local state
        final commentIndex = _comments.indexWhere((c) => c.id == commentId);
        if (commentIndex != -1) {
          _comments[commentIndex] = Comment(
            id: _comments[commentIndex].id,
            commenterName: _comments[commentIndex].commenterName,
            commentText: _comments[commentIndex].commentText,
            status: 'approved',
            createdAt: _comments[commentIndex].createdAt,
            commentType: _comments[commentIndex].commentType,
            aiAnalysis: _comments[commentIndex].aiAnalysis,
            replyText: replyText,
          );
          _comments.removeAt(commentIndex);
        }
        
        _setLoading(false);
        return true;
      } else {
        _setError('Failed to send reply to Instagram');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to approve comment: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> rejectComment(String commentId) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestore
          .collection(FirebaseConfig.commentsCollection)
          .doc(commentId)
          .update({'status': 'rejected'});

      // Update local state
      _comments.removeWhere((comment) => comment.id == commentId);
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to reject comment: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> _callN8nWebhook(String commentId) async {
    try {
      final response = await http.post(
        Uri.parse(FirebaseConfig.n8nWebhookUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': commentId}),
      );

      return response.statusCode == 200;
    } catch (e) {
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

  // Realtime subscription to listen for new comments
  void subscribeToComments() {
    _firestore
        .collection(FirebaseConfig.commentsCollection)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final newComment = Comment.fromMap({...change.doc.data() as Map<String, dynamic>, 'id': change.doc.id});
          if (newComment.status == 'pending') {
            _comments.insert(0, newComment);
            notifyListeners();
          }
        }
      }
    });
  }

  void unsubscribeFromComments() {
    // Firebase listeners are automatically cleaned up when the widget is disposed
    // You can store the StreamSubscription and cancel it if needed
  }
}
