/// Trade Level Calculator — Recommended buy price and stop-loss.
///
/// Combines ATR-based volatility with key moving-average support levels to
/// produce actionable entry and stop-loss price recommendations.
///
/// **Buy price**: The highest nearby support level (SMA150, SMA200, or the
/// lower Bollinger Band), capped at the current close.  When no support data
/// is available the close price itself is returned.
///
/// **Stop-loss**: `buyPrice − atrMultiplier × ATR`.  A tighter multiplier
/// (e.g. 1.5) suits short-term trades; a wider one (e.g. 2.5) suits swing
/// or position trades.
///
/// **Risk/reward ratio**: `(close − buyPrice) / (buyPrice − stopLoss)` when
/// the denominator is positive.
library;

import 'package:equatable/equatable.dart';

import 'atr_calculator.dart';
import 'bollinger_calculator.dart';
import 'entities.dart';
import 'sma_calculator.dart';

/// The calculated trade-entry and stop-loss levels for a ticker.
class TradeLevels extends Equatable {
  const TradeLevels({
    required this.symbol,
    required this.currentClose,
    required this.recommendedBuy,
    required this.stopLoss,
    required this.atr,
    required this.atrMultiplier,
    this.supportSma150,
    this.supportSma200,
    this.supportBollingerLower,
  });

  final String symbol;

  /// Most recent closing price.
  final double currentClose;

  /// Recommended entry (buy) price — near the strongest support level.
  final double recommendedBuy;

  /// Recommended stop-loss price — below entry by an ATR-based buffer.
  final double stopLoss;

  /// The ATR value used (absolute, in price units).
  final double atr;

  /// The multiplier applied to ATR for the stop-loss distance.
  final double atrMultiplier;

  /// SMA 150 value (if available).
  final double? supportSma150;

  /// SMA 200 value (if available).
  final double? supportSma200;

  /// Lower Bollinger Band (if available).
  final double? supportBollingerLower;

  /// Distance from buy price to stop-loss (always ≥ 0).
  double get riskAmount => recommendedBuy - stopLoss;

  /// Risk as a percentage of the buy price.
  double get riskPercent =>
      recommendedBuy > 0 ? (riskAmount / recommendedBuy) * 100 : 0;

  /// Potential upside from the buy price to the current close (may be zero
  /// when the buy price equals the close).
  double get rewardAmount => currentClose - recommendedBuy;

  /// Reward-to-risk ratio.  Returns `null` when risk is zero.
  double? get rewardToRisk => riskAmount > 0 ? rewardAmount / riskAmount : null;

  @override
  List<Object?> get props => [
    symbol,
    currentClose,
    recommendedBuy,
    stopLoss,
    atr,
    atrMultiplier,
    supportSma150,
    supportSma200,
    supportBollingerLower,
  ];
}

/// Computes recommended buy and stop-loss levels for a ticker.
///
/// Requires at least enough candles for the ATR calculation (default 15).
/// Returns `null` when data is insufficient.
class TradeLevelCalculator {
  const TradeLevelCalculator({
    this.atrMultiplier = 2.0,
    this.atrCalculator = const AtrCalculator(),
    this.smaCalculator = const SmaCalculator(),
    this.bollingerCalculator = const BollingerCalculator(),
  });

  /// How many ATR units below the buy price the stop-loss is placed.
  final double atrMultiplier;

  final AtrCalculator atrCalculator;
  final SmaCalculator smaCalculator;
  final BollingerCalculator bollingerCalculator;

  /// Compute trade levels for [symbol] given its [candles].
  ///
  /// Returns `null` when there are too few candles for the ATR.
  TradeLevels? compute(String symbol, List<DailyCandle> candles) {
    if (candles.isEmpty) return null;

    // ATR is mandatory — without it we cannot size the stop-loss.
    final AtrResult? atrResult = atrCalculator.compute(candles);
    if (atrResult == null) return null;

    final double close = candles.last.close;
    final double atr = atrResult.atr;

    // Gather support levels: SMA150, SMA200, lower Bollinger Band.
    final double? sma150 = _latestSma(candles, 150);
    final double? sma200 = _latestSma(candles, 200);
    final double? bollingerLower = _latestBollingerLower(candles);

    // Choose the highest support level that is at or below the current close.
    // This is the nearest strong support where a buy limit order makes sense.
    final List<double> supports = [
      if (sma150 != null && sma150 <= close) sma150,
      if (sma200 != null && sma200 <= close) sma200,
      if (bollingerLower != null && bollingerLower <= close) bollingerLower,
    ];

    final double buyPrice = supports.isEmpty ? close : supports.reduce(_max);

    final double stopLoss = buyPrice - atrMultiplier * atr;

    return TradeLevels(
      symbol: symbol,
      currentClose: close,
      recommendedBuy: buyPrice,
      stopLoss: stopLoss,
      atr: atr,
      atrMultiplier: atrMultiplier,
      supportSma150: sma150,
      supportSma200: sma200,
      supportBollingerLower: bollingerLower,
    );
  }

  // ── Private helpers ─────────────────────────────────────────────────────

  double? _latestSma(List<DailyCandle> candles, int period) {
    final List<(DateTime, double?)> series = smaCalculator.computeSeries(
      candles,
      period: period,
    );
    if (series.isEmpty) return null;
    final (_, double? value) = series.last;
    return value;
  }

  double? _latestBollingerLower(List<DailyCandle> candles) {
    final List<BollingerResult> series = bollingerCalculator.computeSeries(
      candles,
    );
    if (series.isEmpty) return null;
    return series.last.lower;
  }

  static double _max(double a, double b) => a > b ? a : b;
}
