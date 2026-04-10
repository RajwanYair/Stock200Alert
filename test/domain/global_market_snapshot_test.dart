import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GlobalIndexLevel', () {
    test('creates instance and computes rising/falling', () {
      const rising = GlobalIndexLevel(
        symbol: '^GSPC',
        displayName: 'S&P 500',
        price: 5000.0,
        changePercent: 0.8,
      );
      expect(rising.isRising, isTrue);
      expect(rising.isFalling, isFalse);

      const falling = GlobalIndexLevel(
        symbol: '^DJI',
        displayName: 'Dow Jones',
        price: 38000.0,
        changePercent: -0.5,
      );
      expect(falling.isFalling, isTrue);
      expect(falling.isRising, isFalse);
    });

    test('changePercent null means neither rising nor falling', () {
      const flat = GlobalIndexLevel(
        symbol: '^VIX',
        displayName: 'VIX',
        price: 18.0,
      );
      expect(flat.isRising, isFalse);
      expect(flat.isFalling, isFalse);
    });
  });

  group('GlobalMarketSnapshot', () {
    late DateTime snap;

    setUp(() => snap = DateTime(2025, 6, 1));

    test('creates snapshot and reports counts', () {
      final snapshot = GlobalMarketSnapshot(
        indices: const [
          GlobalIndexLevel(
            symbol: '^GSPC',
            displayName: 'S&P',
            price: 5000,
            changePercent: 0.5,
          ),
          GlobalIndexLevel(
            symbol: '^NDX',
            displayName: 'NASDAQ',
            price: 18000,
            changePercent: -0.3,
          ),
        ],
        snapshotDate: snap,
      );
      expect(snapshot.indexCount, 2);
      expect(snapshot.risingCount, 1);
      expect(snapshot.fallingCount, 1);
      expect(snapshot.isEmpty, isFalse);
    });

    test('isBroadlyUp when risingCount > fallingCount', () {
      final snapshot = GlobalMarketSnapshot(
        indices: const [
          GlobalIndexLevel(
            symbol: 'A',
            displayName: 'A',
            price: 100,
            changePercent: 1.0,
          ),
          GlobalIndexLevel(
            symbol: 'B',
            displayName: 'B',
            price: 200,
            changePercent: 0.5,
          ),
          GlobalIndexLevel(
            symbol: 'C',
            displayName: 'C',
            price: 300,
            changePercent: -0.2,
          ),
        ],
        snapshotDate: snap,
      );
      expect(snapshot.isBroadlyUp, isTrue);
    });

    test('indexFor returns matching index or null', () {
      final snapshot = GlobalMarketSnapshot(
        indices: const [
          GlobalIndexLevel(symbol: '^GSPC', displayName: 'S&P', price: 5000),
        ],
        snapshotDate: snap,
      );
      expect(snapshot.indexFor('^GSPC'), isNotNull);
      expect(snapshot.indexFor('^NDX'), isNull);
    });

    test('isEmpty is true for empty snapshot', () {
      final snapshot = GlobalMarketSnapshot(
        indices: const [],
        snapshotDate: snap,
      );
      expect(snapshot.isEmpty, isTrue);
    });

    test('equality holds', () {
      final a = GlobalMarketSnapshot(indices: const [], snapshotDate: snap);
      final b = GlobalMarketSnapshot(indices: const [], snapshotDate: snap);
      expect(a, equals(b));
    });
  });
}
