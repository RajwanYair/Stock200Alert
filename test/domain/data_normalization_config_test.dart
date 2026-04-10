import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NormalisationMethod', () {
    test('has 4 values', () {
      expect(NormalisationMethod.values.length, 4);
    });
  });

  group('DataNormalizationConfig', () {
    test('hasClamping is true when minClamp is set', () {
      const c = DataNormalizationConfig(
        fieldName: 'rsi',
        method: NormalisationMethod.minMax,
        minClamp: 0.0,
      );
      expect(c.hasClamping, isTrue);
    });

    test('hasClamping is true when only maxClamp is set', () {
      const c = DataNormalizationConfig(
        fieldName: 'volume',
        method: NormalisationMethod.zScore,
        maxClamp: 1000000.0,
      );
      expect(c.hasClamping, isTrue);
    });

    test('hasClamping is false when no clamps specified', () {
      const c = DataNormalizationConfig(
        fieldName: 'macd',
        method: NormalisationMethod.zScore,
      );
      expect(c.hasClamping, isFalse);
    });

    test('isRolling is true when windowPeriods > 0', () {
      const c = DataNormalizationConfig(
        fieldName: 'price',
        method: NormalisationMethod.zScore,
        windowPeriods: 20,
      );
      expect(c.isRolling, isTrue);
    });

    test('isRolling is false when windowPeriods is 0', () {
      const c = DataNormalizationConfig(
        fieldName: 'price',
        method: NormalisationMethod.minMax,
      );
      expect(c.isRolling, isFalse);
    });

    test('equality holds for same props', () {
      const a = DataNormalizationConfig(
        fieldName: 'rsi',
        method: NormalisationMethod.minMax,
        minClamp: 0.0,
        maxClamp: 100.0,
        windowPeriods: 14,
      );
      const b = DataNormalizationConfig(
        fieldName: 'rsi',
        method: NormalisationMethod.minMax,
        minClamp: 0.0,
        maxClamp: 100.0,
        windowPeriods: 14,
      );
      expect(a, equals(b));
    });
  });
}
