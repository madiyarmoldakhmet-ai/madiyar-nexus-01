import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Authentication state.
enum AuthState { initial, loading, authenticated, unauthenticated, error }

/// Production-ready Firebase Authentication service.
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthState _state = AuthState.initial;
  MadiUser? _currentUser;
  String? _errorMessage;

  AuthState get state => _state;
  MadiUser? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;

  /// Stream that emits the current user on auth state changes.
  final StreamController<MadiUser?> _authStateController =
      StreamController<MadiUser?>.broadcast();
  Stream<MadiUser?> get authStateChanges => _authStateController.stream;

  AuthService() {
    // Listen to Firebase Auth state changes
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
      _state = AuthState.unauthenticated;
      _authStateController.add(null);
    } else {
      // Sync user data from Firestore using our unified storage method
      _currentUser = await _ensureUserStored(firebaseUser);
      _state = AuthState.authenticated;
      _authStateController.add(_currentUser);
    }
    notifyListeners();
  }

  /// Ensures the user document exists in Firestore.
  /// If it doesn't exist, it creates it with the required fields.
  Future<MadiUser> _ensureUserStored(User firebaseUser, {String? nameOverride}) async {
    // Create a fallback/initial user object
    final initialUser = MadiUser(
      id: firebaseUser.uid,
      name: nameOverride ?? firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? 'User',
      username: firebaseUser.email?.split('@')[0] ?? 'user',
      email: firebaseUser.email ?? '',
      bio: '', // Default empty bio
    );

    try {
      final docRef = _firestore.collection('users').doc(firebaseUser.uid);
      final doc = await docRef.get().timeout(const Duration(seconds: 5));

      print('DEBUG: [Full Sync] Ensuring storage for UID: ${firebaseUser.uid}');

      if (!doc.exists) {
        print('DEBUG: [Full Sync] Creating NEW user document in Firestore');
        final userData = initialUser.toJson();
        // Specifically add fields requested by the user
        userData['uid'] = firebaseUser.uid;
        userData['name'] = initialUser.name;
        userData['username'] = initialUser.username;
        userData['email'] = initialUser.email;
        userData['bio'] = initialUser.bio;
        userData['createdAt'] = FieldValue.serverTimestamp();
        
        await docRef.set(userData);
        return initialUser;
      } else {
        print('DEBUG: [Full Sync] Existing document found in Firestore');
        return MadiUser.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }
    } catch (e) {
      print('DEBUG WARNING: [Full Sync] Firestore sync failed: $e');
      return initialUser;
    }
  }

  /// Register a new account.
  Future<MadiUser?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        // Set display name in Firebase Auth
        await user.updateDisplayName(name.trim());
        
        // Manual sync after creation to ensure name is set correctly
        print('DEBUG: User created: ${user.uid}');
        _currentUser = await _ensureUserStored(user, nameOverride: name.trim());
        
        _state = AuthState.authenticated;
        notifyListeners();
        return _currentUser;
      }
    } on FirebaseAuthException catch (e) {
      _state = AuthState.error;
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = 'An unexpected error occurred.';
      notifyListeners();
    }
    return null;
  }

  /// Sign in with email and password.
  Future<MadiUser?> signIn({
    required String email,
    required String password,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        print('DEBUG: User signed in: ${credential.user!.uid}');
        // Sync handled by the listener
        return _currentUser;
      }
    } on FirebaseAuthException catch (e) {
      _state = AuthState.error;
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = 'An unexpected error occurred.';
      notifyListeners();
    }
    return null;
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
    print('DEBUG: Signed out');
  }

  @override
  void dispose() {
    _authStateController.close();
    super.dispose();
  }
}
