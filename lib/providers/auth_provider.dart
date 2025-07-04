import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  
  bool _isLoading = true;
  bool _isAuthenticated = false;
  User? _user;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  User? get user => _user;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _user = _firebaseAuth.currentUser;
    _isAuthenticated = _user != null;
    _isLoading = false;
    notifyListeners();

    // Listen to auth state changes
    _firebaseAuth.authStateChanges().listen((User? user) {
      _user = user;
      _isAuthenticated = user != null;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        _user = credential.user;
        _isAuthenticated = true;
        _setLoading(false);
        return true;
      } else {
        _setError('Login failed. Please check your credentials.');
        _setLoading(false);
        return false;
      }
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'Authentication failed');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      _user = null;
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      _setError('Error signing out. Please try again.');
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
