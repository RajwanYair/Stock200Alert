import 'package:cross_tide/src/domain/sector_correlation_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calc = SectorCorrelationCalculator();

  group('SectorCorrelationCalculator', () {
    test('returns empty for fewer than 2 sectors', () {
      expect(
        calc.computeAll({
          'Tech': [1.0, 2.0],
        }),
        isEmpty,
      );
    });

    test('returns empty when data has fewer than 2 points', () {
      expect(
        calc.computeAll({
          'A': [1.0],
          'B': [2.0],
        }),
        isEmpty,
      );
    });

    test('computes positive correlation for identical series', () {
      final result = calc.computeAll({
        'A': [1.0, 2.0, 3.0, 4.0, 5.0],
        'B': [1.0, 2.0, 3.0, 4.0, 5.0],
      });

      expect(result, hasLength(1));
      expect(result.first.sectorA, 'A');
      expect(result.first.sectorB, 'B');
      expect(result.first.correlation, closeTo(1.0, 0.001));
    });

    test('computes negative correlation for inverse series', () {
      final result = calc.computeAll({
        'A': [1.0, 2.0, 3.0, 4.0, 5.0],
        'B': [5.0, 4.0, 3.0, 2.0, 1.0],
      });

      expect(result.first.correlation, closeTo(-1.0, 0.001));
    });

    test('computes all pairwise correlations for 3 sectors', () {
      final result = calc.computeAll({
        'A': [1.0, 2.0, 3.0],
        'B': [3.0, 2.0, 1.0],
        'C': [1.0, 3.0, 2.0],
      });

      // 3 pairs: A-B, A-C, B-C
      expect(result, hasLength(3));
    });

    test('SectorCorrelation props equality', () {
      const a = SectorCorrelation(sectorA: 'X', sectorB: 'Y', correlation: 0.5);
      const b = SectorCorrelation(sectorA: 'X', sectorB: 'Y', correlation: 0.5);
      expect(a, equals(b));
    });
  });
}
