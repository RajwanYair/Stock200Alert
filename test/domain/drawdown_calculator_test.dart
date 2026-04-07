import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

List<DailyCandle> _candles(List<double> prices) => [
  for (int i = 0; i < prices.length; i++)
    DailyCandle(
      date: DateTime(2024, 1, 1).add(Duration(days: i)),
      open: prices[i],
      high: prices[i] + 2,
      low: prices[i] - 2,
      close: prices[i],
      volume: 1000,
    ),
];

void main() {
  const calculator = DrawdownCalculator();

  group('DrawdownCalculator', () {
    test('const constructor', () {
      const DrawdownCalculator Function() create = DrawdownCalculator.new;
      expect(create(), isNotNull);
    });

    test('returns null for too few candles', () {
      expect(calculator.compute(_candles([100])), isNull);
    });

    test('zero drawdown for monotonically increasing prices', () {
      final result = calculator.compute(_candles([100, 110, 120, 130, 140]));
      expect(result, isNotNull);
      expect(result!.maxDrawdownPercent, 0.0);
    });

    test('computes drawdown for declining prices', () {
      final result = calculator.compute(_candles([100, 90, 80, 70, 60]));
      expect(result, isNotNull);
      // Max drawdown: (60-100)/100 = -40%
      expect(result!.maxDrawdownPercent, closeTo(-40.0, 0.01));
      expect(result.peakPrice, 100);
      expect(result.troughPrice, 60);
    });

    test('identifies correct peak and trough dates', () {
      final result = calculator.compute(_candles([100, 120, 80, 90, 110]));
      expect(result, isNotNull);
      // Peak at day 1 (120), trough at day 2 (80) => -33.3%
      expect(result!.peakDate, DateTime(2024, 1, 2));
      expect(result.troughDate, DateTime(2024, 1, 3));
      expect(result.maxDrawdownPercent, closeTo(-33.33, 0.01));
    });

    test('series has correct length', () {
      final candles = _candles([100, 110, 105, 115, 90]);
      final result = calculator.compute(candles);
      expect(result!.series.length, candles.length);
    });

    test('series first entry is 0% drawdown', () {
      final result = calculator.compute(_candles([100, 90, 110]));
      expect(result!.series.first.$2, 0.0);
    });
  });
}
