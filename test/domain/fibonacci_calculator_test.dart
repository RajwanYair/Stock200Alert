import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calculator = FibonacciCalculator();

  group('FibonacciCalculator', () {
    test('const constructor', () {
      const FibonacciCalculator Function() create = FibonacciCalculator.new;
      expect(create(), isNotNull);
    });

    test('returns empty when swingHigh <= swingLow', () {
      final levels = calculator.compute(
        ticker: 'AAPL',
        swingHigh: 100,
        swingLow: 100,
      );
      expect(levels, isEmpty);
    });

    test('returns 7 levels for valid range', () {
      final levels = calculator.compute(
        ticker: 'AAPL',
        swingHigh: 200,
        swingLow: 100,
      );
      expect(levels.length, 7);
    });

    test('levels span from high to low', () {
      final levels = calculator.compute(
        ticker: 'AAPL',
        swingHigh: 200,
        swingLow: 100,
      );
      expect(levels.first.price, closeTo(200.0, 0.01));
      expect(levels.last.price, closeTo(100.0, 0.01));
    });

    test('38.2% retracement is correct', () {
      final levels = calculator.compute(
        ticker: 'AAPL',
        swingHigh: 200,
        swingLow: 100,
      );
      // 38.2% retracement from 200: 200 - 100*0.382 = 161.8
      final fib382 = levels[2];
      expect(fib382.label, '38.2%');
      expect(fib382.price, closeTo(161.8, 0.01));
    });

    test('50% retracement is the midpoint', () {
      final levels = calculator.compute(
        ticker: 'AAPL',
        swingHigh: 200,
        swingLow: 100,
      );
      final fib50 = levels[3];
      expect(fib50.label, '50%');
      expect(fib50.price, closeTo(150.0, 0.01));
    });

    test('levels above midpoint are resistance', () {
      final levels = calculator.compute(
        ticker: 'AAPL',
        swingHigh: 200,
        swingLow: 100,
      );
      // midPoint = 150. 0% (200), 23.6% (176.4), 38.2% (161.8), 50% (150)
      expect(levels[0].levelType, LevelType.resistance);
      expect(levels[1].levelType, LevelType.resistance);
      expect(levels[2].levelType, LevelType.resistance);
      expect(levels[3].levelType, LevelType.resistance);
    });

    test('levels below midpoint are support', () {
      final levels = calculator.compute(
        ticker: 'AAPL',
        swingHigh: 200,
        swingLow: 100,
      );
      // 61.8% (138.2), 78.6% (121.4), 100% (100)
      expect(levels[4].levelType, LevelType.support);
      expect(levels[5].levelType, LevelType.support);
      expect(levels[6].levelType, LevelType.support);
    });

    test('computeFromCandles returns empty for too few candles', () {
      final candles = List.generate(
        10,
        (i) => DailyCandle(
          date: DateTime(2024, 1, 1).add(Duration(days: i)),
          open: 100,
          high: 110,
          low: 90,
          close: 105,
          volume: 1000,
        ),
      );
      final levels = calculator.computeFromCandles(
        ticker: 'AAPL',
        candles: candles,
      );
      expect(levels, isEmpty);
    });

    test('computeFromCandles finds swing points', () {
      final candles = List.generate(
        60,
        (i) => DailyCandle(
          date: DateTime(2024, 1, 1).add(Duration(days: i)),
          open: 100 + (i % 10).toDouble(),
          high: 120,
          low: 80,
          close: 100 + (i % 5).toDouble(),
          volume: 1000,
        ),
      );
      final levels = calculator.computeFromCandles(
        ticker: 'AAPL',
        candles: candles,
      );
      expect(levels.length, 7);
      expect(levels.first.price, closeTo(120, 0.01));
      expect(levels.last.price, closeTo(80, 0.01));
    });

    test('source is fibonacci for all levels', () {
      final levels = calculator.compute(
        ticker: 'AAPL',
        swingHigh: 200,
        swingLow: 100,
      );
      for (final TechnicalLevel level in levels) {
        expect(level.source, LevelSource.fibonacci);
      }
    });

    test('computedAt is passed through', () {
      final now = DateTime(2024, 6, 15);
      final levels = calculator.compute(
        ticker: 'AAPL',
        swingHigh: 200,
        swingLow: 100,
        computedAt: now,
      );
      for (final TechnicalLevel level in levels) {
        expect(level.computedAt, now);
      }
    });
  });
}
