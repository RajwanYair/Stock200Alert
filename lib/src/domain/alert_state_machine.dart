/// Alert State Machine — Pure domain logic.
///
/// Manages the per-ticker alert lifecycle:
///   below → cross-up detected + rising → ALERT → above
///   above → stays above → no alert (idempotent)
///   above → crosses back below → below
///   below → cross-up detected + rising → ALERT → above (can fire again)
///
/// This is a pure function: it takes the previous state + evaluation
/// and returns the new state. Persistence is handled externally.
library;

import 'entities.dart';

class AlertStateMachine {
  const AlertStateMachine();

  /// Transition the alert state based on a new evaluation.
  ///
  /// Returns the new [TickerAlertState] to persist.
  TickerAlertState transition(
    TickerAlertState previous,
    CrossUpEvaluation evaluation,
  ) {
    var newState = previous.copyWith(
      lastStatus: evaluation.currentRelation,
      lastEvaluatedAt: evaluation.evaluatedAt,
      lastCloseUsed: evaluation.currentClose,
      lastSma200: evaluation.currentSma200,
    );

    // If alert should fire, record the cross-up date.
    if (evaluation.shouldAlert) {
      newState = newState.copyWith(
        lastAlertedCrossUpAt: evaluation.evaluatedAt,
      );
    }

    return newState;
  }

  /// Check if we're currently in quiet hours.
  /// [quietStart] and [quietEnd] are hours (0-23).
  /// Returns true if [now] falls within the quiet window.
  bool isInQuietHours({required DateTime now, int? quietStart, int? quietEnd}) {
    if (quietStart == null || quietEnd == null) return false;

    final hour = now.hour;
    if (quietStart <= quietEnd) {
      // Same-day window: e.g. 22-06 doesn't apply here, 09-17 does
      return hour >= quietStart && hour < quietEnd;
    } else {
      // Overnight window: e.g. 22-06
      return hour >= quietStart || hour < quietEnd;
    }
  }
}
