import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VolatilityDataPoint', () {
    late DateTime date;

    setUp(() => date = DateTime(2025, 6, 1));

    test('creates data point without IV', () {
      final point = VolatilityDataPoint(date: date, historicalVolatility: 25.0);
      expect(point.hasImpliedVolatility, isFalse);
      expect(point.volSpread, isNull);
    });

    test('volSpread computed when IV provided', () {
      final point = VolatilityDataPoint(
        date: date,
        historicalVolatility: 20.0,
        impliedVolatility: 35.0,
      );
      expect(point.volSpread, closeTo(15.0, 0.001));
      expect(point.hasImpliedVolatility, isTrue);
    });
  });

  group('VolatilitySurface', () {
    late DateTime d1, d2, d3;

    setUp(() {
      d1 = DateTime(2025, 6, 1);
      d2 = DateTime(2025, 6, 2);
      d3 = DateTime(2025, 6, 3);
    });

    test('empty surface is empty', () {
      const surface = VolatilitySurface(
        symbol: 'AAPL',
        dataPoints: [],
        lookbackDays: 30,
      );
      expect(surface.isEmpty, isTrue);
      expect(surface.avgHistoricalVolatility, isNull);
      expect(surface.latest, isNull);
      expect(surface.isCurrentlyElevated, isFalse);
    });

    test('avgHistoricalVolatility computed correctly', () {
      final surface = VolatilitySurface(
        symbol: 'NVDA',
        dataPoints: [
          VolatilityDataPoint(date: d1, historicalVolatility: 20.0),
          VolatilityDataPoint(date: d2, historicalVolatility: 40.0),
        ],
        lookbackDays: 30,
      );
      expect(surface.avgHistoricalVolatility, closeTo(30.0, 0.001));
      expect(surface.length, 2);
    });

    test('isCurrentlyElevated true when latest > avg * 1.5', () {
      final surface = VolatilitySurface(
        symbol: 'TSLA',
        dataPoints: [
          VolatilityDataPoint(date: d1, historicalVolatility: 20.0),
          VolatilityDataPoint(date: d2, historicalVolatility: 20.0),
          VolatilityDataPoint(date: d3, historicalVolatility: 50.0),
        ],
        lookbackDays: 30,
      );
      final avg = surface.avgHistoricalVolatility!;
      expect(surface.latest!.historicalVolatility, greaterThan(avg * 1.5));
      expect(surface.isCurrentlyElevated, isTrue);
    });

    test('equality holds for identical surfaces', () {
      const a = VolatilitySurface(
        symbol: 'X',
        dataPoints: [],
        lookbackDays: 20,
      );
      const b = VolatilitySurface(
        symbol: 'X',
        dataPoints: [],
        lookbackDays: 20,
      );
      expect(a, equals(b));
    });
  });
}
