import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AlertEventLog', () {
    test('created event', () {
      final AlertEventLog log = AlertEventLog(
        alertId: 1,
        symbol: 'AAPL',
        alertType: 'sma200CrossUp',
        eventType: AlertEventType.created,
        occurredAt: DateTime(2024, 6, 15, 10, 0),
      );
      expect(log.alertId, 1);
      expect(log.symbol, 'AAPL');
      expect(log.eventType, AlertEventType.created);
      expect(log.channel, isNull);
      expect(log.reason, isNull);
    });

    test('delivered event with channel', () {
      final AlertEventLog log = AlertEventLog(
        alertId: 1,
        symbol: 'AAPL',
        alertType: 'sma200CrossUp',
        eventType: AlertEventType.delivered,
        occurredAt: DateTime(2024, 6, 15, 10, 0),
        channel: 'push',
      );
      expect(log.channel, 'push');
    });

    test('suppressed event with reason', () {
      final AlertEventLog log = AlertEventLog(
        alertId: 1,
        symbol: 'AAPL',
        alertType: 'sma200CrossUp',
        eventType: AlertEventType.suppressed,
        occurredAt: DateTime(2024, 6, 15, 10, 0),
        reason: 'Quiet hours',
      );
      expect(log.reason, 'Quiet hours');
    });

    test('equality via Equatable', () {
      final AlertEventLog a = AlertEventLog(
        alertId: 1,
        symbol: 'AAPL',
        alertType: 'sma200CrossUp',
        eventType: AlertEventType.created,
        occurredAt: DateTime(2024, 6, 15),
      );
      final AlertEventLog b = AlertEventLog(
        alertId: 1,
        symbol: 'AAPL',
        alertType: 'sma200CrossUp',
        eventType: AlertEventType.created,
        occurredAt: DateTime(2024, 6, 15),
      );
      expect(a, equals(b));
    });

    test('AlertEventType labels', () {
      expect(AlertEventType.created.label, 'Created');
      expect(AlertEventType.delivered.label, 'Delivered');
      expect(AlertEventType.acknowledged.label, 'Acknowledged');
      expect(AlertEventType.dismissed.label, 'Dismissed');
      expect(AlertEventType.suppressed.label, 'Suppressed');
    });
  });
}
