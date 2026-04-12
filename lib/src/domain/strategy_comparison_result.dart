import 'package:equatable/equatable.dart';

/// Side-by-side strategy performance comparison result (S481).
class StrategyComparisonResult extends Equatable {
  const StrategyComparisonResult({
    required this.baseStrategyId,
    required this.compareStrategyId,
    required this.baseReturnPercent,
    required this.compareReturnPercent,
    required this.baseSharpe,
    required this.compareSharpe,
    required this.periodDays,
  });

  final String baseStrategyId;
  final String compareStrategyId;

  /// Annualised return of the base strategy.
  final double baseReturnPercent;

  /// Annualised return of the comparison strategy.
  final double compareReturnPercent;
  final double baseSharpe;
  final double compareSharpe;
  final int periodDays;

  /// True when the compare strategy outperforms the base strategy.
  bool get compareOutperforms => compareReturnPercent > baseReturnPercent;

  /// Absolute return difference (compare minus base).
  double get returnDeltaPercent => compareReturnPercent - baseReturnPercent;

  /// True when comparison Sharpe > base Sharpe.
  bool get compareHasBetterSharpe => compareSharpe > baseSharpe;

  @override
  List<Object?> get props => [
    baseStrategyId,
    compareStrategyId,
    baseReturnPercent,
    compareReturnPercent,
    baseSharpe,
    compareSharpe,
    periodDays,
  ];
}
