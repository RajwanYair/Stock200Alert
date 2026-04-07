/// Sector Rotation Scorer — ranks sectors by relative momentum.
///
/// Given per-sector average returns over a window, computes a 0–100
/// rotation score indicating which sectors are leading vs. lagging.
library;

import 'package:equatable/equatable.dart';

/// Score for a single sector.
class SectorScore extends Equatable {
  const SectorScore({
    required this.sector,
    required this.averageReturn,
    required this.score,
    required this.rank,
  });

  /// Human-readable sector name (e.g. "Technology", "Energy").
  final String sector;

  /// Average return over the scoring window.
  final double averageReturn;

  /// Normalized 0–100 score: 100 = strongest momentum.
  final double score;

  /// 1-based rank among all scored sectors.
  final int rank;

  @override
  List<Object?> get props => [sector, averageReturn, score, rank];
}

/// Computes sector rotation scores from per-sector average returns.
class SectorRotationScorer {
  const SectorRotationScorer();

  /// Score sectors by relative momentum.
  ///
  /// [sectorReturns] maps sector name → average % return over the window.
  /// Returns an empty list when fewer than 2 sectors are provided.
  List<SectorScore> score(Map<String, double> sectorReturns) {
    if (sectorReturns.length < 2) return [];

    final entries = sectorReturns.entries.toList()
      ..sort(
        (MapEntry<String, double> a, MapEntry<String, double> b) =>
            b.value.compareTo(a.value),
      );

    final maxReturn = entries.first.value;
    final minReturn = entries.last.value;
    final range = maxReturn - minReturn;

    final results = <SectorScore>[];
    for (var i = 0; i < entries.length; i++) {
      final MapEntry<String, double> e = entries[i];
      final normalized = range > 0
          ? ((e.value - minReturn) / range) * 100
          : 50.0;
      results.add(
        SectorScore(
          sector: e.key,
          averageReturn: e.value,
          score: normalized,
          rank: i + 1,
        ),
      );
    }
    return results;
  }
}
