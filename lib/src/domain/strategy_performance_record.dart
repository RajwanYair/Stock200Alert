import 'package:equatable/equatable.dart';

/// Categories of trading strategy types.
enum StrategyCategory {
  trendFollowing,
  meanReversion,
  momentum,
  breakout,
  arbitrage,
}

/// A historical performance record for a named trading strategy.
class StrategyPerformanceRecord extends Equatable {
  const StrategyPerformanceRecord({
    required this.strategyId,
    required this.strategyName,
    required this.category,
    required this.totalReturnPct,
    required this.maxDrawdownPct,
    required this.winRatePct,
    required this.totalTrades,
    required this.sharpeRatio,
    required this.evaluatedAt,
  });

  final String strategyId;
  final String strategyName;
  final StrategyCategory category;

  /// Net return as a percentage (e.g. 12.5 means +12.5 %).
  final double totalReturnPct;

  /// Maximum peak-to-trough drawdown as a percentage (non-negative).
  final double maxDrawdownPct;

  /// Percentage of trades that were profitable (0–100).
  final double winRatePct;

  final int totalTrades;

  /// Annualised Sharpe ratio.
  final double sharpeRatio;

  final DateTime evaluatedAt;

  /// Returns true when the strategy has a positive Sharpe ratio and win rate
  /// at or above 50 %.
  bool get isViable => sharpeRatio > 0 && winRatePct >= 50;

  /// Risk-adjusted quality label based on Sharpe ratio thresholds.
  String get qualityLabel {
    if (sharpeRatio >= 2.0) return 'Excellent';
    if (sharpeRatio >= 1.0) return 'Good';
    if (sharpeRatio >= 0.5) return 'Acceptable';
    return 'Poor';
  }

  @override
  List<Object?> get props => [
    strategyId,
    strategyName,
    category,
    totalReturnPct,
    maxDrawdownPct,
    winRatePct,
    totalTrades,
    sharpeRatio,
    evaluatedAt,
  ];
}
