import 'package:equatable/equatable.dart';

/// Outcome of a deduplication check for an alert.
enum DeduplicationOutcome {
  /// Alert was accepted — no matching prior alert found.
  accepted,

  /// Alert was suppressed — an identical alert was already delivered.
  suppressed,

  /// Alert was accepted after the cooldown window expired.
  cooldownExpired,
}

/// An audit record produced when an incoming alert is evaluated for
/// deduplication against previously delivered alerts.
class AlertDeduplicationLog extends Equatable {
  /// Creates an [AlertDeduplicationLog].
  const AlertDeduplicationLog({
    required this.alertId,
    required this.ticker,
    required this.methodKey,
    required this.outcome,
    required this.evaluatedAt,
    this.priorAlertId,
    this.cooldownSeconds,
  });

  /// ID of the candidate alert being evaluated.
  final String alertId;

  /// Ticker symbol.
  final String ticker;

  /// Method key (e.g. `'micho'`, `'rsi'`).
  final String methodKey;

  /// Result of the deduplication check.
  final DeduplicationOutcome outcome;

  /// Timestamp when the check was performed.
  final DateTime evaluatedAt;

  /// ID of the prior alert that caused suppression (if any).
  final String? priorAlertId;

  /// Cooldown window in seconds that was applied (if any).
  final int? cooldownSeconds;

  /// Returns `true` when the alert was suppressed.
  bool get isSuppressed => outcome == DeduplicationOutcome.suppressed;

  /// Returns `true` when the alert was accepted (either fresh or after cooldown).
  bool get isAccepted =>
      outcome == DeduplicationOutcome.accepted ||
      outcome == DeduplicationOutcome.cooldownExpired;

  @override
  List<Object?> get props => [
    alertId,
    ticker,
    methodKey,
    outcome,
    evaluatedAt,
    priorAlertId,
    cooldownSeconds,
  ];
}
