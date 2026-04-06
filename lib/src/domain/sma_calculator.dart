/// SMA Calculator — Pure domain logic.
///
/// Computes the Simple Moving Average over N trading-day closes.
/// Uses only the provider's actual trading-day series; never invents
/// weekend or holiday candles.
library;

import 'entities.dart';

class SmaCalculator {
  const SmaCalculator();

  /// Compute SMA for the given [period] using the last [period] closes
  /// from [candles]. Candles must be sorted ascending by date.
  ///
  /// Returns null if fewer than [period] candles are available.
  ///
  /// Definition: SMA(t, N) = (close[t] + close[t-1] + ... + close[t-N+1]) / N
  /// where t is the index of the latest candle (inclusive).
  double? compute(List<DailyCandle> candles, {int period = 200}) {
    if (candles.length < period) return null;
    final slice = candles.sublist(candles.length - period);
    final sum = slice.fold<double>(0.0, (acc, c) => acc + c.close);
    return sum / period;
  }

  /// Compute a rolling SMA series for each position where enough data exists.
  /// Returns a list of (date, smaValue) pairs aligned with the input candles.
  /// The first [period - 1] entries will be null.
  List<(DateTime, double?)> computeSeries(
    List<DailyCandle> candles, {
    int period = 200,
  }) {
    final result = <(DateTime, double?)>[];
    for (var i = 0; i < candles.length; i++) {
      if (i < period - 1) {
        result.add((candles[i].date, null));
      } else {
        final slice = candles.sublist(i - period + 1, i + 1);
        final sum = slice.fold<double>(0.0, (acc, c) => acc + c.close);
        result.add((candles[i].date, sum / period));
      }
    }
    return result;
  }
}
