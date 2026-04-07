import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChartDataPoint', () {
    test('fromCandle creates point with no indicators', () {
      final DailyCandle candle = DailyCandle(
        date: DateTime(2024, 1, 15),
        open: 100,
        high: 105,
        low: 98,
        close: 103,
        volume: 5000,
      );
      final ChartDataPoint point = ChartDataPoint.fromCandle(candle);

      expect(point.date, DateTime(2024, 1, 15));
      expect(point.open, 100);
      expect(point.high, 105);
      expect(point.low, 98);
      expect(point.close, 103);
      expect(point.volume, 5000);
      expect(point.hasIndicators, isFalse);
    });

    test('hasIndicators returns true when any indicator set', () {
      final ChartDataPoint point = ChartDataPoint(
        date: DateTime(2024, 1, 15),
        open: 100,
        high: 105,
        low: 98,
        close: 103,
        volume: 5000,
        sma200: 101.5,
      );
      expect(point.hasIndicators, isTrue);
    });

    test('full constructor with all indicators', () {
      final ChartDataPoint point = ChartDataPoint(
        date: DateTime(2024, 1, 15),
        open: 100,
        high: 105,
        low: 98,
        close: 103,
        volume: 5000,
        sma50: 102,
        sma150: 101,
        sma200: 100,
        ema12: 103,
        ema26: 101,
        rsi: 55,
        macdLine: 1.5,
        macdSignal: 1.2,
        macdHistogram: 0.3,
        bollingerUpper: 110,
        bollingerMiddle: 103,
        bollingerLower: 96,
        atr: 3.2,
      );
      expect(point.hasIndicators, isTrue);
      expect(point.sma50, 102);
      expect(point.rsi, 55);
      expect(point.bollingerLower, 96);
      expect(point.atr, 3.2);
    });

    test('copyWith preserves original values for unset fields', () {
      final ChartDataPoint original = ChartDataPoint(
        date: DateTime(2024, 1, 15),
        open: 100,
        high: 105,
        low: 98,
        close: 103,
        volume: 5000,
        sma200: 101.5,
      );
      final ChartDataPoint updated = original.copyWith(rsi: () => 65);
      expect(updated.sma200, 101.5);
      expect(updated.rsi, 65);
      expect(updated.close, 103);
    });

    test('copyWith can set nullable field to null', () {
      final ChartDataPoint original = ChartDataPoint(
        date: DateTime(2024, 1, 15),
        open: 100,
        high: 105,
        low: 98,
        close: 103,
        volume: 5000,
        sma200: 101.5,
      );
      final ChartDataPoint updated = original.copyWith(sma200: () => null);
      expect(updated.sma200, isNull);
    });

    test('equality works via Equatable', () {
      final ChartDataPoint a = ChartDataPoint(
        date: DateTime(2024, 1, 15),
        open: 100,
        high: 105,
        low: 98,
        close: 103,
        volume: 5000,
      );
      final ChartDataPoint b = ChartDataPoint(
        date: DateTime(2024, 1, 15),
        open: 100,
        high: 105,
        low: 98,
        close: 103,
        volume: 5000,
      );
      expect(a, equals(b));
    });
  });
}
