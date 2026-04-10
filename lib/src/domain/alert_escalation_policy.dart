import 'package:equatable/equatable.dart';

/// Escalation channel for unacknowledged alerts.
enum EscalationChannel { pushNotification, email, sms, inApp }

/// Policy governing when and how an unacknowledged alert is escalated.
class AlertEscalationPolicy extends Equatable {
  const AlertEscalationPolicy({
    required this.policyId,
    required this.escalationChannel,
    required this.initialDelayMinutes,
    required this.repeatIntervalMinutes,
    required this.maxEscalations,
    this.isEnabled = true,
  });

  final String policyId;
  final EscalationChannel escalationChannel;

  /// Minutes after initial alert before first escalation.
  final int initialDelayMinutes;

  /// Minutes between repeated escalations.
  final int repeatIntervalMinutes;

  /// Maximum number of escalation attempts (0 = unlimited).
  final int maxEscalations;

  final bool isEnabled;

  /// Returns true when repeat escalation is configured.
  bool get isRepeating => repeatIntervalMinutes > 0;

  /// Returns true when max escalations limit is unbounded.
  bool get isUnbounded => maxEscalations == 0;

  @override
  List<Object?> get props => [
    policyId,
    escalationChannel,
    initialDelayMinutes,
    repeatIntervalMinutes,
    maxEscalations,
    isEnabled,
  ];
}
