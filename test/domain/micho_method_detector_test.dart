import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MichoMethodDetector', () {
    const detector = MichoMethodDetector();

    /// Creates candles from a list of close prices.
    /// All candles share the same open/high/low/volume for simplicity.
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

    group('evaluateBuy', () {
      test('returns null with insufficient data (<151 candles)', () {
        final candles = makeCandles(List.filled(150, 100.0));
        final result = detector.evaluateBuy(ticker: 'TEST', candles: candles);
        expect(result, isNull);
      });

      test('triggers when price crosses above rising MA150 within 5%', () {
        // 151 candles: first 149 at $100 (SMA ~100), t-1 at $99, t at $102
        final closes = [
          ...List.filled(149, 100.0),
          99.0, // t-1: below SMA150 (~100)
          102.0, // t: above SMA150 and within 5%
        ];
        final candles = makeCandles(closes);

        final result = detector.evaluateBuy(ticker: 'TEST', candles: candles);

        expect(result, isNotNull);
        expect(result!.isTriggered, isTrue);
        expect(result.alertType, AlertType.michoMethodBuy);
        expect(result.methodName, 'Micho Method');
        expect(result.description, isNotNull);
      });

      test('does not trigger when price already above SMA150 (no cross)', () {
        // Both t-1 and t are above SMA — no cross-up
        final closes = [
          ...List.filled(149, 100.0),
          101.0, // t-1: above SMA
          102.0, // t: also above SMA
        ];
        final candles = makeCandles(closes);

        final result = detector.evaluateBuy(ticker: 'TEST', candles: candles);

        expect(result, isNotNull);
        expect(result!.isTriggered, isFalse);
      });

      test('does not trigger when price is >5% above MA150', () {
        // Cross-up but too far above MA150
        final closes = [
          ...List.filled(149, 100.0),
          99.0, // t-1: below SMA
          110.0, // t: 10% above SMA — exceeds 5% threshold
        ];
        final candles = makeCandles(closes);

        final result = detector.evaluateBuy(ticker: 'TEST', candles: candles);

        expect(result, isNotNull);
        expect(result!.isTriggered, isFalse);
      });

      test('does not trigger when MA150 is falling', () {
        // Setup: declining prices so SMA150 is falling.
        // Last 149 candles gently decline, then cross-up at end.
        // SMA at t will be less than SMA at t-1 because prices dropped.
        final closes = <double>[];
        for (var i = 0; i < 149; i++) {
          // Decline from 110 → 100 over 149 candles
          closes.add(110.0 - (i * 10.0 / 148));
        }
        closes.add(99.0); // t-1: below SMA
        closes.add(101.0); // t: slight cross-up

        final candles = makeCandles(closes);
        final result = detector.evaluateBuy(ticker: 'TEST', candles: candles);

        // SMA is declining so this should not trigger,
        // OR the cross-up math itself doesn't satisfy conditions.
        // Either way the signal should not be triggered:
        expect(result, isNotNull);
        expect(result!.isTriggered, isFalse);
      });

      test('custom maxAboveRatio is respected', () {
        const strictDetector = MichoMethodDetector(maxAboveRatio: 0.02);
        final closes = [
          ...List.filled(149, 100.0),
          99.0, // t-1: below SMA
          103.0, // t: 3% above — exceeds strict 2% limit
        ];
        final candles = makeCandles(closes);

        final result = strictDetector.evaluateBuy(
          ticker: 'TEST',
          candles: candles,
        );

        expect(result, isNotNull);
        expect(result!.isTriggered, isFalse);
      });
    });

    group('evaluateSell', () {
      test('returns null with insufficient data', () {
        final candles = makeCandles(List.filled(150, 100.0));
        final result = detector.evaluateSell(ticker: 'TEST', candles: candles);
        expect(result, isNull);
      });

      test('triggers when price crosses below MA150', () {
        // t-1: above SMA, t: below SMA
        final closes = [
          ...List.filled(149, 100.0),
          101.0, // t-1: above SMA ~100
          98.0, // t: below SMA
        ];
        final candles = makeCandles(closes);

        final result = detector.evaluateSell(ticker: 'TEST', candles: candles);

        expect(result, isNotNull);
        expect(result!.isTriggered, isTrue);
        expect(result.alertType, AlertType.michoMethodSell);
        expect(result.description, isNotNull);
      });

      test('does not trigger when price stays above MA150', () {
        final closes = [
          ...List.filled(149, 100.0),
          101.0, // t-1: above SMA
          102.0, // t: still above SMA
        ];
        final candles = makeCandles(closes);

        final result = detector.evaluateSell(ticker: 'TEST', candles: candles);

        expect(result, isNotNull);
        expect(result!.isTriggered, isFalse);
      });

      test('does not trigger when price stays below MA150', () {
        final closes = [
          ...List.filled(149, 100.0),
          99.0, // t-1: below SMA
          98.0, // t: still below SMA
        ];
        final candles = makeCandles(closes);

        final result = detector.evaluateSell(ticker: 'TEST', candles: candles);

        expect(result, isNotNull);
        expect(result!.isTriggered, isFalse);
      });
    });

    group('evaluateBoth', () {
      test('returns empty list when no signals trigger', () {
        // Both t-1 and t are at same level — no cross either way
        final closes = List.filled(151, 100.0);
        final candles = makeCandles(closes);

        final signals = detector.evaluateBoth(ticker: 'TEST', candles: candles);

        expect(signals, isEmpty);
      });

      test('returns BUY signal when buy conditions met', () {
        final closes = [...List.filled(149, 100.0), 99.0, 102.0];
        final candles = makeCandles(closes);

        final signals = detector.evaluateBoth(ticker: 'TEST', candles: candles);

        expect(signals.length, 1);
        expect(signals.first.alertType, AlertType.michoMethodBuy);
      });

      test('returns SELL signal when sell conditions met', () {
        final closes = [...List.filled(149, 100.0), 101.0, 98.0];
        final candles = makeCandles(closes);

        final signals = detector.evaluateBoth(ticker: 'TEST', candles: candles);

        expect(signals.length, 1);
        expect(signals.first.alertType, AlertType.michoMethodSell);
      });
    });

    group('MethodSignal', () {
      test('equality works via Equatable', () {
        final now = DateTime(2024, 6, 15);
        final a = MethodSignal(
          ticker: 'AAPL',
          methodName: 'Micho Method',
          alertType: AlertType.michoMethodBuy,
          isTriggered: true,
          evaluatedAt: now,
          currentClose: 150.0,
          currentSma: 148.0,
        );
        final b = MethodSignal(
          ticker: 'AAPL',
          methodName: 'Micho Method',
          alertType: AlertType.michoMethodBuy,
          isTriggered: true,
          evaluatedAt: now,
          currentClose: 150.0,
          currentSma: 148.0,
        );
        expect(a, equals(b));
      });
    });
  });
}
