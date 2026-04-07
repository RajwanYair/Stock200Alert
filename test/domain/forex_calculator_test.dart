import 'package:cross_tide/src/domain/entities.dart';
import 'package:cross_tide/src/domain/forex_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calc = ForexCalculator();

  group('ForexCalculator.pipSize', () {
    test('JPY pair has pip size 0.01', () {
      const pair = ForexPair(base: 'USD', quote: 'JPY');
      expect(calc.pipSize(pair), 0.01);
    });

    test('non-JPY pair has pip size 0.0001', () {
      const pair = ForexPair(base: 'EUR', quote: 'USD');
      expect(calc.pipSize(pair), 0.0001);
    });
  });

  group('ForexCalculator.averageDailyRangePips', () {
    test('computes from candle highs and lows', () {
      const pair = ForexPair(base: 'EUR', quote: 'USD');
      final candles = [
        DailyCandle(
          date: DateTime(2025, 1, 1),
          open: 1.1000,
          high: 1.1100,
          low: 1.1000,
          close: 1.1050,
          volume: 1000,
        ),
        DailyCandle(
          date: DateTime(2025, 1, 2),
          open: 1.1050,
          high: 1.1150,
          low: 1.1050,
          close: 1.1100,
          volume: 1200,
        ),
      ];

      // Each day: range = 0.0100, in pips = 100
      final pips = calc.averageDailyRangePips(pair, candles);
      expect(pips, closeTo(100, 1));
    });

    test('empty candles returns 0', () {
      const pair = ForexPair(base: 'EUR', quote: 'USD');
      expect(calc.averageDailyRangePips(pair, []), 0);
    });
  });

  group('ForexCalculator.spreadPips', () {
    test('computes spread in pips', () {
      const pair = ForexPair(base: 'GBP', quote: 'USD');
      final spread = calc.spreadPips(pair, 1.2650, 1.2653);
      expect(spread, closeTo(3, 0.1));
    });
  });

  group('ForexCalculator.summarize', () {
    test('provides full summary', () {
      const pair = ForexPair(base: 'GBP', quote: 'USD');
      final candles = [
        DailyCandle(
          date: DateTime(2025, 1, 1),
          open: 1.2600,
          high: 1.2700,
          low: 1.2580,
          close: 1.2650,
          volume: 500,
        ),
        DailyCandle(
          date: DateTime(2025, 1, 2),
          open: 1.2650,
          high: 1.2720,
          low: 1.2610,
          close: 1.2690,
          volume: 600,
        ),
      ];

      final result = calc.summarize(pair: pair, candles: candles);

      expect(result.pair, pair);
      expect(result.currentRate, closeTo(1.2690, 0.001));
      expect(result.averageDailyRange, greaterThan(0));
    });

    test('empty candles produces zeroed summary', () {
      const pair = ForexPair(base: 'EUR', quote: 'USD');
      final result = calc.summarize(pair: pair, candles: []);
      expect(result.currentRate, 0);
      expect(result.averageDailyRange, 0);
    });
  });

  group('ForexPair', () {
    test('symbol returns concatenated pair', () {
      const pair = ForexPair(base: 'EUR', quote: 'USD');
      expect(pair.symbol, 'EURUSD');
    });

    test('displayName returns base/quote', () {
      const pair = ForexPair(base: 'EUR', quote: 'USD');
      expect(pair.displayName, 'EUR/USD');
    });

    test('props equality', () {
      const a = ForexPair(base: 'EUR', quote: 'USD');
      const b = ForexPair(base: 'EUR', quote: 'USD');
      expect(a, equals(b));
    });
  });

  group('PipInfo props equality', () {
    test('equal instances match', () {
      const pair = ForexPair(base: 'EUR', quote: 'USD');
      const a = PipInfo(pair: pair, pipSize: 0.0001, pipValue: 10, spread: 1.5);
      const b = PipInfo(pair: pair, pipSize: 0.0001, pipValue: 10, spread: 1.5);
      expect(a, equals(b));
    });
  });

  group('ForexSummary props equality', () {
    test('equal instances match', () {
      const pair = ForexPair(base: 'A', quote: 'B');
      const a = ForexSummary(
        pair: pair,
        currentRate: 1.0,
        dailyChangePct: 0.5,
        weeklyChangePct: 1.2,
        dailyRange: 0.01,
        averageDailyRange: 0.012,
      );
      const b = ForexSummary(
        pair: pair,
        currentRate: 1.0,
        dailyChangePct: 0.5,
        weeklyChangePct: 1.2,
        dailyRange: 0.01,
        averageDailyRange: 0.012,
      );
      expect(a, equals(b));
    });
  });
}
