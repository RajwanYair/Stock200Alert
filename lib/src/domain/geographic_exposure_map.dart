import 'package:equatable/equatable.dart';

/// Geographic region for market exposure classification.
enum MarketRegion {
  northAmerica,
  europe,
  asiaPacific,
  emergingMarkets,
  latam,
  middleEastAfrica,
  global,
}

/// A single regional exposure entry for a portfolio or holding.
class RegionalExposureEntry extends Equatable {
  const RegionalExposureEntry({required this.region, required this.exposurePct})
    : assert(
        exposurePct >= 0 && exposurePct <= 100,
        'exposurePct must be 0–100',
      );

  final MarketRegion region;

  /// Share of portfolio exposed to this region (0–100).
  final double exposurePct;

  bool get isDominant => exposurePct >= 50.0;

  @override
  List<Object?> get props => [region, exposurePct];
}

/// Geographic exposure breakdown for a portfolio or strategy.
class GeographicExposureMap extends Equatable {
  const GeographicExposureMap({
    required this.entries,
    required this.calculatedAt,
  });

  final List<RegionalExposureEntry> entries;
  final DateTime calculatedAt;

  int get regionCount => entries.length;

  double get totalExposurePct => entries.fold(
    0.0,
    (final double s, final RegionalExposureEntry e) => s + e.exposurePct,
  );

  bool get isFullyMapped => (totalExposurePct - 100.0).abs() < 0.001;

  RegionalExposureEntry? exposureFor(MarketRegion region) =>
      entries
          .where((final RegionalExposureEntry e) => e.region == region)
          .isEmpty
      ? null
      : entries.firstWhere(
          (final RegionalExposureEntry e) => e.region == region,
        );

  RegionalExposureEntry? get dominantRegion {
    if (entries.isEmpty) return null;
    return entries.reduce(
      (final RegionalExposureEntry a, final RegionalExposureEntry b) =>
          a.exposurePct >= b.exposurePct ? a : b,
    );
  }

  @override
  List<Object?> get props => [entries, calculatedAt];
}
