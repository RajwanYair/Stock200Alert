import 'package:equatable/equatable.dart';

/// Allocation drift for a single position in the portfolio.
class AllocationDriftEntry extends Equatable {
  /// Creates an [AllocationDriftEntry].
  const AllocationDriftEntry({
    required this.ticker,
    required this.targetWeight,
    required this.actualWeight,
  });

  /// Ticker symbol.
  final String ticker;

  /// Target allocation weight as a percentage (0–100).
  final double targetWeight;

  /// Current actual allocation weight as a percentage (0–100).
  final double actualWeight;

  /// Signed drift: positive = overweight; negative = underweight.
  double get drift => actualWeight - targetWeight;

  /// Returns `true` when the position is above its target weight.
  bool get isOverweight => actualWeight > targetWeight;

  @override
  List<Object?> get props => [ticker, targetWeight, actualWeight];
}

/// Point-in-time report of how each position has drifted from its target.
class AllocationDriftReport extends Equatable {
  /// Creates an [AllocationDriftReport].
  const AllocationDriftReport({
    required this.portfolioId,
    required this.reportDate,
    required this.entries,
  });

  /// Portfolio identifier.
  final String portfolioId;

  /// Date of the drift calculation.
  final DateTime reportDate;

  /// Per-position drift details.
  final List<AllocationDriftEntry> entries;

  /// Maximum absolute drift across all positions.
  double get maxDrift => entries.isEmpty
      ? 0.0
      : entries
            .map((AllocationDriftEntry e) => e.drift.abs())
            .reduce((double a, double b) => a > b ? a : b);

  /// Returns `true` when any position has drifted more than 5 percent.
  bool get hasMaterialDrift => maxDrift > 5.0;

  /// Number of positions in this report.
  int get entryCount => entries.length;

  @override
  List<Object?> get props => [portfolioId, reportDate, entries];
}
