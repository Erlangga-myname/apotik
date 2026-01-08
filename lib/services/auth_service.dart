import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';

/// Firebase authentication service
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current user stream for session persistence
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Sign in with email and password
  Future<UserModel?> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Get user data from Firestore
        final doc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(userCredential.user!.uid)
            .get();

        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Register new user
  Future<UserModel?> register(String email, String password, String name) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Create user document in Firestore
        final userModel = UserModel(
          id: userCredential.user!.uid,
          email: email,
          name: name,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(userCredential.user!.uid)
            .set(userModel.toMap());

        return userModel;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to get user data: $e';
    }
  }

  /// Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password provided';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}
