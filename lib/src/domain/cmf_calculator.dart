/// Chaikin Money Flow (CMF) — Pure domain logic.
///
/// CMF = sum(MFV, period) / sum(volume, period)
/// where MFV = ((close − low) − (high − close)) / (high − low) × volume
/// Default period: 20.
library;

import 'entities.dart';

/// Computes the Chaikin Money Flow series for [DailyCandle] data.
class CmfCalculator {
  const CmfCalculator();

  /// Compute the most recent CMF value.
  ///
  /// Returns null when fewer than [period] candles are available.
  double? compute(List<DailyCandle> candles, {int period = 20}) {
    final series = computeSeries(candles, period: period);
    for (int i = series.length - 1; i >= 0; i--) {
      if (series[i].$2 != null) return series[i].$2;
    }
    return null;
  }

  /// Compute a rolling CMF series aligned with [candles].
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
      double sumMfv = 0;
      double sumVol = 0;
      for (int j = i - period + 1; j <= i; j++) {
        final DailyCandle c = candles[j];
        final double range = c.high - c.low;
        final double mfm = range > 0
            ? ((c.close - c.low) - (c.high - c.close)) / range
            : 0;
        sumMfv += mfm * c.volume;
        sumVol += c.volume;
      }
      final double cmf = sumVol > 0 ? sumMfv / sumVol : 0;
      result.add((candles[i].date, cmf));
    }
    return result;
  }
}
