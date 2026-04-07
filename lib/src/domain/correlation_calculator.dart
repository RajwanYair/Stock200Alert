/// Correlation Calculator — pure domain logic.
///
/// Computes Pearson correlation coefficient between two price series.
/// Values range from -1 (perfect inverse) to +1 (perfect positive).
library;

import 'dart:math' show sqrt;

import 'entities.dart';

/// Computes correlation between two daily candle series.
class CorrelationCalculator {
  const CorrelationCalculator();

  /// Compute the Pearson correlation coefficient of closing prices.
  ///
  /// Aligns the two series by date (taking the intersection). Returns
  /// null if fewer than 2 common dates exist.
  double? compute({
    required List<DailyCandle> seriesA,
    required List<DailyCandle> seriesB,
  }) {
    final Map<DateTime, double> mapA = {
      for (final DailyCandle c in seriesA)
        DateTime(c.date.year, c.date.month, c.date.day): c.close,
    };
    final Map<DateTime, double> mapB = {
      for (final DailyCandle c in seriesB)
        DateTime(c.date.year, c.date.month, c.date.day): c.close,
    };

    final List<DateTime> common = mapA.keys.where(mapB.containsKey).toList()
      ..sort();

    if (common.length < 2) return null;

    final List<double> xValues = [for (final DateTime d in common) mapA[d]!];
    final List<double> yValues = [for (final DateTime d in common) mapB[d]!];

    return _pearson(xValues, yValues);
  }

  /// Compute Pearson correlation from returns (daily % changes) rather
  /// than absolute prices. More meaningful for financial correlation.
  double? computeReturns({
    required List<DailyCandle> seriesA,
    required List<DailyCandle> seriesB,
  }) {
    final Map<DateTime, double> mapA = {
      for (final DailyCandle c in seriesA)
        DateTime(c.date.year, c.date.month, c.date.day): c.close,
    };
    final Map<DateTime, double> mapB = {
      for (final DailyCandle c in seriesB)
        DateTime(c.date.year, c.date.month, c.date.day): c.close,
    };

    final List<DateTime> common = mapA.keys.where(mapB.containsKey).toList()
      ..sort();

    if (common.length < 3) return null;

    // Compute daily returns
    final List<double> xReturns = [];
    final List<double> yReturns = [];
    for (int i = 1; i < common.length; i++) {
      final double prevA = mapA[common[i - 1]]!;
      final double prevB = mapB[common[i - 1]]!;
      if (prevA == 0 || prevB == 0) continue;
      xReturns.add((mapA[common[i]]! - prevA) / prevA);
      yReturns.add((mapB[common[i]]! - prevB) / prevB);
    }

    if (xReturns.length < 2) return null;
    return _pearson(xReturns, yReturns);
  }

  static double? _pearson(List<double> x, List<double> y) {
    final int n = x.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0, sumY2 = 0;

    for (int i = 0; i < n; i++) {
      sumX += x[i];
      sumY += y[i];
      sumXY += x[i] * y[i];
      sumX2 += x[i] * x[i];
      sumY2 += y[i] * y[i];
    }

    final double numerator = n * sumXY - sumX * sumY;
    final double denominator = sqrt(
      (n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY),
    );

    if (denominator == 0) return null;
    return numerator / denominator;
  }
}
