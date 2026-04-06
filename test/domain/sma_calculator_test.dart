import 'package:flutter_test/flutter_test.dart';
import 'package:stock_alert/src/domain/domain.dart';

void main() {
  group('SmaCalculator', () {
    const calc = SmaCalculator();

    List<DailyCandle> makeCandles(List<double> closes) {
      return closes.asMap().entries.map((e) {
        return DailyCandle(
          date: DateTime(2024, 1, 1).add(Duration(days: e.key)),
          open: e.value,
          high: e.value + 1,
          low: e.value - 1,
          close: e.value,
          volume: 1000000,
        );
      }).toList();
    }

    test('returns null when fewer than 200 candles', () {
      final candles = makeCandles(List.generate(199, (i) => 100.0 + i));
      expect(calc.compute(candles, period: 200), isNull);
    });

    test('computes SMA200 correctly with exactly 200 candles', () {
      // 200 candles all at $100 → SMA200 = $100
      final candles = makeCandles(List.filled(200, 100.0));
      expect(calc.compute(candles, period: 200), closeTo(100.0, 0.001));
    });

    test('computes SMA200 correctly with more than 200 candles', () {
      // 300 candles: first 100 at $50, next 200 at $100
      // SMA200 uses last 200 → all $100 → SMA = $100
      final closes = [...List.filled(100, 50.0), ...List.filled(200, 100.0)];
      final candles = makeCandles(closes);
      expect(calc.compute(candles, period: 200), closeTo(100.0, 0.001));
    });

    test('computes SMA200 with ascending values', () {
      // last 200 values: 1, 2, 3, ..., 200
      // Mean = (1+200)/2 = 100.5
      final closes = List.generate(200, (i) => (i + 1).toDouble());
      final candles = makeCandles(closes);
      expect(calc.compute(candles, period: 200), closeTo(100.5, 0.001));
    });

    test('computeSeries returns correct length and null prefix', () {
      final candles = makeCandles(List.generate(210, (i) => 100.0 + i));
      final series = calc.computeSeries(candles, period: 200);

      expect(series.length, 210);
      // First 199 entries should be null
      for (var i = 0; i < 199; i++) {
        expect(series[i].$2, isNull, reason: 'index $i should be null');
      }
      // Entry 199 and beyond should be non-null
      for (var i = 199; i < 210; i++) {
        expect(series[i].$2, isNotNull, reason: 'index $i should be non-null');
      }
    });

    test('SMA with smaller period for validation', () {
      // Period=3, candles=[10, 20, 30] → SMA = 20
      final candles = makeCandles([10, 20, 30]);
      expect(calc.compute(candles, period: 3), closeTo(20.0, 0.001));
    });
  });
}
