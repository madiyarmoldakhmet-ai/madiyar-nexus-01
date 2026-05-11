import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/skill_model.dart';
import '../models/swap_request_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Central app state: manages the current user, the community pool,
/// and all swap requests.
///
/// In production, replace the in-memory lists with API calls.
class AppState extends ChangeNotifier {
  MadiUser? _currentUser;
  List<MadiUser> _communityUsers = [];
  final List<SwapRequest> _swapRequests = [];
  int _selectedTabIndex = 0;

  MadiUser? get currentUser => _currentUser;
  List<MadiUser> get communityUsers => List.unmodifiable(_communityUsers);
  List<SwapRequest> get swapRequests => List.unmodifiable(_swapRequests);
  int get selectedTabIndex => _selectedTabIndex;

  /// Update the current user from the Auth service.
  void setCurrentUser(MadiUser? user) {
    _currentUser = user;
    if (_currentUser != null) {
      _startListeningToCommunity();
    }
    notifyListeners();
  }

  void _startListeningToCommunity() {
    FirebaseFirestore.instance.collection('users').snapshots().listen((snapshot) {
      _communityUsers = snapshot.docs
          .map((doc) => MadiUser.fromJson(doc.data(), doc.id))
          .where((u) => u.id != _currentUser?.id)
          .toList();
      notifyListeners();
    });
  }

  /// Initialize state.
  void initialize() {
    notifyListeners();
  }

  /// Update bottom nav index.
  void setTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  /// Incoming requests for the current user.
  List<SwapRequest> get incomingRequests {
    if (_currentUser == null) return [];
    return _swapRequests
        .where((r) => r.receiverId == _currentUser!.id && r.isPending)
        .toList();
  }

  /// Outgoing requests from the current user.
  List<SwapRequest> get outgoingRequests {
    if (_currentUser == null) return [];
    return _swapRequests
        .where((r) => r.requesterId == _currentUser!.id)
        .toList();
  }

  /// Send a swap request to another user.
  SwapRequest sendSwapRequest({
    required String receiverId,
    required String skillRequested,
    required String skillOffered,
    String? message,
  }) {
    final request = SwapRequest(
      requesterId: _currentUser!.id,
      receiverId: receiverId,
      skillRequested: skillRequested,
      skillOffered: skillOffered,
      message: message,
    );
    _swapRequests.add(request);
    notifyListeners();
    return request;
  }

  /// Accept a swap request (receiver side).
  void acceptSwapRequest(String requestId) {
    final request = _swapRequests.firstWhere((r) => r.id == requestId);
    request.status = SwapStatus.accepted;
    request.respondedAt = DateTime.now();
    notifyListeners();
  }

  /// Decline a swap request (receiver side).
  void declineSwapRequest(String requestId) {
    final request = _swapRequests.firstWhere((r) => r.id == requestId);
    request.status = SwapStatus.declined;
    request.respondedAt = DateTime.now();
    notifyListeners();
  }

  /// Mark a swap as completed and trigger credit transfer.
  void completeSwap(String requestId) {
    final request = _swapRequests.firstWhere((r) => r.id == requestId);
    request.status = SwapStatus.completed;
    request.completedAt = DateTime.now();
    notifyListeners();
  }

  /// Update the current user's profile.
  void updateProfile({
    String? name,
    String? bio,
    String? location,
  }) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      name: name,
      bio: bio,
      location: location,
    );
    notifyListeners();
  }

  // ────────────────────────────────────────────────────────
  //  DEMO DATA — Replace with real backend calls
  // ────────────────────────────────────────────────────────

}
