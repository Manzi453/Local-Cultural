import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateChangesProvider = StreamProvider<firebase_auth.User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  
  // Stream for auth state changes
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<firebase_auth.User?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Send email verification
      await credential.user?.sendEmailVerification();
      return credential.user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint(e.message);
      rethrow;
    }
  }

  // Sign in with email and password
  Future<firebase_auth.User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint(e.message);
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  firebase_auth.User? get currentUser => _auth.currentUser;

  // Resend verification email
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  void resetSessionTimer() {
    // Session management can be added here if needed
  }

  void dispose() {
    // Cleanup if needed
  }
}
