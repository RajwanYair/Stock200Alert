/// Fibonacci Calculator — pure domain logic.
///
/// Computes standard Fibonacci retracement levels between a swing high
/// and swing low. Returns [TechnicalLevel] objects usable in charts
/// and alert systems.
library;

import 'entities.dart';
import 'technical_level.dart';

/// Standard Fibonacci retracement ratios.
const List<double> fibonacciRatios = [
  0.0,
  0.236,
  0.382,
  0.5,
  0.618,
  0.786,
  1.0,
];

/// Fibonacci retracement level labels.
const List<String> fibonacciLabels = [
  '0%',
  '23.6%',
  '38.2%',
  '50%',
  '61.8%',
  '78.6%',
  '100%',
];

/// Computes Fibonacci retracement levels for a given ticker.
class FibonacciCalculator {
  const FibonacciCalculator();

  /// Compute retracement levels between [swingHigh] and [swingLow].
  ///
  /// Returns a list of [TechnicalLevel] in descending price order
  /// (from swing high down to swing low). Levels above the midpoint
  /// are classified as resistance, below as support.
  List<TechnicalLevel> compute({
    required String ticker,
    required double swingHigh,
    required double swingLow,
    DateTime? computedAt,
  }) {
    if (swingHigh <= swingLow) return const [];

    final double range = swingHigh - swingLow;
    final double midPoint = (swingHigh + swingLow) / 2;
    final List<TechnicalLevel> levels = [];

    for (int i = 0; i < fibonacciRatios.length; i++) {
      final double price = swingHigh - range * fibonacciRatios[i];
      levels.add(
        TechnicalLevel(
          ticker: ticker,
          price: price,
          levelType: price >= midPoint
              ? LevelType.resistance
              : LevelType.support,
          source: LevelSource.fibonacci,
          label: fibonacciLabels[i],
          computedAt: computedAt,
        ),
      );
    }

    return levels;
  }

  /// Auto-detect swing high/low from candle data and compute levels.
  ///
  /// Uses the highest high and lowest low from the last [lookback] candles.
  /// Returns empty if [candles] has fewer than [lookback] entries.
  List<TechnicalLevel> computeFromCandles({
    required String ticker,
    required List<DailyCandle> candles,
    int lookback = 50,
    DateTime? computedAt,
  }) {
    if (candles.length < lookback) return const [];

    final List<DailyCandle> window = candles.sublist(candles.length - lookback);

    double high = window.first.high;
    double low = window.first.low;
    for (final DailyCandle c in window) {
      if (c.high > high) high = c.high;
      if (c.low < low) low = c.low;
    }

    return compute(
      ticker: ticker,
      swingHigh: high,
      swingLow: low,
      computedAt: computedAt,
    );
  }
}
