import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

List<DailyCandle> _candles(List<double> prices) => [
  for (int i = 0; i < prices.length; i++)
    DailyCandle(
      date: DateTime(2024, 1, 1).add(Duration(days: i)),
      open: prices[i],
      high: prices[i] + 1,
      low: prices[i] - 1,
      close: prices[i],
      volume: 1000,
    ),
];

void main() {
  const calculator = CorrelationCalculator();

  group('CorrelationCalculator', () {
    test('const constructor', () {
      const CorrelationCalculator Function() create = CorrelationCalculator.new;
      expect(create(), isNotNull);
    });

    test('returns null for too few common dates', () {
      final seriesA = _candles([100]);
      final seriesB = _candles([200]);
      expect(calculator.compute(seriesA: seriesA, seriesB: seriesB), isNull);
    });

    test('perfect positive correlation', () {
      final seriesA = _candles([100, 110, 120, 130, 140]);
      final seriesB = _candles([200, 220, 240, 260, 280]);
      final r = calculator.compute(seriesA: seriesA, seriesB: seriesB);
      expect(r, isNotNull);
      expect(r!, closeTo(1.0, 0.001));
    });

    test('perfect negative correlation', () {
      final seriesA = _candles([100, 110, 120, 130, 140]);
      final seriesB = _candles([280, 260, 240, 220, 200]);
      final r = calculator.compute(seriesA: seriesA, seriesB: seriesB);
      expect(r, isNotNull);
      expect(r!, closeTo(-1.0, 0.001));
    });

    test('computeReturns requires at least 3 common dates', () {
      final seriesA = _candles([100, 110]);
      final seriesB = _candles([200, 220]);
      expect(
        calculator.computeReturns(seriesA: seriesA, seriesB: seriesB),
        isNull,
      );
    });

    test(
      'computeReturns produces positive correlation for comoving series',
      () {
        final seriesA = _candles([100, 110, 120, 130, 140]);
        final seriesB = _candles([200, 220, 240, 260, 280]);
        final r = calculator.computeReturns(seriesA: seriesA, seriesB: seriesB);
        expect(r, isNotNull);
        expect(r!, closeTo(1.0, 0.001));
      },
    );
  });
}
