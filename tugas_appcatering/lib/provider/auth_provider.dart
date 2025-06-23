import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  User? get user => _user;

  bool get isLoggedIn => _user != null;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _user = _auth.currentUser;
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    _user = firebaseUser;
    notifyListeners();
  }

  // LOGIN
  Future<String?> signInWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      debugPrint("User signed in: ${_auth.currentUser?.email}");
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Terjadi kesalahan: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // REGISTER
  Future<String?> signUpWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint("User registered: ${_auth.currentUser?.email}");
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Terjadi kesalahan: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // LOGOUT
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      debugPrint("User signed out");
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }
}
