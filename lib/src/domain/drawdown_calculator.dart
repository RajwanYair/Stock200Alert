/// Drawdown Calculator — pure domain logic.
///
/// Computes maximum drawdown (peak-to-trough decline) from a price series.
/// Essential for risk assessment and strategy evaluation.
library;

import 'package:equatable/equatable.dart';

import 'entities.dart';

/// Result of a drawdown calculation.
class DrawdownResult extends Equatable {
  const DrawdownResult({
    required this.maxDrawdownPercent,
    required this.peakDate,
    required this.troughDate,
    required this.peakPrice,
    required this.troughPrice,
    required this.series,
  });

  /// Maximum drawdown as a percentage (negative value).
  final double maxDrawdownPercent;

  /// Date of the peak before the maximum drawdown.
  final DateTime peakDate;

  /// Date of the trough (bottom of the drawdown).
  final DateTime troughDate;

  /// Price at the peak.
  final double peakPrice;

  /// Price at the trough.
  final double troughPrice;

  /// Drawdown series: (date, drawdown%) for every candle.
  final List<(DateTime, double)> series;

  @override
  List<Object?> get props => [
    maxDrawdownPercent,
    peakDate,
    troughDate,
    peakPrice,
    troughPrice,
    series,
  ];
}

/// Computes drawdown metrics from candle data.
class DrawdownCalculator {
  const DrawdownCalculator();

  /// Compute the maximum drawdown and full drawdown series.
  ///
  /// Returns null if [candles] has fewer than 2 entries.
  DrawdownResult? compute(List<DailyCandle> candles) {
    if (candles.length < 2) return null;

    double peak = candles.first.close;
    DateTime peakDate = candles.first.date;

    double maxDrawdown = 0;
    DateTime maxPeakDate = candles.first.date;
    DateTime maxTroughDate = candles.first.date;
    double maxPeakPrice = candles.first.close;
    double maxTroughPrice = candles.first.close;

    final List<(DateTime, double)> series = [];

    for (final DailyCandle c in candles) {
      if (c.close > peak) {
        peak = c.close;
        peakDate = c.date;
      }

      final double drawdown = (c.close - peak) / peak * 100;
      series.add((c.date, drawdown));

      if (drawdown < maxDrawdown) {
        maxDrawdown = drawdown;
        maxPeakDate = peakDate;
        maxTroughDate = c.date;
        maxPeakPrice = peak;
        maxTroughPrice = c.close;
      }
    }

    return DrawdownResult(
      maxDrawdownPercent: maxDrawdown,
      peakDate: maxPeakDate,
      troughDate: maxTroughDate,
      peakPrice: maxPeakPrice,
      troughPrice: maxTroughPrice,
      series: series,
    );
  }
}
