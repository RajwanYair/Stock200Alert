/// Rate of Change (ROC) — Pure domain logic.
///
/// ROC = ((close − close_n_periods_ago) / close_n_periods_ago) × 100
/// Measures percentage price change over N periods (default 12).
library;

import 'entities.dart';

/// Computes the Rate of Change series for [DailyCandle] data.
class RocCalculator {
  const RocCalculator();

  /// Compute the most recent ROC value.
  ///
  /// Returns null when fewer than [period + 1] candles are available.
  double? compute(List<DailyCandle> candles, {int period = 12}) {
    final series = computeSeries(candles, period: period);
    for (int i = series.length - 1; i >= 0; i--) {
      if (series[i].$2 != null) return series[i].$2;
    }
    return null;
  }

  /// Compute a rolling ROC series aligned with [candles].
  ///
  /// The first [period] entries have null values.
  List<(DateTime, double?)> computeSeries(
    List<DailyCandle> candles, {
    int period = 12,
  }) {
    if (candles.length <= period) {
      return candles.map((DailyCandle c) => (c.date, null as double?)).toList();
    }

    final result = <(DateTime, double?)>[];

    for (int i = 0; i < period; i++) {
      result.add((candles[i].date, null));
    }

    for (int i = period; i < candles.length; i++) {
      final double prev = candles[i - period].close;
      final double roc = prev != 0
          ? ((candles[i].close - prev) / prev) * 100
          : 0;
      result.add((candles[i].date, roc));
    }
    return result;
  }
}
