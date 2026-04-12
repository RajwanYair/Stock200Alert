import 'package:equatable/equatable.dart';

/// Tracking error of a portfolio relative to a benchmark (S480).
class TrackingErrorResult extends Equatable {
  const TrackingErrorResult({
    required this.portfolioId,
    required this.benchmarkTicker,
    required this.trackingErrorPercent,
    required this.activeReturnPercent,
    required this.correlationWithBenchmark,
    required this.periodDays,
  });

  final String portfolioId;
  final String benchmarkTicker;

  /// Annualized tracking error as a percentage.
  final double trackingErrorPercent;
  final double activeReturnPercent;

  /// Pearson correlation with benchmark returns (–1 to 1).
  final double correlationWithBenchmark;
  final int periodDays;

  bool get isLowTracking => trackingErrorPercent < 2.0;
  bool get isHighlyCorrelated => correlationWithBenchmark >= 0.95;
  bool get isActivelyManaged => trackingErrorPercent >= 5.0;

  @override
  List<Object?> get props => [
    portfolioId,
    benchmarkTicker,
    trackingErrorPercent,
    activeReturnPercent,
    correlationWithBenchmark,
    periodDays,
  ];
}
