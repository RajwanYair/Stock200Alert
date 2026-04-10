import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TrailingStopConfig', () {
    group('percentage unit', () {
      const config = TrailingStopConfig(
        ticker: 'TSLA',
        unit: TrailingStopUnit.percentage,
        trailDistance: 10.0,
        entryPrice: 200.0,
        highWatermark: 250.0,
      );

      test('stopPrice is highWatermark * (1 - trailDistance/100)', () {
        expect(config.stopPrice, closeTo(225.0, 0.001));
      });

      test('isTriggered is true when currentPrice <= stopPrice', () {
        expect(config.isTriggered(225.0), isTrue);
      });

      test('isTriggered is false when currentPrice > stopPrice', () {
        expect(config.isTriggered(230.0), isFalse);
      });
    });

    group('absoluteValue unit', () {
      const config = TrailingStopConfig(
        ticker: 'TSLA',
        unit: TrailingStopUnit.absoluteValue,
        trailDistance: 20.0,
        entryPrice: 200.0,
        highWatermark: 250.0,
      );

      test('stopPrice is highWatermark - trailDistance', () {
        expect(config.stopPrice, closeTo(230.0, 0.001));
      });
    });

    test('isTriggered is false when isActive is false', () {
      const inactive = TrailingStopConfig(
        ticker: 'AAPL',
        unit: TrailingStopUnit.percentage,
        trailDistance: 5.0,
        entryPrice: 100.0,
        highWatermark: 100.0,
        isActive: false,
      );
      expect(inactive.isTriggered(80.0), isFalse);
    });

    test('isActive defaults to true', () {
      const config = TrailingStopConfig(
        ticker: 'AAPL',
        unit: TrailingStopUnit.percentage,
        trailDistance: 5.0,
        entryPrice: 100.0,
        highWatermark: 100.0,
      );
      expect(config.isActive, isTrue);
    });

    test('equality holds for same props', () {
      const a = TrailingStopConfig(
        ticker: 'TSLA',
        unit: TrailingStopUnit.percentage,
        trailDistance: 10.0,
        entryPrice: 200.0,
        highWatermark: 250.0,
      );
      const b = TrailingStopConfig(
        ticker: 'TSLA',
        unit: TrailingStopUnit.percentage,
        trailDistance: 10.0,
        entryPrice: 200.0,
        highWatermark: 250.0,
      );
      expect(a, equals(b));
    });
  });
}
