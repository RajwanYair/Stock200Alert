/// Cross-Up Detector — Pure domain logic.
///
/// Determines whether a stock has crossed above its SMA200 while rising.
///
/// Cross-up definition (KEY RULE):
///   close[t-1] <= sma200[t-1]  AND  close[t] > sma200[t]
///
/// Rising definition (configurable):
///   Strictness 1: close[t] > close[t-1]
///   Strictness N: close[t] > close[t-1] > ... > close[t-N+1]
///                 (N consecutive days of higher closes)
library;

import 'entities.dart';
import 'sma_calculator.dart';

class CrossUpDetector {
  const CrossUpDetector({this.smaCalculator = const SmaCalculator()});

  final SmaCalculator smaCalculator;

  /// Evaluate a ticker for cross-up. Requires at least 201 candles (to have
  /// both sma200[t] and sma200[t-1]) and at least [trendStrictnessDays + 1]
  /// candles for the rising check.
  ///
  /// [candles] must be sorted ascending by date.
  /// [previousState] is the last persisted alert state (for idempotency).
  /// [trendStrictnessDays] controls how many consecutive rising days are needed.
  ///
  /// Returns a [CrossUpEvaluation] describing the full result.
  CrossUpEvaluation? evaluate({
    required String ticker,
    required List<DailyCandle> candles,
    required TickerAlertState previousState,
    int trendStrictnessDays = 1,
  }) {
    // Need at least 201 candles to compute sma200[t] and sma200[t-1].
    if (candles.length < 201) return null;

    final now = DateTime.now();

    // Current (t) and previous (t-1) candles
    final candleT = candles[candles.length - 1];
    final candleTm1 = candles[candles.length - 2];

    // SMA200 at t: uses candles[length-200 .. length-1] (inclusive)
    final sma200T = smaCalculator.compute(candles, period: 200);
    if (sma200T == null) return null;

    // SMA200 at t-1: uses candles[length-201 .. length-2] (inclusive)
    final candlesForTm1 = candles.sublist(0, candles.length - 1);
    final sma200Tm1 = smaCalculator.compute(candlesForTm1, period: 200);
    if (sma200Tm1 == null) return null;

    // Cross-up check: close[t-1] <= sma200[t-1] AND close[t] > sma200[t]
    final isCrossUp = candleTm1.close <= sma200Tm1 && candleT.close > sma200T;

    // Rising check with configurable strictness
    final isRising = _checkRising(candles, trendStrictnessDays);

    // Current relation
    final currentRelation = candleT.close > sma200T
        ? SmaRelation.above
        : SmaRelation.below;

    // Idempotent alert: only fire if cross-up AND rising AND not already alerted
    // for this cross-up event. "Already alerted" means lastStatus was already
    // 'above' (the price hasn't crossed back down since last alert).
    final alreadyAlerted = previousState.lastStatus == SmaRelation.above;
    final shouldAlert = isCrossUp && isRising && !alreadyAlerted;

    return CrossUpEvaluation(
      ticker: ticker,
      currentClose: candleT.close,
      previousClose: candleTm1.close,
      currentSma200: sma200T,
      previousSma200: sma200Tm1,
      currentRelation: currentRelation,
      isCrossUp: isCrossUp,
      isRising: isRising,
      shouldAlert: shouldAlert,
      evaluatedAt: now,
    );
  }

  /// Check if the last [days] closes form a strictly rising sequence.
  /// Requires candles.length >= days + 1.
  bool _checkRising(List<DailyCandle> candles, int days) {
    if (days < 1) return true;
    if (candles.length < days + 1) return false;

    for (var i = 0; i < days; i++) {
      final current = candles[candles.length - 1 - i];
      final previous = candles[candles.length - 2 - i];
      if (current.close <= previous.close) return false;
    }
    return true;
  }
}
