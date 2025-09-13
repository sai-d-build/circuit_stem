// lib/application/services/auth_service.dart
// Firebase Authentication Service Interface and Implementation

import 'package:firebase_auth/firebase_auth.dart';
import 'package:sparkcircuit/domain/entities/entities.dart' as domain;

abstract class AuthService {
  /// Stream of authentication state changes
  Stream<domain.User?> authStateChanges();

  /// Get current authenticated user
  Future<domain.User?> getCurrentUser();

  /// Sign in with email and password
  Future<domain.User> signInWithEmail(String email, String password);

  /// Sign in with Google
  Future<domain.User> signInWithGoogle();

  /// Sign in with Apple
  Future<domain.User> signInWithApple();

  /// Create account with email and password
  Future<domain.User> createAccount(String email, String password);

  /// Send password reset email
  Future<void> sendPasswordReset(String email);

  /// Sign out current user
  Future<void> signOut();

  /// Delete current user account
  Future<void> deleteAccount();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Refresh user token
  Future<void> refreshToken();
}

// Firebase Implementation
class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth;

  FirebaseAuthService(this._auth);

  @override
  Stream<domain.User?> authStateChanges() async* {
    await for (final user in _auth.authStateChanges()) {
      if (user == null) {
        yield null;
      } else {
        yield await _userFromFirebaseUser(user);
      }
    }
  }

  @override
  Future<domain.User?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await _userFromFirebaseUser(user);
  }

  @override
  Future<domain.User> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await _userFromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<domain.User> signInWithGoogle() async {
    try {
      // TODO: Implement Google Sign-In
      // final googleUser = await GoogleSignIn().signIn();
      // final googleAuth = await googleUser!.authentication;
      // final credential = GoogleAuthProvider.credential(
      //   accessToken: googleAuth.accessToken,
      //   idToken: googleAuth.idToken,
      // );
      // final result = await _auth.signInWithCredential(credential);
      // return await _userFromFirebaseUser(result.user!);
      throw UnimplementedError('Google Sign-In not yet implemented');
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<domain.User> signInWithApple() async {
    try {
      // TODO: Implement Apple Sign-In
      throw UnimplementedError('Apple Sign-In not yet implemented');
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<domain.User> createAccount(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await _userFromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.delete();
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return _auth.currentUser != null;
  }

  @override
  Future<void> refreshToken() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.getIdToken(true);
    }
  }

  Future<domain.User> _userFromFirebaseUser(User firebaseUser) async {
    // Get additional user data from Firestore if needed
    // final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();

    return domain.User(
      id: firebaseUser.uid,
      uid: firebaseUser.uid,
      username:
          firebaseUser.displayName ?? firebaseUser.email!.split('@').first,
      email: firebaseUser.email!,
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      createdAt: firebaseUser.metadata.creationTime,
      lastLoginAt: firebaseUser.metadata.lastSignInTime,
    );
  }

  AuthException _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException.userNotFound(); // ignore: cascade_invocations
      case 'wrong-password':
        return AuthException.invalidCredentials(); // ignore: cascade_invocations
      case 'email-already-in-use':
        return AuthException.emailAlreadyInUse(); // ignore: cascade_invocations
      case 'weak-password':
        return AuthException.weakPassword(); // ignore: cascade_invocations
      case 'invalid-email':
        return AuthException.invalidEmail(); // ignore: cascade_invocations
      case 'user-disabled':
        return AuthException.userDisabled(); // ignore: cascade_invocations
      case 'too-many-requests':
        return AuthException.tooManyRequests(); // ignore: cascade_invocations
      default:
        return AuthException.unknown(e.message ?? 'Unknown error'); // ignore: cascade_invocations
    }
  }
}

// Custom Auth Exceptions
class AuthException implements Exception {
  final String message;
  final String code;

  AuthException._(this.code, this.message);

  factory AuthException.userNotFound() =>
      AuthException._('user-not-found', 'No user found with this email');

  factory AuthException.invalidCredentials() =>
      AuthException._('invalid-credentials', 'Invalid email or password');

  factory AuthException.emailAlreadyInUse() =>
      AuthException._('email-already-in-use', 'Email is already registered');

  factory AuthException.weakPassword() =>
      AuthException._('weak-password', 'Password is too weak');

  factory AuthException.invalidEmail() =>
      AuthException._('invalid-email', 'Invalid email format');

  factory AuthException.userDisabled() =>
      AuthException._('user-disabled', 'This account has been disabled');

  factory AuthException.tooManyRequests() => AuthException._(
      'too-many-requests', 'Too many failed attempts. Try again later');

  factory AuthException.unknown(String message) =>
      AuthException._('unknown', message);

  @override
  String toString() => 'AuthException: $message';
}
