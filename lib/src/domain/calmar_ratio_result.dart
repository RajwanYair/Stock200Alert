import 'package:equatable/equatable.dart';

/// Calmar ratio: annualized return divided by max drawdown (S478).
class CalmarRatioResult extends Equatable {
  const CalmarRatioResult({
    required this.portfolioId,
    required this.annualizedReturnPercent,
    required this.maxDrawdownPercent,
    required this.calmarRatio,
    required this.periodDays,
  });

  final String portfolioId;
  final double annualizedReturnPercent;

  /// Maximum drawdown as a positive percentage value.
  final double maxDrawdownPercent;
  final double calmarRatio;
  final int periodDays;

  bool get isAcceptable => calmarRatio >= 0.5;
  bool get isStrong => calmarRatio >= 1.0;
  bool get isNegativeReturn => annualizedReturnPercent < 0;

  @override
  List<Object?> get props => [
    portfolioId,
    annualizedReturnPercent,
    maxDrawdownPercent,
    calmarRatio,
    periodDays,
  ];
}
