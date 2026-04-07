import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const NotificationDeliveryChain chain = NotificationDeliveryChain();

  group('NotificationDeliveryChain', () {
    test('delivers via first available channel', () {
      const NotificationPreference pref = NotificationPreference(
        symbol: 'AAPL',
      );
      final DeliveryChainResult result = chain.evaluate(
        pref,
        now: DateTime(2024, 6, 15),
      );
      expect(result.wasDelivered, isTrue);
      expect(result.deliveredVia, NotificationChannel.push);
      expect(result.attempts.length, 1);
    });

    test('skips disabled channels', () {
      const NotificationPreference pref = NotificationPreference(
        symbol: 'AAPL',
      );
      final DeliveryChainResult result = chain.evaluate(
        pref,
        now: DateTime(2024, 6, 15),
        disabledChannels: {NotificationChannel.push},
      );
      expect(result.wasDelivered, isTrue);
      expect(result.deliveredVia, NotificationChannel.inApp);
      expect(result.attempts.length, 2);
      expect(result.attempts[0].outcome, DeliveryOutcome.skipped);
    });

    test('all channels disabled returns not delivered', () {
      const NotificationPreference pref = NotificationPreference(
        symbol: 'AAPL',
      );
      final DeliveryChainResult result = chain.evaluate(
        pref,
        now: DateTime(2024, 6, 15),
        disabledChannels: {
          NotificationChannel.push,
          NotificationChannel.inApp,
          NotificationChannel.silent,
        },
      );
      expect(result.wasDelivered, isFalse);
      expect(result.deliveredVia, isNull);
    });

    test('muted preference skips all channels', () {
      final NotificationPreference pref = NotificationPreference(
        symbol: 'AAPL',
        mutedUntil: DateTime(2024, 6, 20),
      );
      final DeliveryChainResult result = chain.evaluate(
        pref,
        now: DateTime(2024, 6, 15),
      );
      expect(result.wasDelivered, isFalse);
      expect(result.attempts.length, 3);
      for (final DeliveryAttempt a in result.attempts) {
        expect(a.outcome, DeliveryOutcome.skipped);
      }
    });

    test('unmuted preference delivers normally', () {
      final NotificationPreference pref = NotificationPreference(
        symbol: 'AAPL',
        mutedUntil: DateTime(2024, 6, 10),
      );
      final DeliveryChainResult result = chain.evaluate(
        pref,
        now: DateTime(2024, 6, 15),
      );
      expect(result.wasDelivered, isTrue);
    });

    test('custom channel order', () {
      const NotificationDeliveryChain custom = NotificationDeliveryChain(
        channelOrder: [NotificationChannel.inApp, NotificationChannel.push],
      );
      const NotificationPreference pref = NotificationPreference(
        symbol: 'AAPL',
      );
      final DeliveryChainResult result = custom.evaluate(
        pref,
        now: DateTime(2024, 6, 15),
      );
      expect(result.deliveredVia, NotificationChannel.inApp);
    });

    test('DeliveryAttempt equality', () {
      const DeliveryAttempt a = DeliveryAttempt(
        channel: NotificationChannel.push,
        outcome: DeliveryOutcome.delivered,
      );
      const DeliveryAttempt b = DeliveryAttempt(
        channel: NotificationChannel.push,
        outcome: DeliveryOutcome.delivered,
      );
      expect(a, equals(b));
    });

    test('DeliveryOutcome values', () {
      expect(DeliveryOutcome.values.length, 3);
    });
  });
}
