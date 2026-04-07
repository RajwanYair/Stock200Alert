import 'package:cross_tide/src/domain/options_heatmap_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const builder = OptionsHeatmapBuilder();

  group('OptionsHeatmapBuilder', () {
    test('empty strikes return zeroed summary', () {
      final result = builder.build(ticker: 'AAPL', strikes: []);
      expect(result.cells, isEmpty);
      expect(result.maxPainStrike, 0);
      expect(result.overallPutCallRatio, 0);
      expect(result.averageIV, 0);
    });

    test('groups calls and puts by strike', () {
      final strikes = [
        OptionsStrike(
          strike: 150,
          type: OptionType.call,
          openInterest: 1000,
          impliedVolatility: 0.30,
          volume: 500,
          expiration: DateTime(2025, 5, 16),
        ),
        OptionsStrike(
          strike: 150,
          type: OptionType.put,
          openInterest: 800,
          impliedVolatility: 0.35,
          volume: 300,
          expiration: DateTime(2025, 5, 16),
        ),
        OptionsStrike(
          strike: 160,
          type: OptionType.call,
          openInterest: 500,
          impliedVolatility: 0.25,
          volume: 200,
          expiration: DateTime(2025, 5, 16),
        ),
      ];

      final result = builder.build(ticker: 'AAPL', strikes: strikes);
      expect(result.cells, hasLength(2));

      // Sorted by strike ascending
      final cell150 = result.cells.first;
      expect(cell150.strike, 150);
      expect(cell150.callOI, 1000);
      expect(cell150.putOI, 800);
      expect(cell150.totalOI, 1800);
      expect(cell150.putCallRatio, closeTo(0.8, 0.01));
    });

    test('identifies max pain strike', () {
      final strikes = [
        OptionsStrike(
          strike: 100,
          type: OptionType.call,
          openInterest: 100,
          impliedVolatility: 0.2,
          volume: 50,
          expiration: DateTime(2025, 5, 16),
        ),
        OptionsStrike(
          strike: 110,
          type: OptionType.call,
          openInterest: 5000,
          impliedVolatility: 0.3,
          volume: 2000,
          expiration: DateTime(2025, 5, 16),
        ),
        OptionsStrike(
          strike: 110,
          type: OptionType.put,
          openInterest: 4000,
          impliedVolatility: 0.35,
          volume: 1500,
          expiration: DateTime(2025, 5, 16),
        ),
      ];

      final result = builder.build(ticker: 'X', strikes: strikes);
      expect(result.maxPainStrike, 110);
    });

    test('overall put/call ratio computed across all strikes', () {
      final strikes = [
        OptionsStrike(
          strike: 100,
          type: OptionType.call,
          openInterest: 1000,
          impliedVolatility: 0.3,
          volume: 100,
          expiration: DateTime(2025, 5, 16),
        ),
        OptionsStrike(
          strike: 100,
          type: OptionType.put,
          openInterest: 2000,
          impliedVolatility: 0.35,
          volume: 200,
          expiration: DateTime(2025, 5, 16),
        ),
      ];

      final result = builder.build(ticker: 'X', strikes: strikes);
      expect(result.overallPutCallRatio, closeTo(2.0, 0.01));
    });

    test('OptionsHeatmapCell props equality', () {
      const a = OptionsHeatmapCell(
        strike: 150,
        callOI: 100,
        putOI: 200,
        totalOI: 300,
        callIV: 0.3,
        putIV: 0.35,
        putCallRatio: 2.0,
      );
      const b = OptionsHeatmapCell(
        strike: 150,
        callOI: 100,
        putOI: 200,
        totalOI: 300,
        callIV: 0.3,
        putIV: 0.35,
        putCallRatio: 2.0,
      );
      expect(a, equals(b));
    });

    test('OptionsStrike props equality', () {
      final a = OptionsStrike(
        strike: 100,
        type: OptionType.call,
        openInterest: 500,
        impliedVolatility: 0.3,
        volume: 100,
        expiration: DateTime(2025, 5, 16),
      );
      final b = OptionsStrike(
        strike: 100,
        type: OptionType.call,
        openInterest: 500,
        impliedVolatility: 0.3,
        volume: 100,
        expiration: DateTime(2025, 5, 16),
      );
      expect(a, equals(b));
    });

    test('OptionsHeatmapSummary props equality', () {
      const a = OptionsHeatmapSummary(
        ticker: 'X',
        cells: [],
        maxPainStrike: 0,
        overallPutCallRatio: 0,
        averageIV: 0,
      );
      const b = OptionsHeatmapSummary(
        ticker: 'X',
        cells: [],
        maxPainStrike: 0,
        overallPutCallRatio: 0,
        averageIV: 0,
      );
      expect(a, equals(b));
    });
  });
}
