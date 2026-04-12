import 'package:equatable/equatable.dart';

/// Category of market regime used in classification results (S453).
enum RegimeClassificationType {
  bullTrending,
  bearTrending,
  rangebound,
  highVolatility,
  lowVolatility,
}

/// Classification of the current market regime for a ticker or index (S453).
class MarketRegimeClassification extends Equatable {
  const MarketRegimeClassification({
    required this.ticker,
    required this.regime,
    required this.confidenceScore,
    required this.adxValue,
    required this.atrPercent,
  });

  final String ticker;
  final RegimeClassificationType regime;

  /// Confidence in the classification (0–1).
  final double confidenceScore;
  final double adxValue;

  /// ATR as a percentage of price.
  final double atrPercent;

  bool get isTrending =>
      regime == RegimeClassificationType.bullTrending ||
      regime == RegimeClassificationType.bearTrending;
  bool get isRangebound => regime == RegimeClassificationType.rangebound;
  bool get isHighConfidence => confidenceScore >= 0.75;

  @override
  List<Object?> get props => [
    ticker,
    regime,
    confidenceScore,
    adxValue,
    atrPercent,
  ];
}
