import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationPreference', () {
    test('default has all alert types enabled', () {
      const NotificationPreference pref = NotificationPreference(
        symbol: 'AAPL',
      );
      expect(pref.isAlertEnabled('sma200CrossUp'), isTrue);
      expect(pref.isAlertEnabled('anything'), isTrue);
      expect(pref.enabledAlertTypes, isEmpty);
    });

    test('specific alert types can be enabled', () {
      const NotificationPreference pref = NotificationPreference(
        symbol: 'AAPL',
        enabledAlertTypes: {'sma200CrossUp', 'michoMethodBuy'},
      );
      expect(pref.isAlertEnabled('sma200CrossUp'), isTrue);
      expect(pref.isAlertEnabled('rsiMethodBuy'), isFalse);
    });

    test('isMuted returns true before mutedUntil', () {
      final NotificationPreference pref = NotificationPreference(
        symbol: 'AAPL',
        mutedUntil: DateTime(2024, 6, 15, 12, 0),
      );
      expect(pref.isMuted(DateTime(2024, 6, 15, 11, 0)), isTrue);
      expect(pref.isMuted(DateTime(2024, 6, 15, 13, 0)), isFalse);
    });

    test('isMuted returns false when no mute set', () {
      const NotificationPreference pref = NotificationPreference(
        symbol: 'AAPL',
      );
      expect(pref.isMuted(DateTime(2024, 6, 15)), isFalse);
    });

    test('copyWith updates fields', () {
      const NotificationPreference original = NotificationPreference(
        symbol: 'AAPL',
        channel: NotificationChannel.push,
      );
      final NotificationPreference updated = original.copyWith(
        channel: NotificationChannel.silent,
        mutedUntil: () => DateTime(2024, 12, 31),
      );
      expect(updated.channel, NotificationChannel.silent);
      expect(updated.mutedUntil, DateTime(2024, 12, 31));
      expect(updated.symbol, 'AAPL');
    });

    test('copyWith clears mutedUntil', () {
      final NotificationPreference pref = NotificationPreference(
        symbol: 'AAPL',
        mutedUntil: DateTime(2024, 6, 15),
      );
      final NotificationPreference cleared = pref.copyWith(
        mutedUntil: () => null,
      );
      expect(cleared.mutedUntil, isNull);
    });

    test('equality via Equatable', () {
      const NotificationPreference a = NotificationPreference(
        symbol: 'AAPL',
        channel: NotificationChannel.inApp,
      );
      const NotificationPreference b = NotificationPreference(
        symbol: 'AAPL',
        channel: NotificationChannel.inApp,
      );
      expect(a, equals(b));
    });

    test('NotificationChannel labels', () {
      expect(NotificationChannel.push.label, 'Push');
      expect(NotificationChannel.inApp.label, 'In-App');
      expect(NotificationChannel.silent.label, 'Silent');
    });
  });
}
