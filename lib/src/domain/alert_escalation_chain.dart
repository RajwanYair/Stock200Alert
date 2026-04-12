import 'package:equatable/equatable.dart';

/// A chain of notification channels to escalate through for unacknowledged alerts (S468).
class AlertEscalationChain extends Equatable {
  const AlertEscalationChain({
    required this.chainId,
    required this.ticker,
    required this.channels,
    required this.escalationDelaySeconds,
    this.isEnabled = true,
    this.maxEscalations = 3,
  });

  final String chainId;
  final String ticker;

  /// Ordered list of notification channel names to escalate through.
  final List<String> channels;

  /// Delay in seconds before advancing to next channel.
  final int escalationDelaySeconds;
  final bool isEnabled;
  final int maxEscalations;

  int get channelCount => channels.length;
  bool get isMultiChannel => channelCount > 1;
  bool get isAggressiveEscalation => escalationDelaySeconds < 300;

  @override
  List<Object?> get props => [
    chainId,
    ticker,
    channels,
    escalationDelaySeconds,
    isEnabled,
    maxEscalations,
  ];
}
