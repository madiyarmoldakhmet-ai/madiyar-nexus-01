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
    required MadiUser learner,
    required MadiUser teacher,
    double amount = 1.0,
  }) {
    if (learner.madiCredits < amount) {
      debugPrint(
        '❌ Transfer failed: ${learner.name} has ${learner.madiCredits} credits, '
        'needs $amount',
      );
      return false;
    }

    learner.madiCredits -= amount;
    teacher.madiCredits += amount;

    debugPrint(
      '✅ Transferred $amount credit(s): ${learner.name} → ${teacher.name}',
    );
    debugPrint(
      '   ${learner.name}: ${learner.madiCredits} | '
      '${teacher.name}: ${teacher.madiCredits}',
    );

    notifyListeners();
    return true;
  }

  /// Award bonus credits (e.g. sign-up bonus, referral, admin grant).
  /// Replace this with an API call to your backend for production.
  void awardCredits(MadiUser user, double amount) {
    user.madiCredits += amount;
    debugPrint('🎁 Awarded $amount credit(s) to ${user.name}');
    notifyListeners();
  }

  /// Check if a user can afford a swap session.
  bool canAfford(MadiUser user, {double cost = 1.0}) {
    return user.madiCredits >= cost;
  }
}
