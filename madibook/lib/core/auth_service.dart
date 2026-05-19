import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'notification_service.dart';

/// Authentication state.
enum AuthState { initial, loading, authenticated, unauthenticated, error }

/// Production-ready Firebase Authentication service.
class AuthService extends ChangeNotifier {
  FirebaseAuth? __auth;
  FirebaseFirestore? __firestore;

  FirebaseAuth get _auth {
    try {
      return __auth ??= FirebaseAuth.instance;
    } catch (e) {
      debugPrint('❌ AuthService: Failed to get FirebaseAuth instance: $e');
      rethrow;
    }
  }

  FirebaseFirestore get _firestore {
    try {
      return __firestore ??= FirebaseFirestore.instance;
    } catch (e) {
      debugPrint('❌ AuthService: Failed to get FirebaseFirestore instance: $e');
      rethrow;
    }
  }

  AuthState _state = AuthState.initial;
  NexusUser? _currentUser;
  String? _errorMessage;

  AuthState get state => _state;
  NexusUser? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;

  /// Stream that emits the current user on auth state changes.
  final StreamController<NexusUser?> _authStateController =
      StreamController<NexusUser?>.broadcast();
  Stream<NexusUser?> get authStateChanges => _authStateController.stream;

  StreamSubscription? _userDocSubscription;

  AuthService() {
    debugPrint('🔐 AuthService: Initializing...');
    // Listen to Firebase Auth state changes
    try {
      _auth.authStateChanges().listen((user) {
        debugPrint('🔐 AuthService: Firebase Auth state changed: ${user?.uid ?? "null"}');
        _onAuthStateChanged(user);
      }, onError: (e) {
        debugPrint('❌ AuthService: Firebase Auth error: $e');
        _state = AuthState.error;
        _errorMessage = 'Firebase Auth Error: $e';
        notifyListeners();
      });
    } catch (e) {
      debugPrint('❌ AuthService: Failed to initialize listeners: $e');
      _state = AuthState.error;
      _errorMessage = 'Auth failed to initialize: $e';
    }
    
    // Safety timeout: if auth state doesn't change from initial within 3 seconds, it's likely a Firebase config issue
    Future.delayed(const Duration(seconds: 3), () {
      if (_state == AuthState.initial) {
        debugPrint('⚠️ AuthService: Auth timeout! Current state still initial.');
        _state = AuthState.error;
        _errorMessage = 'Auth failed to initialize. Please check your internet connection or Firebase configuration.';
        _authStateController.add(null);
        notifyListeners();
      }
    });
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    _userDocSubscription?.cancel();
    
    if (firebaseUser == null) {
      _currentUser = null;
      _state = AuthState.unauthenticated;
      _authStateController.add(null);
    } else {
      // Initialize state as loading while we fetch data
      _state = AuthState.authenticated;
      
      // Start listening to the Firestore document for real-time updates
      _userDocSubscription = _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .snapshots()
          .listen((snapshot) async {
        if (snapshot.exists) {
          _currentUser = NexusUser.fromJson(snapshot.data() as Map<String, dynamic>, snapshot.id);
          _authStateController.add(_currentUser);
          notifyListeners();
        } else {
          // If doc doesn't exist yet, create it
          _currentUser = await _ensureUserStored(firebaseUser);
          _authStateController.add(_currentUser);
          notifyListeners();
        }
      });
      
      _userDocSubscription?.onError((error) {
        debugPrint('Firestore User Doc Error: $error');
        // If Firestore fails (e.g. permissions), fallback to initial user to prevent infinite loading
        _currentUser = NexusUser(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'Error User',
          username: 'error_user',
          email: firebaseUser.email ?? '',
          bio: 'Error loading profile',
        );
        _state = AuthState.authenticated;
        _authStateController.add(_currentUser);
        notifyListeners();
      });
      
      // Initial FCM token update
      NotificationService().updateFcmToken(firebaseUser.uid);
    }
    notifyListeners();
  }

  /// Ensures the user document exists in Firestore.
  /// If it doesn't exist, it creates it with the required fields.
  Future<NexusUser> _ensureUserStored(User firebaseUser, {String? nameOverride}) async {
    // Create a fallback/initial user object
    final initialUser = NexusUser(
      id: firebaseUser.uid,
      name: nameOverride ?? firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? 'User',
      username: firebaseUser.email?.split('@')[0] ?? 'user',
      email: firebaseUser.email ?? '',
      bio: '', // Default empty bio
    );

    try {
      final docRef = _firestore.collection('users').doc(firebaseUser.uid);
      final doc = await docRef.get().timeout(const Duration(seconds: 5));

      debugPrint('DEBUG: [Full Sync] Ensuring storage for UID: ${firebaseUser.uid}');

      if (!doc.exists) {
        debugPrint('DEBUG: [Full Sync] Creating NEW user document in Firestore');
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
        debugPrint('DEBUG: [Full Sync] Existing document found in Firestore');
        return NexusUser.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }
    } catch (e) {
      debugPrint('DEBUG WARNING: [Full Sync] Firestore sync failed: $e');
      return initialUser;
    }
  }

  /// Register a new account.
  Future<NexusUser?> signUp({
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
        debugPrint('DEBUG: User created: ${user.uid}');
        _currentUser = await _ensureUserStored(user, nameOverride: name.trim());
        
        _state = AuthState.authenticated;
        notifyListeners();
        return _currentUser;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _errorMessage = 'ACCOUNT_EXISTS';
        notifyListeners();
        return await signIn(email: email, password: password);
      }
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
  Future<NexusUser?> signIn({
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
        debugPrint('DEBUG: User signed in: ${credential.user!.uid}');
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
    debugPrint('DEBUG: Signed out');
  }

  @override
  void dispose() {
    _authStateController.close();
    super.dispose();
  }
}
