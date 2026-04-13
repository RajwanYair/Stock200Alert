import 'package:cross_tide/src/domain/push_notification_token.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PushNotificationToken', () {
    test('equality', () {
      final a = PushNotificationToken(
        userId: 'user-1',
        token: 'fcm-token-abc',
        platform: PushTokenPlatform.android,
        isValid: true,
        registeredAt: DateTime(2025, 1, 1),
      );
      final b = PushNotificationToken(
        userId: 'user-1',
        token: 'fcm-token-abc',
        platform: PushTokenPlatform.android,
        isValid: true,
        registeredAt: DateTime(2025, 1, 1),
      );
      expect(a, b);
    });

    test('copyWith changes isValid', () {
      final base = PushNotificationToken(
        userId: 'user-1',
        token: 'fcm-token-abc',
        platform: PushTokenPlatform.android,
        isValid: true,
        registeredAt: DateTime(2025, 1, 1),
      );
      final updated = base.copyWith(isValid: false);
      expect(updated.isValid, false);
    });

    test('props length is 5', () {
      final obj = PushNotificationToken(
        userId: 'user-1',
        token: 'fcm-token-abc',
        platform: PushTokenPlatform.android,
        isValid: true,
        registeredAt: DateTime(2025, 1, 1),
      );
      expect(obj.props.length, 5);
    });
  });
}
