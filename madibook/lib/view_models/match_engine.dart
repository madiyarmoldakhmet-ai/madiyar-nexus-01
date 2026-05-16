import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/skill_model.dart';

/// Result of a match between two users.
///
/// Contains:
/// - The matched [user]
/// - The list of [matchedSkills] that overlap
/// - A [score] from 0.0 to 1.0 indicating match quality
class MatchResult {
  final NexusUser user;
  final List<Skill> matchedSkills;
  final double score;

  const MatchResult({
    required this.user,
    required this.matchedSkills,
    required this.score,
  });

  /// Whether this is a "perfect match" — mutual overlap in both directions.
  bool get isPerfectMatch => score >= 0.8;

  @override
  String toString() =>
      'MatchResult(${user.name}, score: ${score.toStringAsFixed(2)}, '
      'skills: ${matchedSkills.map((s) => s.name).join(', ')})';
}

/// The core matching engine for Nexus.
///
/// Given a current user and a pool of all users, it finds:
/// - **Forward matches**: others who OFFER what the current user SEEKS.
/// - **Perfect matches**: mutual overlap — A seeks what B offers AND B seeks what A offers.
///
/// The algorithm is O(n × s²) where n = user count and s = avg skills per user,
/// which is efficient enough for the MVP. For scale, move this to a backend service.
class MatchEngine extends ChangeNotifier {
  List<MatchResult> _matches = [];
  bool _isSearching = false;

  List<MatchResult> get matches => List.unmodifiable(_matches);
  bool get isSearching => _isSearching;

  /// Find all users whose offerings overlap with [currentUser]'s seekings.
  ///
  /// Results are sorted by match score (highest first).
  /// Perfect matches (mutual overlap) get a score boost.
  List<MatchResult> findMatches({
    required NexusUser currentUser,
    required List<NexusUser> allUsers,
  }) {
    _isSearching = true;
    notifyListeners();

    final results = <MatchResult>[];

    for (final candidate in allUsers) {
      // Skip self
      if (candidate.id == currentUser.id) continue;

      // --- Forward match: candidate OFFERS what I SEEK ---
      final forwardMatches = <Skill>[];
      for (final seeking in currentUser.seekings) {
        for (final offering in candidate.offerings) {
          if (seeking.matchesWith(offering)) {
            forwardMatches.add(offering);
          }
        }
      }

      if (forwardMatches.isEmpty) continue;

      // --- Reverse match: candidate SEEKS what I OFFER ---
      final reverseMatches = <Skill>[];
      for (final candidateSeeking in candidate.seekings) {
        for (final myOffering in currentUser.offerings) {
          if (candidateSeeking.matchesWith(myOffering)) {
            reverseMatches.add(myOffering);
          }
        }
      }

      // Score calculation:
      // Forward match base score (what % of my seekings are covered)
      final forwardScore = currentUser.seekings.isNotEmpty
          ? forwardMatches.length / currentUser.seekings.length
          : 0.0;

      // Reverse match bonus (mutual exchange potential)
      final reverseScore = candidate.seekings.isNotEmpty
          ? reverseMatches.length / candidate.seekings.length
          : 0.0;

      // Weighted composite: forward matters more (0.6) but reverse adds boost (0.4)
      final compositeScore = (forwardScore * 0.6) + (reverseScore * 0.4);

      results.add(MatchResult(
        user: candidate,
        matchedSkills: forwardMatches,
        score: compositeScore.clamp(0.0, 1.0),
      ));
    }

    // Sort by score descending — best matches first
    results.sort((a, b) => b.score.compareTo(a.score));

    _matches = results;
    _isSearching = false;
    notifyListeners();

    debugPrint('🔍 Found ${results.length} matches for ${currentUser.name}');
    for (final r in results) {
      debugPrint('   $r');
    }

    return results;
  }

  /// Convenience: get only "perfect" matches (score ≥ 0.8).
  List<MatchResult> findPerfectMatches({
    required NexusUser currentUser,
    required List<NexusUser> allUsers,
  }) {
    final all = findMatches(currentUser: currentUser, allUsers: allUsers);
    return all.where((m) => m.isPerfectMatch).toList();
  }

  /// Clear cached results.
  void clearMatches() {
    _matches = [];
    notifyListeners();
  }
}
