import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Firebase Auth instance provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Current user provider
final currentUserProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

// Current user ID provider (nullable - null if not logged in)
final currentUserIdProvider = Provider<String?>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.whenOrNull(
    data: (user) => user?.uid,
  );
});

// Check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return userId != null;
});

// Auth state notifier for login/logout operations
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final FirebaseAuth _auth;
  
  AuthNotifier(this._auth) : super(const AsyncValue.loading()) {
    _initAuth();
  }

  void _initAuth() {
    _auth.authStateChanges().listen(
      (user) {
        state = AsyncValue.data(user);
      },
      onError: (error, stack) {
        state = AsyncValue.error(error, stack);
      },
    );
  }

  Future<bool> signIn(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      // Ignore sign out errors
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return AuthNotifier(auth);
});

