import 'package:equatable/equatable.dart';

/// A single percentile result from a Monte Carlo simulation (S483).
class MonteCarloPercentile extends Equatable {
  const MonteCarloPercentile({
    required this.runId,
    required this.percentile,
    required this.finalEquity,
    required this.maxDrawdownPercent,
    required this.totalReturnPercent,
  });

  final String runId;

  /// Percentile rank (0–100).
  final double percentile;

  /// Portfolio equity at the end of simulation for this percentile.
  final double finalEquity;
  final double maxDrawdownPercent;
  final double totalReturnPercent;

  bool get isProfitable => totalReturnPercent > 0;
  bool get isTopDecile => percentile >= 90;
  bool get isBottomDecile => percentile <= 10;

  @override
  List<Object?> get props => [
    runId,
    percentile,
    finalEquity,
    maxDrawdownPercent,
    totalReturnPercent,
  ];
}
