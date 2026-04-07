import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calculator = MeanTimeToAlertCalculator();

  group('MeanTimeToAlertCalculator', () {
    test('returns null for empty events', () {
      final result = calculator.compute(
        events: [],
        candleDateFor: (_) => DateTime.now(),
      );
      expect(result, isNull);
    });

    test('computes mean, min, max for single event', () {
      final candleDate = DateTime(2024, 6, 14);
      final fireTime = DateTime(2024, 6, 14, 18, 30);
      final event = AlertEvent(
        ticker: 'AAPL',
        alertType: 'michoMethodBuy',
        firedAt: fireTime,
        price: 150,
      );
      final result = calculator.compute(
        events: [event],
        candleDateFor: (_) => candleDate,
      );
      expect(result, isNotNull);
      expect(result!.eventCount, 1);
      expect(result.meanDuration.inHours, 18);
      expect(result.minDuration, result.maxDuration);
    });

    test('computes mean across multiple events', () {
      final base = DateTime(2024, 6, 14);
      final events = [
        AlertEvent(
          ticker: 'AAPL',
          alertType: 'buy',
          firedAt: base.add(const Duration(hours: 2)),
          price: 100,
        ),
        AlertEvent(
          ticker: 'TSLA',
          alertType: 'buy',
          firedAt: base.add(const Duration(hours: 4)),
          price: 200,
        ),
      ];
      final result = calculator.compute(
        events: events,
        candleDateFor: (_) => base,
      );
      expect(result!.eventCount, 2);
      expect(result.meanDuration.inHours, 3);
      expect(result.minDuration.inHours, 2);
      expect(result.maxDuration.inHours, 4);
    });

    test('handles zero delay', () {
      final now = DateTime(2024, 6, 14, 10, 0);
      final event = AlertEvent(
        ticker: 'AAPL',
        alertType: 'buy',
        firedAt: now,
        price: 100,
      );
      final result = calculator.compute(
        events: [event],
        candleDateFor: (_) => now,
      );
      expect(result!.meanDuration, Duration.zero);
    });
  });
}
