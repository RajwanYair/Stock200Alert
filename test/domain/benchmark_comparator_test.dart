import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const BenchmarkComparator comparator = BenchmarkComparator();

  DailyCandle candle(DateTime date, double close) => DailyCandle(
    date: date,
    open: close,
    high: close + 1,
    low: close - 1,
    close: close,
    volume: 1000,
  );

  group('BenchmarkComparator', () {
    test('returns empty for empty ticker list', () {
      expect(comparator.compare([], [candle(DateTime(2024), 100)]), isEmpty);
    });

    test('returns empty for empty benchmark list', () {
      expect(comparator.compare([candle(DateTime(2024), 100)], []), isEmpty);
    });

    test('returns empty when fewer than 2 common dates', () {
      final List<DailyCandle> ticker = [candle(DateTime(2024, 1, 1), 100)];
      final List<DailyCandle> benchmark = [candle(DateTime(2024, 1, 1), 200)];
      expect(comparator.compare(ticker, benchmark), isEmpty);
    });

    test('normalizes to base 100 by default', () {
      final List<DailyCandle> ticker = [
        candle(DateTime(2024, 1, 1), 50),
        candle(DateTime(2024, 1, 2), 55),
      ];
      final List<DailyCandle> benchmark = [
        candle(DateTime(2024, 1, 1), 200),
        candle(DateTime(2024, 1, 2), 210),
      ];
      final List<NormalizedPoint> result = comparator.compare(
        ticker,
        benchmark,
      );

      expect(result.length, 2);
      expect(result[0].tickerValue, 100);
      expect(result[0].benchmarkValue, 100);
      // Ticker: 55/50 * 100 = 110
      expect(result[1].tickerValue, closeTo(110, 0.01));
      // Benchmark: 210/200 * 100 = 105
      expect(result[1].benchmarkValue, closeTo(105, 0.01));
    });

    test('spread is positive when ticker outperforms', () {
      final List<DailyCandle> ticker = [
        candle(DateTime(2024, 1, 1), 100),
        candle(DateTime(2024, 1, 2), 120),
      ];
      final List<DailyCandle> benchmark = [
        candle(DateTime(2024, 1, 1), 100),
        candle(DateTime(2024, 1, 2), 105),
      ];
      final List<NormalizedPoint> result = comparator.compare(
        ticker,
        benchmark,
      );
      expect(result[1].spread, greaterThan(0));
    });

    test('only includes dates present in both series', () {
      final List<DailyCandle> ticker = [
        candle(DateTime(2024, 1, 1), 100),
        candle(DateTime(2024, 1, 2), 105),
        candle(DateTime(2024, 1, 3), 110),
      ];
      final List<DailyCandle> benchmark = [
        candle(DateTime(2024, 1, 1), 200),
        candle(DateTime(2024, 1, 3), 210),
      ];
      final List<NormalizedPoint> result = comparator.compare(
        ticker,
        benchmark,
      );
      expect(result.length, 2);
      expect(result[0].date, DateTime(2024, 1, 1));
      expect(result[1].date, DateTime(2024, 1, 3));
    });

    test('custom base value works', () {
      final List<DailyCandle> ticker = [
        candle(DateTime(2024, 1, 1), 50),
        candle(DateTime(2024, 1, 2), 75),
      ];
      final List<DailyCandle> benchmark = [
        candle(DateTime(2024, 1, 1), 100),
        candle(DateTime(2024, 1, 2), 100),
      ];
      final List<NormalizedPoint> result = comparator.compare(
        ticker,
        benchmark,
        base: 1000,
      );
      expect(result[0].tickerValue, 1000);
      // 75/50 * 1000 = 1500
      expect(result[1].tickerValue, closeTo(1500, 0.01));
    });

    test('returns empty when base price is zero', () {
      final List<DailyCandle> ticker = [
        candle(DateTime(2024, 1, 1), 0),
        candle(DateTime(2024, 1, 2), 50),
      ];
      final List<DailyCandle> benchmark = [
        candle(DateTime(2024, 1, 1), 100),
        candle(DateTime(2024, 1, 2), 110),
      ];
      expect(comparator.compare(ticker, benchmark), isEmpty);
    });

    test('NormalizedPoint equality via Equatable', () {
      final NormalizedPoint a = NormalizedPoint(
        date: DateTime(2024, 1, 1),
        tickerValue: 100,
        benchmarkValue: 100,
      );
      final NormalizedPoint b = NormalizedPoint(
        date: DateTime(2024, 1, 1),
        tickerValue: 100,
        benchmarkValue: 100,
      );
      expect(a, equals(b));
    });
  });
}
