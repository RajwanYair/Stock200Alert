/// Alert Deduplicator — pure domain utility.
///
/// Prevents the same logical alert from firing multiple times within a
/// configurable cooldown window. Uses candle-date deduplication.
library;

import 'package:equatable/equatable.dart';

/// A dedup key that uniquely identifies a logical alert firing.
class AlertDedupKey extends Equatable {
  const AlertDedupKey({
    required this.symbol,
    required this.alertType,
    required this.candleDate,
  });

  /// Ticker symbol.
  final String symbol;

  /// Alert type name.
  final String alertType;

  /// The candle date on which the alert fired.
  final DateTime candleDate;

  @override
  List<Object?> get props => [symbol, alertType, candleDate];
}

/// Result of a dedup check.
enum DedupDecision {
  /// This alert is new — fire it.
  fire,

  /// This alert is a duplicate — suppress it.
  suppress,
}

/// Deduplicates alerts by (symbol, alertType, candleDate) with an optional
/// cooldown window.
class AlertDeduplicator {
  /// Create a deduplicator with a set of already-fired keys.
  const AlertDeduplicator({
    this.firedKeys = const {},
    this.cooldown = Duration.zero,
  });

  /// Set of keys that have already been fired.
  final Set<AlertDedupKey> firedKeys;

  /// Minimum time between re-firing the same logical alert.
  /// [Duration.zero] means strict candle-date dedup (same date = suppress).
  final Duration cooldown;

  /// Check whether [key] should fire or be suppressed.
  DedupDecision check(AlertDedupKey key) {
    if (firedKeys.contains(key)) return DedupDecision.suppress;
    return DedupDecision.fire;
  }

  /// Check with cooldown: [key] is suppressed if a matching key was
  /// fired after [now] minus [cooldown].
  DedupDecision checkWithCooldown(
    AlertDedupKey key, {
    required DateTime now,
    required Map<AlertDedupKey, DateTime> firedAt,
  }) {
    final DateTime? lastFired = firedAt[key];
    if (lastFired == null) return DedupDecision.fire;
    if (cooldown == Duration.zero) return DedupDecision.suppress;
    if (now.difference(lastFired) < cooldown) return DedupDecision.suppress;
    return DedupDecision.fire;
  }

  /// Return a new deduplicator with [key] added to fired keys.
  AlertDeduplicator recordFired(AlertDedupKey key) =>
      AlertDeduplicator(firedKeys: {...firedKeys, key}, cooldown: cooldown);
}
