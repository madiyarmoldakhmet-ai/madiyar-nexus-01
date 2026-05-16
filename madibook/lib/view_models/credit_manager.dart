import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

/// Manages Nexus-Credit transactions.
///
/// All credit mutations go through this class so that:
/// 1. Business rules are centralized (minimum balance, validation).
/// 2. It's trivial to swap in a backend API call later.
/// 3. The UI reactively updates via ChangeNotifier.
class CreditManager extends ChangeNotifier {
  /// Transfer 1 Nexus-Credit from [learner] to [teacher].
  ///
  /// Returns `true` if the transfer succeeded.
  /// Returns `false` if the learner has insufficient credits.
  bool transferCredit({
    required NexusUser learner,
    required NexusUser teacher,
    double amount = 1.0,
  }) {
    if (learner.nexusCredits < amount) {
      debugPrint(
        '❌ Transfer failed: ${learner.name} has ${learner.nexusCredits} credits, '
        'needs $amount',
      );
      return false;
    }

    learner.nexusCredits -= amount;
    teacher.nexusCredits += amount;

    debugPrint(
      '✅ Transferred $amount credit(s): ${learner.name} → ${teacher.name}',
    );
    debugPrint(
      '   ${learner.name}: ${learner.nexusCredits} | '
      '${teacher.name}: ${teacher.nexusCredits}',
    );

    notifyListeners();
    return true;
  }

  /// Award bonus credits (e.g. sign-up bonus, referral, admin grant).
  /// Replace this with an API call to your backend for production.
  void awardCredits(NexusUser user, double amount) {
    user.nexusCredits += amount;
    debugPrint('🎁 Awarded $amount credit(s) to ${user.name}');
    notifyListeners();
  }

  /// Check if a user can afford a swap session.
  bool canAfford(NexusUser user, {double cost = 1.0}) {
    return user.nexusCredits >= cost;
  }
}
