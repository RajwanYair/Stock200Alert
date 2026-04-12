import 'package:equatable/equatable.dart';

/// A record of a consensus signal being overridden by the user (S469).
class ConsensusOverrideRecord extends Equatable {
  const ConsensusOverrideRecord({
    required this.recordId,
    required this.ticker,
    required this.originalSignal,
    required this.overriddenSignal,
    required this.overriddenBy,
    this.reason = '',
  });

  final String recordId;
  final String ticker;

  /// Signal direction before override (e.g. 'BUY', 'SELL', 'NEUTRAL').
  final String originalSignal;

  /// Signal direction after override.
  final String overriddenSignal;
  final String overriddenBy;
  final String reason;

  bool get isEscalated =>
      originalSignal == 'NEUTRAL' &&
      (overriddenSignal == 'BUY' || overriddenSignal == 'SELL');
  bool get isDemoted =>
      (originalSignal == 'BUY' || originalSignal == 'SELL') &&
      overriddenSignal == 'NEUTRAL';
  bool get hasReason => reason.isNotEmpty;

  @override
  List<Object?> get props => [
    recordId,
    ticker,
    originalSignal,
    overriddenSignal,
    overriddenBy,
    reason,
  ];
}
