/// VWAP Calculator — Volume-Weighted Average Price (rolling daily window).
///
/// Classic daily VWAP resets each trading day. This implementation computes a
/// rolling VWAP using available candles, which approximates daily VWAP using
/// end-of-day OHLC data: typical price = (H + L + C) / 3.
library;

import 'package:equatable/equatable.dart';

import 'entities.dart';

/// A single point in the VWAP series.
class VwapResult extends Equatable {
  const VwapResult({required this.date, required this.vwap});

  final DateTime date;

  /// Volume-weighted average price for this candle's contribution window.
  final double vwap;

  @override
  List<Object?> get props => [date, vwap];
}

/// Computes a cumulative VWAP series from a list of [DailyCandle] values.
///
/// Formula per bar: `typicalPrice = (high + low + close) / 3`
/// Cumulative: `vwap[i] = Σ(typicalPrice × volume) / Σ(volume)`
///
/// This is a running (not reset-per-session) VWAP over the supplied window,
/// which is appropriate for multi-day technical analysis.
class VwapCalculator {
  const VwapCalculator();

  /// Compute the most recent VWAP value across all [candles].
  ///
  /// Returns null if [candles] is empty.
  VwapResult? compute(List<DailyCandle> candles) {
    final series = computeSeries(candles);
    return series.isEmpty ? null : series.last;
  }

  /// Compute the full cumulative VWAP series aligned to [candles].
  ///
  /// Returns an empty list when [candles] is empty.
  List<VwapResult> computeSeries(List<DailyCandle> candles) {
    if (candles.isEmpty) return [];

    final List<VwapResult> results = [];
    double cumTpv = 0; // cumulative (typicalPrice * volume)
    double cumVol = 0; // cumulative volume

    for (final DailyCandle c in candles) {
      final double tp = (c.high + c.low + c.close) / 3.0;
      cumTpv += tp * c.volume;
      cumVol += c.volume;
      final double vwap = cumVol > 0 ? cumTpv / cumVol : tp;
      results.add(VwapResult(date: c.date, vwap: vwap));
    }
    return results;
  }
}
