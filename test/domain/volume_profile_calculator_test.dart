import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

List<DailyCandle> _candles(List<double> prices) => [
  for (int i = 0; i < prices.length; i++)
    DailyCandle(
      date: DateTime(2024, 1, 1).add(Duration(days: i)),
      open: prices[i],
      high: prices[i] + 2,
      low: prices[i] - 2,
      close: prices[i],
      volume: 1000000,
    ),
];

void main() {
  const calculator = VolumeProfileCalculator();

  group('VolumeProfileCalculator', () {
    test('const constructor', () {
      const VolumeProfileCalculator Function() create =
          VolumeProfileCalculator.new;
      expect(create(), isNotNull);
    });

    test('returns null for empty candles', () {
      expect(calculator.compute([]), isNull);
    });

    test('returns null for zero bin count', () {
      expect(calculator.compute(_candles([100]), binCount: 0), isNull);
    });

    test('returns null for flat range', () {
      final candles = List.generate(
        5,
        (i) => DailyCandle(
          date: DateTime(2024, 1, i + 1),
          open: 100,
          high: 100,
          low: 100,
          close: 100,
          volume: 1000,
        ),
      );
      expect(calculator.compute(candles), isNull);
    });

    test('returns valid profile with bins', () {
      final result = calculator.compute(_candles([100, 110, 120, 115, 105]));
      expect(result, isNotNull);
      expect(result!.bins.length, 24);
      expect(result.totalVolume, 5000000);
    });

    test('POC is the highest-volume bin', () {
      final result = calculator.compute(
        _candles([100, 110, 120, 115, 105]),
        binCount: 4,
      );
      expect(result, isNotNull);
      final VolumeProfileBin poc = result!.poc;
      for (final VolumeProfileBin bin in result.bins) {
        expect(poc.volume, greaterThanOrEqualTo(bin.volume));
      }
    });

    test('midPrice is average of low and high', () {
      const bin = VolumeProfileBin(priceLow: 100, priceHigh: 110, volume: 500);
      expect(bin.midPrice, 105.0);
    });

    test('bins span full price range', () {
      final result = calculator.compute(_candles([90, 100, 110]), binCount: 10);
      expect(result, isNotNull);
      expect(result!.bins.first.priceLow, lessThan(92));
      expect(result.bins.last.priceHigh, greaterThan(110));
    });
  });
}
