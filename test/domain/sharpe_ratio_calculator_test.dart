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
  const calculator = SharpeRatioCalculator();

  group('SharpeRatioCalculator', () {
    test('const constructor', () {
      const SharpeRatioCalculator Function() create = SharpeRatioCalculator.new;
      expect(create(), isNotNull);
    });

    test('returns null for too few candles', () {
      expect(calculator.compute(_candles([100, 110])), isNull);
    });

    test('returns positive for uptrend', () {
      // Steadily increasing prices
      final candles = _candles(List.generate(60, (i) => 100.0 + i * 0.5));
      final sharpe = calculator.compute(candles);
      expect(sharpe, isNotNull);
      expect(sharpe!, greaterThan(0));
    });

    test('returns negative for downtrend', () {
      final candles = _candles(List.generate(60, (i) => 200.0 - i * 0.5));
      final sharpe = calculator.compute(candles);
      expect(sharpe, isNotNull);
      expect(sharpe!, lessThan(0));
    });

    test('risk-free rate lowers Sharpe', () {
      final candles = _candles(List.generate(60, (i) => 100.0 + i * 0.5));
      final sharpe0 = calculator.compute(candles, riskFreeRate: 0.0);
      final sharpe5 = calculator.compute(candles, riskFreeRate: 0.05);
      expect(sharpe0, isNotNull);
      expect(sharpe5, isNotNull);
      expect(sharpe5!, lessThan(sharpe0!));
    });

    test('returns null for zero volatility', () {
      // All same price → zero standard deviation
      final candles = _candles(List.filled(60, 100.0));
      expect(calculator.compute(candles), isNull);
    });
  });
}
