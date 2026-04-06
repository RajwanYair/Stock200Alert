import 'package:cross_tide/src/domain/entities.dart';
import 'package:cross_tide/src/domain/volume_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calc = VolumeCalculator();

  // Build a list of [n] candles with the given volumes.
  List<DailyCandle> makeCandles(List<double> volumes) {
    return List.generate(
      volumes.length,
      (i) => DailyCandle(
        date: DateTime(2024, 1, i + 1),
        open: 100,
        high: 105,
        low: 95,
        close: 100,
        volume: volumes[i].round(),
      ),
    );
  }

  // Build [n] candles all with volume 1000, then last candle has [lastVol].
  List<DailyCandle> makeSpikeCandles(double lastVol, {int n = 21}) {
    final vols = List<double>.filled(n, 1000.0);
    vols[n - 1] = lastVol;
    return makeCandles(vols);
  }

  group('VolumeCalculator.averageVolume', () {
    test('returns null when fewer than period candles', () {
      final candles = makeCandles(List.filled(15, 1000.0));
      expect(calc.averageVolume(candles), isNull);
    });

    test('computes average of preceding 19 candles (excludes latest)', () {
      // 20 candles: first 19 at 1000, last at 5000
      final candles = makeSpikeCandles(5000, n: 20);
      final avg = calc.averageVolume(candles);
      expect(avg, closeTo(1000.0, 1e-9));
    });

    test('uses correct window', () {
      // 21 candles: first 19 at 500, 20th at 500, 21st (last) has high vol
      final vols = List<double>.filled(21, 500.0);
      vols[20] = 9999;
      final candles = makeCandles(vols);
      final avg = calc.averageVolume(candles);
      // slice is [0..19] (20 items, but we do .sublist(1,20) = 19 items all 500)
      expect(avg, closeTo(500.0, 1e-9));
    });
  });

  group('VolumeCalculator.isSpike', () {
    test('returns false when not enough data', () {
      final candles = makeCandles(List.filled(10, 1000.0));
      expect(calc.isSpike(candles), isFalse);
    });

    test('detects spike when volume ≥ multiplier × avg', () {
      // avg ≈ 1000, last = 2500; multiplier = 2.0 → spike
      final candles = makeSpikeCandles(2500);
      expect(calc.isSpike(candles, multiplier: 2.0), isTrue);
    });

    test('does not flag spike below threshold', () {
      // avg ≈ 1000, last = 1500; multiplier = 2.0 → no spike
      final candles = makeSpikeCandles(1500);
      expect(calc.isSpike(candles, multiplier: 2.0), isFalse);
    });

    test('exact threshold boundary fires', () {
      // avg ≈ 1000, last = 2000 exactly; multiplier = 2.0 → fires (≥)
      final candles = makeSpikeCandles(2000);
      expect(calc.isSpike(candles, multiplier: 2.0), isTrue);
    });
  });

  group('VolumeCalculator.spikeRatio', () {
    test('returns null when not enough data', () {
      final candles = makeCandles(List.filled(5, 500.0));
      expect(calc.spikeRatio(candles), isNull);
    });

    test('returns correct ratio', () {
      // avg ≈ 1000, last = 3000 → ratio ≈ 3.0
      final candles = makeSpikeCandles(3000);
      final ratio = calc.spikeRatio(candles);
      expect(ratio, closeTo(3.0, 0.01));
    });
  });
}
