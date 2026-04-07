/// Micho Method Detector — Pure domain logic.
///
/// Implements the Micho Method trading strategy using the 150-day SMA:
///
/// **BUY signal** (all conditions must be met):
///   1. Price crosses above MA150: close[t-1] <= sma150[t-1] AND close[t] > sma150[t]
///   2. Price is within ~5% above MA150: (close[t] - sma150[t]) / sma150[t] <= 0.05
///   3. MA150 is flat or rising: sma150[t] >= sma150[t-1]
///
/// **SELL signal**:
///   Price crosses below MA150: close[t-1] >= sma150[t-1] AND close[t] < sma150[t]
///
/// Designed as an extensible "trading method" pattern — other methods can
/// follow the same [MethodSignal] / detector structure.
library;

import 'package:equatable/equatable.dart';

import 'entities.dart';
import 'sma_calculator.dart';

// ---------------------------------------------------------------------------
// Method signal — generic result type for trading-method detectors
// ---------------------------------------------------------------------------

/// A signal produced by a trading method detector.
///
/// Other methods (e.g. a future "Golden Ratio Method") can reuse this class
/// or extend it with method-specific fields.
class MethodSignal extends Equatable {
  const MethodSignal({
    required this.ticker,
    required this.methodName,
    required this.alertType,
    required this.isTriggered,
    required this.evaluatedAt,
    this.currentClose,
    this.currentSma,
    this.previousClose,
    this.previousSma,
    this.smaSlope,
    this.priceToSmaRatio,
    this.description,
  });

  final String ticker;

  /// Human-readable name of the method (e.g. 'Micho Method').
  final String methodName;

  /// The [AlertType] this signal maps to.
  final AlertType alertType;

  /// Whether the signal condition was met on this evaluation.
  final bool isTriggered;

  final DateTime evaluatedAt;

  // --- Optional context for notifications / UI ---
  final double? currentClose;
  final double? currentSma;
  final double? previousClose;
  final double? previousSma;

  /// sma[t] - sma[t-1]; positive = rising, negative = falling.
  final double? smaSlope;

  /// (close - sma) / sma; shows how far price is from the MA.
  final double? priceToSmaRatio;

  /// Human-readable description of what happened.
  final String? description;

  @override
  List<Object?> get props => [
    ticker,
    methodName,
    alertType,
    isTriggered,
    evaluatedAt,
    currentClose,
    currentSma,
    previousClose,
    previousSma,
    smaSlope,
    priceToSmaRatio,
    description,
  ];
}

// ---------------------------------------------------------------------------
// Micho Method Detector
// ---------------------------------------------------------------------------

class MichoMethodDetector {
  const MichoMethodDetector({
    this.smaCalculator = const SmaCalculator(),
    this.maxAboveRatio = 0.05,
  });

  final SmaCalculator smaCalculator;

  /// Maximum (close - sma150) / sma150 ratio for a valid BUY signal.
  /// Default 0.05 = 5% above MA150.
  final double maxAboveRatio;

  static const String methodName = 'Micho Method';
  static const int _period = 150;

  /// Minimum candles needed: period + 1 (to compare sma[t] vs sma[t-1]).
  static const int requiredCandles = _period + 1;

  /// Evaluate for a Micho Method **BUY** signal.
  ///
  /// Returns null when there is insufficient data.
  MethodSignal? evaluateBuy({
    required String ticker,
    required List<DailyCandle> candles,
  }) {
    final data = _computeBase(ticker: ticker, candles: candles);
    if (data == null) return null;

    final closeT = data.closeT;
    final closeTm1 = data.closeTm1;
    final smaT = data.smaT;
    final smaTm1 = data.smaTm1;

    // 1. Cross-up: close[t-1] <= sma150[t-1] AND close[t] > sma150[t]
    final isCrossUp = closeTm1 <= smaTm1 && closeT > smaT;

    // 2. Price within maxAboveRatio of MA150
    final ratio = (closeT - smaT) / smaT;
    final isNearMa = ratio >= 0 && ratio <= maxAboveRatio;

    // 3. MA150 is flat or rising
    final slope = smaT - smaTm1;
    final isMaFlatOrRising = slope >= 0;

    final isTriggered = isCrossUp && isNearMa && isMaFlatOrRising;

    return MethodSignal(
      ticker: ticker,
      methodName: methodName,
      alertType: AlertType.michoMethodBuy,
      isTriggered: isTriggered,
      evaluatedAt: DateTime.now(),
      currentClose: closeT,
      currentSma: smaT,
      previousClose: closeTm1,
      previousSma: smaTm1,
      smaSlope: slope,
      priceToSmaRatio: ratio,
      description: isTriggered
          ? 'BUY: price crossed above MA150 '
                '(\$${closeT.toStringAsFixed(2)} > \$${smaT.toStringAsFixed(2)}), '
                'MA150 ${slope >= 0 ? "rising" : "falling"}'
          : null,
    );
  }

  /// Evaluate for a Micho Method **SELL** signal.
  ///
  /// Fires when price crosses from above MA150 to below it.
  /// Returns null when there is insufficient data.
  MethodSignal? evaluateSell({
    required String ticker,
    required List<DailyCandle> candles,
  }) {
    final data = _computeBase(ticker: ticker, candles: candles);
    if (data == null) return null;

    final closeT = data.closeT;
    final closeTm1 = data.closeTm1;
    final smaT = data.smaT;
    final smaTm1 = data.smaTm1;

    // Sell: close[t-1] >= sma150[t-1] AND close[t] < sma150[t]
    final isCrossDown = closeTm1 >= smaTm1 && closeT < smaT;

    final slope = smaT - smaTm1;
    final ratio = (closeT - smaT) / smaT;

    return MethodSignal(
      ticker: ticker,
      methodName: methodName,
      alertType: AlertType.michoMethodSell,
      isTriggered: isCrossDown,
      evaluatedAt: DateTime.now(),
      currentClose: closeT,
      currentSma: smaT,
      previousClose: closeTm1,
      previousSma: smaTm1,
      smaSlope: slope,
      priceToSmaRatio: ratio,
      description: isCrossDown
          ? 'SELL: price crossed below MA150 '
                '(\$${closeT.toStringAsFixed(2)} < \$${smaT.toStringAsFixed(2)})'
          : null,
    );
  }

  /// Evaluate both BUY and SELL in one pass.
  ///
  /// Returns a list of triggered signals (0–2 items).
  /// Only signals where [MethodSignal.isTriggered] is true are included.
  List<MethodSignal> evaluateBoth({
    required String ticker,
    required List<DailyCandle> candles,
  }) {
    final buy = evaluateBuy(ticker: ticker, candles: candles);
    final sell = evaluateSell(ticker: ticker, candles: candles);
    return [
      if (buy != null && buy.isTriggered) buy,
      if (sell != null && sell.isTriggered) sell,
    ];
  }

  // ---- Private helpers ----

  _BaseData? _computeBase({
    required String ticker,
    required List<DailyCandle> candles,
  }) {
    if (candles.length < requiredCandles) return null;

    final candleT = candles[candles.length - 1];
    final candleTm1 = candles[candles.length - 2];

    final smaT = smaCalculator.compute(candles, period: _period);
    if (smaT == null) return null;

    final candlesTm1 = candles.sublist(0, candles.length - 1);
    final smaTm1 = smaCalculator.compute(candlesTm1, period: _period);
    if (smaTm1 == null) return null;

    return _BaseData(
      closeT: candleT.close,
      closeTm1: candleTm1.close,
      smaT: smaT,
      smaTm1: smaTm1,
    );
  }
}

class _BaseData {
  const _BaseData({
    required this.closeT,
    required this.closeTm1,
    required this.smaT,
    required this.smaTm1,
  });

  final double closeT;
  final double closeTm1;
  final double smaT;
  final double smaTm1;
}
