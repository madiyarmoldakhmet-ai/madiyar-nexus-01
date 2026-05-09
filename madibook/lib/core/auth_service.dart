import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/skill_model.dart';

/// Authentication state.
enum AuthState { initial, loading, authenticated, unauthenticated, error }

/// Mock authentication service.
///
/// Mirrors Firebase Auth's API surface so you can swap it with:
///   class FirebaseAuthService implements AuthService { ... }
/// without touching any UI code.
class AuthService extends ChangeNotifier {
  AuthState _state = AuthState.initial;
  MadiUser? _currentUser;
  String? _errorMessage;

  // In-memory "database" of registered users.
  final Map<String, _MockAccount> _accounts = {};

  AuthState get state => _state;
  MadiUser? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;

  /// Stream that emits the current user on auth state changes.
  final StreamController<MadiUser?> _authStateController =
      StreamController<MadiUser?>.broadcast();
  Stream<MadiUser?> get authStateChanges => _authStateController.stream;

  AuthService() {
    // Pre-seed Madi's account for demo purposes.
    _accounts['madi@madibook.kz'] = _MockAccount(
      email: 'madi@madibook.kz',
      password: 'madi123',
      user: MadiUser(
        id: 'user-madi',
        name: 'Madiyar',
        bio:
            'Builder of Madibook. Passionate about connecting learners worldwide.',
        location: 'Almaty, Kazakhstan',
        madiCredits: 5.0,
        offerings: [
          Skill(
              name: 'Python',
              category: 'Programming',
              type: SkillType.offering),
          Skill(
              name: 'Flutter',
              category: 'Programming',
              type: SkillType.offering),
          Skill(
              name: 'UI Design', category: 'Design', type: SkillType.offering),
        ],
        seekings: [
          Skill(name: 'Guitar', category: 'Music', type: SkillType.seeking),
          Skill(
              name: 'Japanese',
              category: 'Languages',
              type: SkillType.seeking),
          Skill(
              name: 'Photography',
              category: 'Photography',
              type: SkillType.seeking),
        ],
      ),
    );
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

    // Simulate network delay.
    await Future.delayed(const Duration(milliseconds: 800));

    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      _state = AuthState.error;
      _errorMessage = 'All fields are required.';
      notifyListeners();
      return null;
    }

    if (_accounts.containsKey(email.toLowerCase())) {
      _state = AuthState.error;
      _errorMessage = 'An account with this email already exists.';
      notifyListeners();
      return null;
    }

    if (password.length < 6) {
      _state = AuthState.error;
      _errorMessage = 'Password must be at least 6 characters.';
      notifyListeners();
      return null;
    }

    final user = MadiUser(name: name, madiCredits: 3.0);
    _accounts[email.toLowerCase()] = _MockAccount(
      email: email.toLowerCase(),
      password: password,
      user: user,
    );

    _currentUser = user;
    _state = AuthState.authenticated;
    _authStateController.add(user);
    notifyListeners();

    debugPrint('✅ Sign up: ${user.name} (${email.toLowerCase()})');
    return user;
  }

  /// Sign in with email and password.
  Future<MadiUser?> signIn({
    required String email,
    required String password,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final account = _accounts[email.toLowerCase()];
    if (account == null || account.password != password) {
      _state = AuthState.error;
      _errorMessage = 'Invalid email or password.';
      notifyListeners();
      return null;
    }

    _currentUser = account.user;
    _state = AuthState.authenticated;
    _authStateController.add(account.user);
    notifyListeners();

    debugPrint('✅ Sign in: ${account.user.name}');
    return account.user;
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    _currentUser = null;
    _state = AuthState.unauthenticated;
    _authStateController.add(null);
    notifyListeners();
    debugPrint('👋 Signed out');
  }

  /// Auto-login for demo (skip the login screen).
  void autoLoginForDemo() {
    final account = _accounts['madi@madibook.kz'];
    if (account != null) {
      _currentUser = account.user;
      _state = AuthState.authenticated;
      _authStateController.add(account.user);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authStateController.close();
    super.dispose();
  }
}

/// Internal mock account record.
class _MockAccount {
  final String email;
  final String password;
  final MadiUser user;

  const _MockAccount({
    required this.email,
    required this.password,
    required this.user,
  });
}
