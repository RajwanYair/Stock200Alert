import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const IndicatorOverlayBuilder builder = IndicatorOverlayBuilder();

  List<DailyCandle> makeCandles(int count) => [
    for (int i = 0; i < count; i++)
      DailyCandle(
        date: DateTime(2024, 1, 1).add(Duration(days: i)),
        open: 100.0 + i,
        high: 105.0 + i,
        low: 95.0 + i,
        close: 102.0 + i,
        volume: 1000,
      ),
  ];

  group('IndicatorOverlayBuilder', () {
    test('returns empty for empty candle list', () {
      expect(builder.build([]), isEmpty);
    });

    test('builds points with no indicators when none provided', () {
      final List<DailyCandle> candles = makeCandles(3);
      final List<ChartDataPoint> points = builder.build(candles);

      expect(points.length, 3);
      expect(points[0].close, 102);
      expect(points[0].sma50, isNull);
      expect(points[0].rsi, isNull);
      expect(points[0].hasIndicators, isFalse);
    });

    test('overlays SMA200 values by date lookup', () {
      final List<DailyCandle> candles = makeCandles(3);
      final IndicatorSeries sma200 = {
        DateTime(2024, 1, 1): 100.5,
        DateTime(2024, 1, 2): 101.0,
        // Day 3 intentionally missing
      };

      final List<ChartDataPoint> points = builder.build(
        candles,
        sma200: sma200,
      );
      expect(points[0].sma200, 100.5);
      expect(points[1].sma200, 101.0);
      expect(points[2].sma200, isNull);
    });

    test('overlays multiple indicators simultaneously', () {
      final List<DailyCandle> candles = makeCandles(2);
      final IndicatorSeries rsi = {
        DateTime(2024, 1, 1): 55.0,
        DateTime(2024, 1, 2): 60.0,
      };
      final IndicatorSeries atr = {
        DateTime(2024, 1, 1): 3.2,
        DateTime(2024, 1, 2): 3.5,
      };

      final List<ChartDataPoint> points = builder.build(
        candles,
        rsi: rsi,
        atr: atr,
      );
      expect(points[0].rsi, 55.0);
      expect(points[0].atr, 3.2);
      expect(points[1].rsi, 60.0);
      expect(points[1].atr, 3.5);
      expect(points[0].hasIndicators, isTrue);
    });

    test('MACD lines overlayed correctly', () {
      final List<DailyCandle> candles = makeCandles(1);
      final IndicatorSeries macdLine = {DateTime(2024, 1, 1): 1.5};
      final IndicatorSeries macdSignal = {DateTime(2024, 1, 1): 1.2};
      final IndicatorSeries macdHistogram = {DateTime(2024, 1, 1): 0.3};

      final List<ChartDataPoint> points = builder.build(
        candles,
        macdLine: macdLine,
        macdSignal: macdSignal,
        macdHistogram: macdHistogram,
      );
      expect(points[0].macdLine, 1.5);
      expect(points[0].macdSignal, 1.2);
      expect(points[0].macdHistogram, 0.3);
    });

    test('Bollinger bands overlayed correctly', () {
      final List<DailyCandle> candles = makeCandles(1);
      final IndicatorSeries upper = {DateTime(2024, 1, 1): 110.0};
      final IndicatorSeries middle = {DateTime(2024, 1, 1): 103.0};
      final IndicatorSeries lower = {DateTime(2024, 1, 1): 96.0};

      final List<ChartDataPoint> points = builder.build(
        candles,
        bollingerUpper: upper,
        bollingerMiddle: middle,
        bollingerLower: lower,
      );
      expect(points[0].bollingerUpper, 110);
      expect(points[0].bollingerMiddle, 103);
      expect(points[0].bollingerLower, 96);
    });

    test('preserves candle ordering', () {
      final List<DailyCandle> candles = makeCandles(5);
      final List<ChartDataPoint> points = builder.build(candles);

      for (int i = 1; i < points.length; i++) {
        expect(points[i].date.isAfter(points[i - 1].date), isTrue);
      }
    });
  });
}
