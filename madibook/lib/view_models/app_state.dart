import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/skill_model.dart';
import '../models/swap_request_model.dart';

/// Central app state: manages the current user, the community pool,
/// and all swap requests.
///
/// In production, replace the in-memory lists with API calls.
class AppState extends ChangeNotifier {
  late MadiUser _currentUser;
  List<MadiUser> _communityUsers = [];
  final List<SwapRequest> _swapRequests = [];
  int _selectedTabIndex = 0;

  MadiUser get currentUser => _currentUser;
  List<MadiUser> get communityUsers => List.unmodifiable(_communityUsers);
  List<SwapRequest> get swapRequests => List.unmodifiable(_swapRequests);
  int get selectedTabIndex => _selectedTabIndex;

  /// Incoming requests for the current user.
  List<SwapRequest> get incomingRequests => _swapRequests
      .where((r) => r.receiverId == _currentUser.id && r.isPending)
      .toList();

  /// Outgoing requests from the current user.
  List<SwapRequest> get outgoingRequests => _swapRequests
      .where((r) => r.requesterId == _currentUser.id)
      .toList();

  /// Initialize with demo data. Replace with backend auth + fetch.
  void initialize() {
    _currentUser = _createDemoCurrentUser();
    _communityUsers = _createDemoCommunity();
    notifyListeners();
  }

  /// Update bottom nav index.
  void setTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  /// Send a swap request to another user.
  SwapRequest sendSwapRequest({
    required String receiverId,
    required String skillRequested,
    required String skillOffered,
    String? message,
  }) {
    final request = SwapRequest(
      requesterId: _currentUser.id,
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
    _currentUser = _currentUser.copyWith(
      name: name,
      bio: bio,
      location: location,
    );
    notifyListeners();
  }

  // ────────────────────────────────────────────────────────
  //  DEMO DATA — Replace with real backend calls
  // ────────────────────────────────────────────────────────

  MadiUser _createDemoCurrentUser() {
    return MadiUser(
      id: 'user-madi',
      name: 'Madiyar',
      bio: 'Builder of Madibook. Passionate about connecting learners worldwide.',
      location: 'Almaty, Kazakhstan',
      madiCredits: 5.0,
      offerings: [
        Skill(name: 'Python', category: 'Programming', type: SkillType.offering),
        Skill(name: 'Flutter', category: 'Programming', type: SkillType.offering),
        Skill(name: 'UI Design', category: 'Design', type: SkillType.offering),
      ],
      seekings: [
        Skill(name: 'Guitar', category: 'Music', type: SkillType.seeking),
        Skill(name: 'Japanese', category: 'Languages', type: SkillType.seeking),
        Skill(name: 'Photography', category: 'Photography', type: SkillType.seeking),
      ],
    );
  }

  List<MadiUser> _createDemoCommunity() {
    return [
      MadiUser(
        id: 'user-aisha',
        name: 'Aisha Nurlan',
        bio: 'Music teacher and language enthusiast. Let\'s exchange skills!',
        location: 'Astana, Kazakhstan',
        madiCredits: 8.0,
        offerings: [
          Skill(name: 'Guitar', category: 'Music', type: SkillType.offering),
          Skill(name: 'Piano', category: 'Music', type: SkillType.offering),
          Skill(name: 'Kazakh', category: 'Languages', type: SkillType.offering),
        ],
        seekings: [
          Skill(name: 'Python', category: 'Programming', type: SkillType.seeking),
          Skill(name: 'UI Design', category: 'Design', type: SkillType.seeking),
        ],
      ),
      MadiUser(
        id: 'user-tomas',
        name: 'Tomas Eriksen',
        bio: 'Photographer from Stockholm. Always looking to learn new things.',
        location: 'Stockholm, Sweden',
        madiCredits: 4.0,
        offerings: [
          Skill(name: 'Photography', category: 'Photography', type: SkillType.offering),
          Skill(name: 'Lightroom', category: 'Photography', type: SkillType.offering),
        ],
        seekings: [
          Skill(name: 'Flutter', category: 'Programming', type: SkillType.seeking),
          Skill(name: 'Spanish', category: 'Languages', type: SkillType.seeking),
        ],
      ),
      MadiUser(
        id: 'user-sofia',
        name: 'Sofia Reyes',
        bio: 'Chef and fitness coach. Cooking is love made visible.',
        location: 'Mexico City, Mexico',
        madiCredits: 12.0,
        offerings: [
          Skill(name: 'Spanish', category: 'Languages', type: SkillType.offering),
          Skill(name: 'Cooking', category: 'Cooking', type: SkillType.offering),
          Skill(name: 'Fitness', category: 'Fitness', type: SkillType.offering),
        ],
        seekings: [
          Skill(name: 'Photography', category: 'Photography', type: SkillType.seeking),
          Skill(name: 'Guitar', category: 'Music', type: SkillType.seeking),
        ],
      ),
      MadiUser(
        id: 'user-kenji',
        name: 'Kenji Tanaka',
        bio: 'Japanese language tutor and hobbyist painter from Osaka.',
        location: 'Osaka, Japan',
        madiCredits: 7.0,
        offerings: [
          Skill(name: 'Japanese', category: 'Languages', type: SkillType.offering),
          Skill(name: 'Watercolor', category: 'Art', type: SkillType.offering),
        ],
        seekings: [
          Skill(name: 'Python', category: 'Programming', type: SkillType.seeking),
          Skill(name: 'Cooking', category: 'Cooking', type: SkillType.seeking),
        ],
      ),
      MadiUser(
        id: 'user-priya',
        name: 'Priya Sharma',
        bio: 'Full-stack developer who wants to learn piano and painting.',
        location: 'Bangalore, India',
        madiCredits: 6.0,
        offerings: [
          Skill(name: 'JavaScript', category: 'Programming', type: SkillType.offering),
          Skill(name: 'React', category: 'Programming', type: SkillType.offering),
          Skill(name: 'Node.js', category: 'Programming', type: SkillType.offering),
        ],
        seekings: [
          Skill(name: 'Piano', category: 'Music', type: SkillType.seeking),
          Skill(name: 'Watercolor', category: 'Art', type: SkillType.seeking),
          Skill(name: 'Cooking', category: 'Cooking', type: SkillType.seeking),
        ],
      ),
      MadiUser(
        id: 'user-lucas',
        name: 'Lucas Weber',
        bio: 'Math tutor and aspiring guitarist. Let\'s swap skills!',
        location: 'Berlin, Germany',
        madiCredits: 3.0,
        offerings: [
          Skill(name: 'Calculus', category: 'Math', type: SkillType.offering),
          Skill(name: 'Statistics', category: 'Math', type: SkillType.offering),
        ],
        seekings: [
          Skill(name: 'Guitar', category: 'Music', type: SkillType.seeking),
          Skill(name: 'Flutter', category: 'Programming', type: SkillType.seeking),
        ],
      ),
    ];
  }
}
