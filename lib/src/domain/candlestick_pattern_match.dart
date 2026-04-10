import 'package:equatable/equatable.dart';

import 'candlestick_pattern_detector.dart';

/// Signal bias implied by a candlestick pattern.
enum PatternBias { bullish, bearish, neutral }

/// A matched candlestick pattern at a specific candle index.
class CandlestickPatternMatch extends Equatable {
  const CandlestickPatternMatch({
    required this.ticker,
    required this.patternType,
    required this.bias,
    required this.candleDate,
    required this.confidenceScore,
  });

  final String ticker;
  final CandlestickPatternType patternType;
  final PatternBias bias;
  final DateTime candleDate;

  /// Confidence in the pattern identification (0.0–1.0).
  final double confidenceScore;

  /// Returns true when confidence is high (>= 0.75).
  bool get isHighConfidence => confidenceScore >= 0.75;

  @override
  List<Object?> get props => [
    ticker,
    patternType,
    bias,
    candleDate,
    confidenceScore,
  ];
}
