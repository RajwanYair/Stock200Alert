/// EMA Calculator — Pure domain logic.
///
/// Computes the Exponential Moving Average (EMA) series over N trading-day
/// closes. Standard formula: EMA(t) = close(t) * k + EMA(t-1) * (1 - k),
/// where k = 2 / (period + 1). Seeds with SMA for the first value.
library;

import 'entities.dart';

class EmaCalculator {
  const EmaCalculator();

  /// Compute the current EMA for the given [period].
  ///
  /// Requires at least [period] candles. Returns null if insufficient data.
  double? compute(List<DailyCandle> candles, {int period = 200}) {
    final series = computeSeries(candles, period: period);
    for (int i = series.length - 1; i >= 0; i--) {
      if (series[i].$2 != null) return series[i].$2;
    }
    return null;
  }

  /// Compute a rolling EMA series aligned with [candles].
  ///
  /// The first [period - 1] entries have a null value. The seed (index
  /// [period - 1]) is the SMA of the first [period] closes. Subsequent
  /// entries apply the EMA formula.
  List<(DateTime, double?)> computeSeries(
    List<DailyCandle> candles, {
    int period = 200,
  }) {
    if (candles.length < period) {
      return candles.map((c) => (c.date, null as double?)).toList();
    }

    final k = 2.0 / (period + 1);
    final result = <(DateTime, double?)>[];

    // Seed: SMA of first [period] closes
    final seedSlice = candles.sublist(0, period);
    final seed =
        seedSlice.fold<double>(0.0, (acc, c) => acc + c.close) / period;

    // Fill nulls for the warmup period
    for (int i = 0; i < period - 1; i++) {
      result.add((candles[i].date, null));
    }

    // First EMA = seed
    result.add((candles[period - 1].date, seed));

    double prev = seed;
    for (int i = period; i < candles.length; i++) {
      final ema = candles[i].close * k + prev * (1.0 - k);
      result.add((candles[i].date, ema));
      prev = ema;
    }

    return result;
  }
}
