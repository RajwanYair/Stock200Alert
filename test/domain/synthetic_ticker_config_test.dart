import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SyntheticTickerConfig', () {
    test('componentCount returns number of entries', () {
      const s = SyntheticTickerConfig(
        syntheticId: 'tech_blend',
        displayName: 'Tech Blend',
        components: {'AAPL': 0.5, 'MSFT': 0.3, 'GOOGL': 0.2},
      );
      expect(s.componentCount, 3);
    });

    test('isNormalised is true when weights sum to 1.0', () {
      const s = SyntheticTickerConfig(
        syntheticId: 's1',
        displayName: 'Balanced',
        components: {'AAPL': 0.5, 'MSFT': 0.5},
      );
      expect(s.isNormalised, isTrue);
    });

    test('isNormalised is true within tolerance', () {
      // 0.333 + 0.333 + 0.334 = 1.000 — within 0.01
      const s = SyntheticTickerConfig(
        syntheticId: 's2',
        displayName: 'Thirds',
        components: {'A': 0.333, 'B': 0.333, 'C': 0.334},
      );
      expect(s.isNormalised, isTrue);
    });

    test('isNormalised is false when weights are far from 1.0', () {
      const s = SyntheticTickerConfig(
        syntheticId: 's3',
        displayName: 'UnBalanced',
        components: {'A': 0.5, 'B': 0.3},
      );
      expect(s.isNormalised, isFalse);
    });

    test('description defaults to null', () {
      const s = SyntheticTickerConfig(
        syntheticId: 's4',
        displayName: 'Test',
        components: {'A': 1.0},
      );
      expect(s.description, isNull);
    });

    test('equality holds for same props', () {
      const a = SyntheticTickerConfig(
        syntheticId: 'x',
        displayName: 'X',
        components: {'AAPL': 1.0},
        description: 'test',
      );
      const b = SyntheticTickerConfig(
        syntheticId: 'x',
        displayName: 'X',
        components: {'AAPL': 1.0},
        description: 'test',
      );
      expect(a, equals(b));
    });
  });
}
