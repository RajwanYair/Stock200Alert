import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AlertRateLimitRecord', () {
    late DateTime windowStart;

    setUp(() => windowStart = DateTime(2025, 6, 1, 9, 0));

    test('creates record with capacity', () {
      final record = AlertRateLimitRecord(
        symbol: 'AAPL',
        methodName: 'Micho',
        interval: AlertRateLimitInterval.perHour,
        maxAlerts: 5,
        alertsFired: 2,
        windowStart: windowStart,
      );
      expect(record.isExhausted, isFalse);
      expect(record.hasCapacity, isTrue);
      expect(record.remaining, 3);
    });

    test('isExhausted when alertsFired >= maxAlerts', () {
      final record = AlertRateLimitRecord(
        symbol: 'TSLA',
        methodName: 'RSI',
        interval: AlertRateLimitInterval.perDay,
        maxAlerts: 3,
        alertsFired: 3,
        windowStart: windowStart,
      );
      expect(record.isExhausted, isTrue);
      expect(record.hasCapacity, isFalse);
      expect(record.remaining, 0);
    });

    test('increment() adds one to alertsFired', () {
      final record = AlertRateLimitRecord(
        symbol: 'NVDA',
        methodName: 'MACD',
        interval: AlertRateLimitInterval.perMinute,
        maxAlerts: 2,
        alertsFired: 1,
        windowStart: windowStart,
      );
      final incremented = record.increment();
      expect(incremented.alertsFired, 2);
      expect(incremented.isExhausted, isTrue);
    });

    test('reset() clears alertsFired', () {
      final record = AlertRateLimitRecord(
        symbol: 'MSFT',
        methodName: 'Bollinger',
        interval: AlertRateLimitInterval.perHour,
        maxAlerts: 4,
        alertsFired: 4,
        windowStart: windowStart,
      );
      final newWindow = windowStart.add(const Duration(hours: 1));
      final reset = record.reset(newWindow);
      expect(reset.alertsFired, 0);
      expect(reset.windowStart, newWindow);
    });

    test('equality holds for identical records', () {
      final a = AlertRateLimitRecord(
        symbol: 'X',
        methodName: 'Y',
        interval: AlertRateLimitInterval.perDay,
        maxAlerts: 1,
        alertsFired: 0,
        windowStart: windowStart,
      );
      final b = AlertRateLimitRecord(
        symbol: 'X',
        methodName: 'Y',
        interval: AlertRateLimitInterval.perDay,
        maxAlerts: 1,
        alertsFired: 0,
        windowStart: windowStart,
      );
      expect(a, equals(b));
    });
  });
}
