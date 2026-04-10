import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RegionalExposureEntry', () {
    test('creates entry and reports isDominant', () {
      const major = RegionalExposureEntry(
        region: MarketRegion.northAmerica,
        exposurePct: 70.0,
      );
      expect(major.isDominant, isTrue);

      const minor = RegionalExposureEntry(
        region: MarketRegion.europe,
        exposurePct: 20.0,
      );
      expect(minor.isDominant, isFalse);
    });
  });

  group('GeographicExposureMap', () {
    late DateTime calcAt;

    setUp(() => calcAt = DateTime(2025, 6, 1));

    test('creates map and reports totals', () {
      final map = GeographicExposureMap(
        entries: const [
          RegionalExposureEntry(
            region: MarketRegion.northAmerica,
            exposurePct: 60.0,
          ),
          RegionalExposureEntry(region: MarketRegion.europe, exposurePct: 40.0),
        ],
        calculatedAt: calcAt,
      );
      expect(map.regionCount, 2);
      expect(map.totalExposurePct, closeTo(100.0, 0.001));
      expect(map.isFullyMapped, isTrue);
    });

    test('isFullyMapped false when weights do not total 100', () {
      final map = GeographicExposureMap(
        entries: const [
          RegionalExposureEntry(region: MarketRegion.global, exposurePct: 60.0),
        ],
        calculatedAt: calcAt,
      );
      expect(map.isFullyMapped, isFalse);
    });

    test('exposureFor returns matching entry or null', () {
      final map = GeographicExposureMap(
        entries: const [
          RegionalExposureEntry(
            region: MarketRegion.asiaPacific,
            exposurePct: 30.0,
          ),
        ],
        calculatedAt: calcAt,
      );
      expect(map.exposureFor(MarketRegion.asiaPacific)!.exposurePct, 30.0);
      expect(map.exposureFor(MarketRegion.latam), isNull);
    });

    test('dominantRegion returns highest exposure region', () {
      final map = GeographicExposureMap(
        entries: const [
          RegionalExposureEntry(
            region: MarketRegion.northAmerica,
            exposurePct: 70.0,
          ),
          RegionalExposureEntry(region: MarketRegion.europe, exposurePct: 30.0),
        ],
        calculatedAt: calcAt,
      );
      expect(map.dominantRegion!.region, MarketRegion.northAmerica);
    });

    test('dominantRegion is null for empty map', () {
      final map = GeographicExposureMap(
        entries: const [],
        calculatedAt: calcAt,
      );
      expect(map.dominantRegion, isNull);
    });

    test('equality holds for identical maps', () {
      final a = GeographicExposureMap(entries: const [], calculatedAt: calcAt);
      final b = GeographicExposureMap(entries: const [], calculatedAt: calcAt);
      expect(a, equals(b));
    });
  });
}
