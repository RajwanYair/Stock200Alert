/// Alert Event Log — pure domain value object.
///
/// Immutable record of an alert lifecycle event (created, delivered,
/// acknowledged, dismissed). Used for audit trail and analytics.
library;

import 'package:equatable/equatable.dart';

/// The type of lifecycle event for an alert.
enum AlertEventType {
  /// Alert was first generated.
  created,

  /// Notification was dispatched to a channel.
  delivered,

  /// User acknowledged the alert.
  acknowledged,

  /// User dismissed the alert.
  dismissed,

  /// Alert was suppressed (quiet hours, muted, dedup).
  suppressed;

  /// Human-readable label.
  String get label => switch (this) {
    AlertEventType.created => 'Created',
    AlertEventType.delivered => 'Delivered',
    AlertEventType.acknowledged => 'Acknowledged',
    AlertEventType.dismissed => 'Dismissed',
    AlertEventType.suppressed => 'Suppressed',
  };
}

/// An immutable log entry recording one lifecycle event of an alert.
class AlertEventLog extends Equatable {
  const AlertEventLog({
    required this.alertId,
    required this.symbol,
    required this.alertType,
    required this.eventType,
    required this.occurredAt,
    this.channel,
    this.reason,
  });

  /// ID of the alert this event refers to.
  final int alertId;

  /// Ticker symbol.
  final String symbol;

  /// The alert type name (matches [AlertType.name]).
  final String alertType;

  /// The lifecycle event type.
  final AlertEventType eventType;

  /// When this event occurred.
  final DateTime occurredAt;

  /// Delivery channel (only for [AlertEventType.delivered]).
  final String? channel;

  /// Reason for suppression (only for [AlertEventType.suppressed]).
  final String? reason;

  @override
  List<Object?> get props => [
    alertId,
    symbol,
    alertType,
    eventType,
    occurredAt,
    channel,
    reason,
  ];
}
