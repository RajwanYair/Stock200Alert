import 'package:equatable/equatable.dart';

/// A sector-level exposure entry within a portfolio.
class SectorExposureEntry extends Equatable {
  const SectorExposureEntry({
    required this.sectorName,
    required this.weightPct,
    required this.tickerCount,
  });

  final String sectorName;

  /// Percentage weight of the sector in the portfolio (0–100).
  final double weightPct;

  /// Number of distinct tickers contributing to this sector.
  final int tickerCount;

  /// Returns true when this sector is a dominant allocation (>= 25 %).
  bool get isDominant => weightPct >= 25.0;

  @override
  List<Object?> get props => [sectorName, weightPct, tickerCount];
}

/// Portfolio-level sector exposure breakdown.
class SectorExposureMap extends Equatable {
  const SectorExposureMap({required this.entries, required this.snapshotDate});

  final List<SectorExposureEntry> entries;
  final DateTime snapshotDate;

  /// Total weight across all sectors (should be ~100).
  double get totalWeight => entries.fold(0.0, (sum, e) => sum + e.weightPct);

  /// Returns the sector entry with the largest weight, or null if empty.
  SectorExposureEntry? get topSector {
    if (entries.isEmpty) return null;
    return entries.reduce((a, b) => a.weightPct >= b.weightPct ? a : b);
  }

  /// Number of sectors with a dominant weight.
  int get dominantSectorCount => entries.where((e) => e.isDominant).length;

  @override
  List<Object?> get props => [entries, snapshotDate];
}
