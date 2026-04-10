import 'package:equatable/equatable.dart';

/// Target allocation percentage for a single asset in a portfolio.
///
/// Used by rebalancing workflows to compare current weights against
/// desired weights and compute drift.
class PortfolioAllocationTarget extends Equatable {
  /// Creates a [PortfolioAllocationTarget].
  const PortfolioAllocationTarget({
    required this.ticker,
    required this.targetPct,
    required this.currentPct,
    required this.assetClass,
    this.maxDriftPct = 5.0,
  });

  /// Ticker symbol.
  final String ticker;

  /// Desired allocation as a percentage of the total portfolio (0–100).
  final double targetPct;

  /// Current allocation as a percentage of the total portfolio (0–100).
  final double currentPct;

  /// Asset class label (e.g. `'equity'`, `'bond'`, `'cash'`).
  final String assetClass;

  /// Maximum acceptable drift before a rebalance is triggered (default 5%).
  final double maxDriftPct;

  /// Signed drift: positive = overweight, negative = underweight.
  double get drift => currentPct - targetPct;

  /// Returns `true` when |drift| exceeds [maxDriftPct].
  bool get needsRebalance => drift.abs() > maxDriftPct;

  /// Returns `true` when the position is overweight.
  bool get isOverweight => drift > 0;

  @override
  List<Object?> get props => [
    ticker,
    targetPct,
    currentPct,
    assetClass,
    maxDriftPct,
  ];
}
