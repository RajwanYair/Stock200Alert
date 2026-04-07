import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const CandleRangeFilter filter = CandleRangeFilter();

  List<DailyCandle> makeCandles(int count, {DateTime? start}) {
    final DateTime base = start ?? DateTime(2024, 1, 1);
    return [
      for (int i = 0; i < count; i++)
        DailyCandle(
          date: base.add(Duration(days: i)),
          open: 100,
          high: 105,
          low: 95,
          close: 102,
          volume: 1000,
        ),
    ];
  }

  group('ChartTimeRange', () {
    test('enum values have correct labels', () {
      expect(ChartTimeRange.threeMonths.label, '3M');
      expect(ChartTimeRange.sixMonths.label, '6M');
      expect(ChartTimeRange.oneYear.label, '1Y');
      expect(ChartTimeRange.twoYears.label, '2Y');
      expect(ChartTimeRange.fiveYears.label, '5Y');
      expect(ChartTimeRange.max.label, 'Max');
    });

    test('enum values have correct day counts', () {
      expect(ChartTimeRange.threeMonths.days, 90);
      expect(ChartTimeRange.sixMonths.days, 180);
      expect(ChartTimeRange.oneYear.days, 365);
      expect(ChartTimeRange.twoYears.days, 730);
      expect(ChartTimeRange.fiveYears.days, 1825);
      expect(ChartTimeRange.max.days, 0);
    });
  });

  group('CandleRangeFilter', () {
    test('returns empty list for empty input', () {
      expect(
        filter.filter([], ChartTimeRange.oneYear, asOf: DateTime(2024, 6, 1)),
        isEmpty,
      );
    });

    test('returns all candles for max range', () {
      final List<DailyCandle> data = makeCandles(500);
      final List<DailyCandle> result = filter.filter(
        data,
        ChartTimeRange.max,
        asOf: DateTime(2025, 6, 1),
      );
      expect(result.length, 500);
    });

    test('filters to 3 months correctly', () {
      // 365 candles starting 2024-01-01
      final List<DailyCandle> data = makeCandles(365);
      final DateTime asOf = DateTime(2024, 12, 31);
      final List<DailyCandle> result = filter.filter(
        data,
        ChartTimeRange.threeMonths,
        asOf: asOf,
      );
      // cutoff = 2024-12-31 - 90 days = 2024-10-02
      for (final DailyCandle c in result) {
        expect(c.date.isAfter(DateTime(2024, 10, 1)), isTrue);
      }
      expect(result.length, lessThan(365));
    });

    test('filters to 1 year returns all when data is within range', () {
      // 100 days of data ending around 2024-04-10
      final List<DailyCandle> data = makeCandles(100);
      final DateTime asOf = DateTime(2024, 4, 10);
      final List<DailyCandle> result = filter.filter(
        data,
        ChartTimeRange.oneYear,
        asOf: asOf,
      );
      // All 100 candles are within 365 days of asOf
      expect(result.length, 100);
    });

    test('preserves original ordering', () {
      final List<DailyCandle> data = makeCandles(200);
      final List<DailyCandle> result = filter.filter(
        data,
        ChartTimeRange.sixMonths,
        asOf: DateTime(2024, 7, 18),
      );
      for (int i = 1; i < result.length; i++) {
        expect(result[i].date.isAfter(result[i - 1].date), isTrue);
      }
    });
  });
}
