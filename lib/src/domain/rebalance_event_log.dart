import 'package:equatable/equatable.dart';

/// Lifecycle stage of a portfolio rebalance operation.
enum RebalanceEventType {
  /// Drift threshold crossed — rebalance needed.
  triggered,

  /// Rebalance plan reviewed and approved.
  approved,

  /// Orders placed and executed.
  executed,

  /// Conditions no longer met — rebalance skipped.
  skipped,

  /// Rebalance manually cancelled before execution.
  cancelled,
}

/// A single audit-log entry in a portfolio's rebalance event history.
class RebalanceEventLog extends Equatable {
  /// Creates a [RebalanceEventLog].
  const RebalanceEventLog({
    required this.eventId,
    required this.portfolioId,
    required this.eventType,
    required this.occurredAt,
    this.triggerReason,
  });

  /// Unique identifier for this event record.
  final String eventId;

  /// Identifier of the portfolio being rebalanced.
  final String portfolioId;

  /// The lifecycle stage this entry represents.
  final RebalanceEventType eventType;

  /// When this event occurred.
  final DateTime occurredAt;

  /// Human-readable reason that triggered the rebalance (`null` unless
  /// [eventType] is [triggered]).
  final String? triggerReason;

  /// Returns `true` when the rebalance process has reached a final state.
  bool get isTerminal =>
      eventType == RebalanceEventType.executed ||
      eventType == RebalanceEventType.cancelled;

  /// Returns `true` when a trigger reason is recorded.
  bool get hasTriggerReason => triggerReason != null;

  @override
  List<Object?> get props => [
    eventId,
    portfolioId,
    eventType,
    occurredAt,
    triggerReason,
  ];
}
