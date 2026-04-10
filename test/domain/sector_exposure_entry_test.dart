import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SectorExposureEntry', () {
    test('isDominant is true when weightPct >= 25', () {
      const e = SectorExposureEntry(
        sectorName: 'Technology',
        weightPct: 25.0,
        tickerCount: 10,
      );
      expect(e.isDominant, isTrue);
    });

    test('isDominant is false when weightPct < 25', () {
      const e = SectorExposureEntry(
        sectorName: 'Energy',
        weightPct: 24.9,
        tickerCount: 3,
      );
      expect(e.isDominant, isFalse);
    });

    test('equality holds for same props', () {
      const a = SectorExposureEntry(
        sectorName: 'Healthcare',
        weightPct: 10.0,
        tickerCount: 5,
      );
      const b = SectorExposureEntry(
        sectorName: 'Healthcare',
        weightPct: 10.0,
        tickerCount: 5,
      );
      expect(a, equals(b));
    });
  });

  group('SectorExposureMap', () {
    final entries = [
      const SectorExposureEntry(
        sectorName: 'Technology',
        weightPct: 40.0,
        tickerCount: 8,
      ),
      const SectorExposureEntry(
        sectorName: 'Healthcare',
        weightPct: 20.0,
        tickerCount: 4,
      ),
      const SectorExposureEntry(
        sectorName: 'Financials',
        weightPct: 30.0,
        tickerCount: 6,
      ),
    ];

    final map = SectorExposureMap(
      entries: entries,
      snapshotDate: DateTime(2024, 6, 1),
    );

    test('totalWeight sums all entry weights', () {
      expect(map.totalWeight, closeTo(90.0, 0.001));
    });

    test('topSector returns highest weight entry', () {
      expect(map.topSector?.sectorName, 'Technology');
    });

    test('dominantSectorCount counts entries with weight >= 25', () {
      // Technology (40%) and Financials (30%) are dominant
      expect(map.dominantSectorCount, 2);
    });

    test('topSector is null for empty map', () {
      final empty = SectorExposureMap(
        entries: const [],
        snapshotDate: DateTime(2024, 1, 1),
      );
      expect(empty.topSector, isNull);
    });

    test('equality holds for same props', () {
      final copy = SectorExposureMap(
        entries: entries,
        snapshotDate: DateTime(2024, 6, 1),
      );
      expect(map, equals(copy));
    });
  });
}
