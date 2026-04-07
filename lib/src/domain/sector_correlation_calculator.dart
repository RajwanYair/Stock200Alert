/// Sector Correlation Calculator — Pearson correlation between sector returns.
///
/// Given daily returns per sector, computes the correlation matrix showing
/// how sectors move relative to each other.
library;

import 'dart:math' as math;

import 'package:equatable/equatable.dart';

/// Correlation between two sectors.
class SectorCorrelation extends Equatable {
  const SectorCorrelation({
    required this.sectorA,
    required this.sectorB,
    required this.correlation,
  });

  final String sectorA;
  final String sectorB;

  /// Pearson correlation coefficient: −1.0 to +1.0.
  final double correlation;

  @override
  List<Object?> get props => [sectorA, sectorB, correlation];
}

/// Computes pairwise Pearson correlation between sector daily returns.
class SectorCorrelationCalculator {
  const SectorCorrelationCalculator();

  /// Compute all pairwise correlations.
  ///
  /// [sectorReturns] maps sector name → ordered list of daily returns.
  /// All return lists must have the same length (≥ 2).
  /// Returns empty list when fewer than 2 sectors or fewer than 2 data points.
  List<SectorCorrelation> computeAll(Map<String, List<double>> sectorReturns) {
    final keys = sectorReturns.keys.toList()..sort();
    if (keys.length < 2) return [];

    final first = sectorReturns[keys.first]!;
    if (first.length < 2) return [];

    final results = <SectorCorrelation>[];
    for (var i = 0; i < keys.length; i++) {
      for (var j = i + 1; j < keys.length; j++) {
        final a = sectorReturns[keys[i]]!;
        final b = sectorReturns[keys[j]]!;
        final n = math.min(a.length, b.length);
        if (n < 2) continue;

        final corr = _pearson(a.sublist(0, n), b.sublist(0, n));
        results.add(
          SectorCorrelation(
            sectorA: keys[i],
            sectorB: keys[j],
            correlation: corr,
          ),
        );
      }
    }
    return results;
  }

  double _pearson(List<double> x, List<double> y) {
    final n = x.length;
    var sumX = 0.0;
    var sumY = 0.0;
    var sumXY = 0.0;
    var sumX2 = 0.0;
    var sumY2 = 0.0;

    for (var i = 0; i < n; i++) {
      sumX += x[i];
      sumY += y[i];
      sumXY += x[i] * y[i];
      sumX2 += x[i] * x[i];
      sumY2 += y[i] * y[i];
    }

    final denom = math.sqrt(
      (n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY),
    );
    if (denom == 0) return 0;
    return (n * sumXY - sumX * sumY) / denom;
  }
}
