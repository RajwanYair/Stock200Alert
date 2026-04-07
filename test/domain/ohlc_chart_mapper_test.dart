import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const OhlcChartMapper mapper = OhlcChartMapper();

  List<DailyCandle> makeCandles(int count) => [
    for (int i = 0; i < count; i++)
      DailyCandle(
        date: DateTime(2024, 1, 1).add(Duration(days: i)),
        open: 100.0 + i,
        high: 105.0 + i,
        low: 95.0 + i,
        close: 103.0 + i,
        volume: 1000 + i,
      ),
  ];

  group('OhlcChartMapper', () {
    test('returns empty list for empty input', () {
      expect(mapper.map([]), isEmpty);
    });

    test('maps candles to OhlcBar objects', () {
      final List<DailyCandle> candles = makeCandles(3);
      final List<OhlcBar> bars = mapper.map(candles);

      expect(bars.length, 3);
      expect(bars[0].date, DateTime(2024, 1, 1));
      expect(bars[0].open, 100);
      expect(bars[0].high, 105);
      expect(bars[0].low, 95);
      expect(bars[0].close, 103);
      expect(bars[0].volume, 1000);
    });

    test('bullish direction when close >= open', () {
      final List<OhlcBar> bars = mapper.map([
        DailyCandle(
          date: DateTime(2024, 1, 1),
          open: 100,
          high: 110,
          low: 95,
          close: 108,
          volume: 1000,
        ),
      ]);
      expect(bars[0].direction, CandleDirection.bullish);
    });

    test('bearish direction when close < open', () {
      final List<OhlcBar> bars = mapper.map([
        DailyCandle(
          date: DateTime(2024, 1, 1),
          open: 108,
          high: 110,
          low: 95,
          close: 100,
          volume: 1000,
        ),
      ]);
      expect(bars[0].direction, CandleDirection.bearish);
    });

    test('bodyHeight is absolute open-close difference', () {
      final List<OhlcBar> bars = mapper.map([
        DailyCandle(
          date: DateTime(2024, 1, 1),
          open: 100,
          high: 110,
          low: 90,
          close: 105,
          volume: 1000,
        ),
      ]);
      expect(bars[0].bodyHeight, 5);
    });

    test('shadows calculated correctly for bullish bar', () {
      final List<OhlcBar> bars = mapper.map([
        DailyCandle(
          date: DateTime(2024, 1, 1),
          open: 100,
          high: 110,
          low: 95,
          close: 107,
          volume: 1000,
        ),
      ]);
      expect(bars[0].upperShadow, 3); // 110 - 107
      expect(bars[0].lowerShadow, 5); // 100 - 95
    });

    test('shadows calculated correctly for bearish bar', () {
      final List<OhlcBar> bars = mapper.map([
        DailyCandle(
          date: DateTime(2024, 1, 1),
          open: 107,
          high: 110,
          low: 95,
          close: 100,
          volume: 1000,
        ),
      ]);
      expect(bars[0].upperShadow, 3); // 110 - 107
      expect(bars[0].lowerShadow, 5); // 100 - 95
    });

    test('range is high minus low', () {
      final List<OhlcBar> bars = mapper.map([
        DailyCandle(
          date: DateTime(2024, 1, 1),
          open: 100,
          high: 110,
          low: 90,
          close: 105,
          volume: 1000,
        ),
      ]);
      expect(bars[0].range, 20);
    });

    test('mapRange filters by date range', () {
      final List<DailyCandle> candles = makeCandles(10);
      final List<OhlcBar> bars = mapper.mapRange(
        candles,
        from: DateTime(2024, 1, 3),
        to: DateTime(2024, 1, 7),
      );
      expect(bars.length, 5); // days 3, 4, 5, 6, 7
      expect(bars.first.date, DateTime(2024, 1, 3));
      expect(bars.last.date, DateTime(2024, 1, 7));
    });

    test('OhlcBar equality via Equatable', () {
      final OhlcBar a = OhlcBar(
        date: DateTime(2024, 1, 1),
        open: 100,
        high: 110,
        low: 90,
        close: 105,
        volume: 1000,
      );
      final OhlcBar b = OhlcBar(
        date: DateTime(2024, 1, 1),
        open: 100,
        high: 110,
        low: 90,
        close: 105,
        volume: 1000,
      );
      expect(a, equals(b));
    });
  });
}
