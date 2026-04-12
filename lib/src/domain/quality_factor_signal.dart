import 'package:equatable/equatable.dart';

/// Quality factor signal based on profitability and balance-sheet strength (S539).
class QualityFactorSignal extends Equatable {
  const QualityFactorSignal({
    required this.ticker,
    required this.returnOnEquityPercent,
    required this.debtToEquityRatio,
    required this.grossProfitMarginPercent,
    required this.universePercentileRank,
    required this.isBuy,
  });

  final String ticker;
  final double returnOnEquityPercent;
  final double debtToEquityRatio;
  final double grossProfitMarginPercent;

  /// Percentile rank in the quality universe (0–100).
  final double universePercentileRank;

  /// True → high-quality buy signal.
  final bool isBuy;

  bool get isHighQuality => universePercentileRank >= 80;
  bool get isLowDebt => debtToEquityRatio <= 0.5;
  bool get isHighRoe => returnOnEquityPercent >= 15;

  @override
  List<Object?> get props => [
    ticker,
    returnOnEquityPercent,
    debtToEquityRatio,
    grossProfitMarginPercent,
    universePercentileRank,
    isBuy,
  ];
}
