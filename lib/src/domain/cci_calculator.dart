/// CCI (Commodity Channel Index) — Pure domain logic.
///
/// CCI = (Typical Price − SMA(TP, period)) / (0.015 × Mean Deviation)
/// Typical Price = (high + low + close) / 3
/// Default period: 20.
library;

import 'entities.dart';

/// Computes the Commodity Channel Index series for [DailyCandle] data.
class CciCalculator {
  const CciCalculator();

  /// Compute the most recent CCI value.
  ///
  /// Returns null when fewer than [period] candles are available.
  double? compute(List<DailyCandle> candles, {int period = 20}) {
    final series = computeSeries(candles, period: period);
    for (int i = series.length - 1; i >= 0; i--) {
      if (series[i].$2 != null) return series[i].$2;
    }
    return null;
  }

  /// Compute a rolling CCI series aligned with [candles].
  ///
  /// The first [period − 1] entries have null values.
  List<(DateTime, double?)> computeSeries(
    List<DailyCandle> candles, {
    int period = 20,
  }) {
    if (candles.length < period) {
      return candles.map((DailyCandle c) => (c.date, null as double?)).toList();
    }

    final result = <(DateTime, double?)>[];

    for (int i = 0; i < period - 1; i++) {
      result.add((candles[i].date, null));
    }

    for (int i = period - 1; i < candles.length; i++) {
      // Compute SMA of typical prices over the window
      double sumTp = 0;
      final List<double> tps = [];
      for (int j = i - period + 1; j <= i; j++) {
        final double tp =
            (candles[j].high + candles[j].low + candles[j].close) / 3;
        tps.add(tp);
        sumTp += tp;
      }
      final double smaTp = sumTp / period;

      // Mean deviation
      double sumDev = 0;
      for (final double tp in tps) {
        sumDev += (tp - smaTp).abs();
      }
      final double meanDev = sumDev / period;

      final double cci = meanDev != 0
          ? (tps.last - smaTp) / (0.015 * meanDev)
          : 0;
      result.add((candles[i].date, cci));
    }
    return result;
  }
}
