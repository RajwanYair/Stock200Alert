/// Parabolic SAR — Pure domain logic.
///
/// Uses the standard Welles Wilder Parabolic SAR algorithm:
/// - AF starts at [afStart] (default 0.02), increments by [afStep] each
///   new extreme, capped at [afMax] (default 0.20).
/// - SAR(t) = SAR(t−1) + AF × (EP − SAR(t−1))
library;

import 'package:equatable/equatable.dart';

import 'entities.dart';

/// A single Parabolic SAR data point.
class ParabolicSarResult extends Equatable {
  const ParabolicSarResult({
    required this.date,
    required this.sar,
    required this.isUpTrend,
  });

  final DateTime date;

  /// The SAR value for this bar.
  final double sar;

  /// Whether the trend is currently up (SAR below price).
  final bool isUpTrend;

  @override
  List<Object?> get props => [date, sar, isUpTrend];
}

/// Computes Parabolic SAR for [DailyCandle] data.
class ParabolicSarCalculator {
  const ParabolicSarCalculator({
    this.afStart = 0.02,
    this.afStep = 0.02,
    this.afMax = 0.20,
  });

  final double afStart;
  final double afStep;
  final double afMax;

  /// Compute the most recent Parabolic SAR value.
  ParabolicSarResult? compute(List<DailyCandle> candles) {
    final series = computeSeries(candles);
    return series.isEmpty ? null : series.last;
  }

  /// Compute a full Parabolic SAR series.
  ///
  /// Requires at least 2 candles; returns empty otherwise.
  List<ParabolicSarResult> computeSeries(List<DailyCandle> candles) {
    if (candles.length < 2) return [];

    final List<ParabolicSarResult> results = [];

    // Initialize: determine initial trend from first two bars.
    bool isUpTrend = candles[1].close >= candles[0].close;
    double af = afStart;
    double ep = isUpTrend ? candles[0].high : candles[0].low;
    double sar = isUpTrend ? candles[0].low : candles[0].high;

    results.add(
      ParabolicSarResult(date: candles[0].date, sar: sar, isUpTrend: isUpTrend),
    );

    for (int i = 1; i < candles.length; i++) {
      final DailyCandle prev = candles[i - 1];
      final DailyCandle curr = candles[i];

      // Update SAR
      sar = sar + af * (ep - sar);

      // Constrain SAR to prior bar's range
      if (isUpTrend) {
        if (sar > prev.low) sar = prev.low;
        if (i >= 2 && sar > candles[i - 2].low) sar = candles[i - 2].low;
      } else {
        if (sar < prev.high) sar = prev.high;
        if (i >= 2 && sar < candles[i - 2].high) sar = candles[i - 2].high;
      }

      // Check for reversal
      bool reversed = false;
      if (isUpTrend && curr.low < sar) {
        isUpTrend = false;
        reversed = true;
        sar = ep;
        ep = curr.low;
        af = afStart;
      } else if (!isUpTrend && curr.high > sar) {
        isUpTrend = true;
        reversed = true;
        sar = ep;
        ep = curr.high;
        af = afStart;
      }

      if (!reversed) {
        if (isUpTrend) {
          if (curr.high > ep) {
            ep = curr.high;
            af = (af + afStep).clamp(afStart, afMax);
          }
        } else {
          if (curr.low < ep) {
            ep = curr.low;
            af = (af + afStep).clamp(afStart, afMax);
          }
        }
      }

      results.add(
        ParabolicSarResult(date: curr.date, sar: sar, isUpTrend: isUpTrend),
      );
    }
    return results;
  }
}
