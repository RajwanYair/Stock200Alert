import 'package:equatable/equatable.dart';

/// Aggregated signal-processing funnel for a single ticker:
/// how many signals were detected, evaluated, triggered, and sent.
class SignalFunnelSummary extends Equatable {
  const SignalFunnelSummary({
    required this.ticker,
    required this.detectedCount,
    required this.evaluatedCount,
    required this.triggeredCount,
    required this.sentCount,
    required this.periodStart,
    required this.periodEnd,
  });

  final String ticker;

  /// Raw signals detected (before evaluation filters).
  final int detectedCount;

  /// Signals that passed evaluation rules.
  final int evaluatedCount;

  /// Signals that crossed the trigger threshold.
  final int triggeredCount;

  /// Signals successfully dispatched to the delivery channel.
  final int sentCount;

  final DateTime periodStart;
  final DateTime periodEnd;

  SignalFunnelSummary copyWith({
    String? ticker,
    int? detectedCount,
    int? evaluatedCount,
    int? triggeredCount,
    int? sentCount,
    DateTime? periodStart,
    DateTime? periodEnd,
  }) => SignalFunnelSummary(
    ticker: ticker ?? this.ticker,
    detectedCount: detectedCount ?? this.detectedCount,
    evaluatedCount: evaluatedCount ?? this.evaluatedCount,
    triggeredCount: triggeredCount ?? this.triggeredCount,
    sentCount: sentCount ?? this.sentCount,
    periodStart: periodStart ?? this.periodStart,
    periodEnd: periodEnd ?? this.periodEnd,
  );

  @override
  List<Object?> get props => [
    ticker,
    detectedCount,
    evaluatedCount,
    triggeredCount,
    sentCount,
    periodStart,
    periodEnd,
  ];
}
