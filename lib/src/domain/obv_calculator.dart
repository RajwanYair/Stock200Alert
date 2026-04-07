/// OBV (On-Balance Volume) — Pure domain logic.
///
/// Cumulative indicator: if close > prev close, add volume; if close < prev
/// close, subtract volume; if equal, OBV is unchanged.
library;

import 'entities.dart';

/// Computes the On-Balance Volume series for [DailyCandle] data.
class ObvCalculator {
  const ObvCalculator();

  /// Compute the most recent OBV value.
  ///
  /// Returns null when fewer than 2 candles are available.
  int? compute(List<DailyCandle> candles) {
    final series = computeSeries(candles);
    return series.isEmpty ? null : series.last.$2;
  }

  /// Compute a full OBV series aligned with [candles].
  ///
  /// Returns an empty list when fewer than 2 candles are provided.
  List<(DateTime, int)> computeSeries(List<DailyCandle> candles) {
    if (candles.length < 2) return [];

    final List<(DateTime, int)> results = [(candles[0].date, 0)];
    int obv = 0;

    for (int i = 1; i < candles.length; i++) {
      if (candles[i].close > candles[i - 1].close) {
        obv += candles[i].volume;
      } else if (candles[i].close < candles[i - 1].close) {
        obv -= candles[i].volume;
      }
      results.add((candles[i].date, obv));
    }
    return results;
  }
}
