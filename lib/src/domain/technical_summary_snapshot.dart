/// Technical Summary Snapshot — point-in-time snapshot of all major indicator
/// values for a ticker, enabling quick at-a-glance dashboards.
library;

import 'package:equatable/equatable.dart';

/// Named indicator readings captured at a single point in time.
class IndicatorReadings extends Equatable {
  const IndicatorReadings({
    this.sma50,
    this.sma150,
    this.sma200,
    this.ema12,
    this.ema26,
    this.rsi14,
    this.macd,
    this.macdSignal,
    this.bollingerUpper,
    this.bollingerLower,
    this.atr14,
    this.adx14,
    this.stochasticK,
    this.stochasticD,
    this.williamsR,
  });

  final double? sma50;
  final double? sma150;
  final double? sma200;
  final double? ema12;
  final double? ema26;
  final double? rsi14;
  final double? macd;
  final double? macdSignal;
  final double? bollingerUpper;
  final double? bollingerLower;
  final double? atr14;
  final double? adx14;
  final double? stochasticK;
  final double? stochasticD;
  final double? williamsR;

  /// Returns true if enough indicators are present for a consensus evaluation.
  bool get hasSufficientData => sma200 != null && rsi14 != null && macd != null;

  @override
  List<Object?> get props => [
    sma50,
    sma150,
    sma200,
    ema12,
    ema26,
    rsi14,
    macd,
    macdSignal,
    bollingerUpper,
    bollingerLower,
    atr14,
    adx14,
    stochasticK,
    stochasticD,
    williamsR,
  ];
}

/// Point-in-time technical summary for a single ticker.
class TechnicalSummarySnapshot extends Equatable {
  const TechnicalSummarySnapshot({
    required this.ticker,
    required this.closePrice,
    required this.readings,
    required this.snapshotAt,
  }) : assert(closePrice > 0, 'closePrice must be positive');

  final String ticker;
  final double closePrice;
  final IndicatorReadings readings;
  final DateTime snapshotAt;

  /// Price distance above/below SMA200 as a percentage, or null if unavailable.
  double? get pctFromSma200 {
    final double? sma = readings.sma200;
    if (sma == null || sma == 0) return null;
    return (closePrice - sma) / sma * 100.0;
  }

  /// Returns true if the close is above SMA200 (bullish position).
  bool? get isAboveSma200 {
    final double? sma = readings.sma200;
    if (sma == null) return null;
    return closePrice > sma;
  }

  @override
  List<Object?> get props => [ticker, closePrice, readings, snapshotAt];
}
