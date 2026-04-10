import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AlertNotificationLog', () {
    late DateTime delivered;

    setUp(() => delivered = DateTime(2025, 6, 1, 9, 30));

    test('creates unread delivered log entry', () {
      final log = AlertNotificationLog(
        logId: 'log-1',
        alertType: 'CrossUp',
        symbol: 'AAPL',
        channel: AlertDeliveryChannel.push,
        deliveredAt: delivered,
      );
      expect(log.isRead, isFalse);
      expect(log.isDelivered, isTrue);
      expect(log.isFailed, isFalse);
      expect(log.failureReason, isNull);
    });

    test('markRead() returns read entry', () {
      final log = AlertNotificationLog(
        logId: 'log-2',
        alertType: 'RSI Oversold',
        symbol: 'MSFT',
        channel: AlertDeliveryChannel.inApp,
        deliveredAt: delivered,
      );
      final read = log.markRead();
      expect(read.isRead, isTrue);
      expect(read.logId, 'log-2');
    });

    test('isFailed is true when isDelivered is false', () {
      final log = AlertNotificationLog(
        logId: 'log-3',
        alertType: 'MACD',
        symbol: 'TSLA',
        channel: AlertDeliveryChannel.push,
        deliveredAt: delivered,
        isDelivered: false,
        failureReason: 'Token expired',
      );
      expect(log.isFailed, isTrue);
      expect(log.failureReason, 'Token expired');
    });

    test('equality holds for identical entries', () {
      final a = AlertNotificationLog(
        logId: 'x',
        alertType: 'A',
        symbol: 'SPY',
        channel: AlertDeliveryChannel.email,
        deliveredAt: delivered,
      );
      final b = AlertNotificationLog(
        logId: 'x',
        alertType: 'A',
        symbol: 'SPY',
        channel: AlertDeliveryChannel.email,
        deliveredAt: delivered,
      );
      expect(a, equals(b));
    });
  });
}
