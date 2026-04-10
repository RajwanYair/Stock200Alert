import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FeatureFlagEntry', () {
    test('creates disabled flag', () {
      const flag = FeatureFlagEntry(
        key: 'dark_mode',
        status: FeatureFlagStatus.disabled,
      );
      expect(flag.isDisabled, isTrue);
      expect(flag.isEnabled, isFalse);
      expect(flag.isRollout, isFalse);
      expect(flag.hasDescription, isFalse);
    });

    test('enable() returns enabled flag', () {
      const flag = FeatureFlagEntry(
        key: 'charts',
        status: FeatureFlagStatus.disabled,
      );
      final enabled = flag.enable();
      expect(enabled.isEnabled, isTrue);
      expect(enabled.rolloutPercent, 100);
    });

    test('disable() returns disabled flag', () {
      const flag = FeatureFlagEntry(
        key: 'charts',
        status: FeatureFlagStatus.enabled,
      );
      final disabled = flag.disable();
      expect(disabled.isDisabled, isTrue);
      expect(disabled.rolloutPercent, 0);
    });

    test('isRollout true for rollout status', () {
      const flag = FeatureFlagEntry(
        key: 'new_ui',
        status: FeatureFlagStatus.rollout,
        rolloutPercent: 25,
        description: 'New UI for 25% of users',
      );
      expect(flag.isRollout, isTrue);
      expect(flag.hasDescription, isTrue);
    });
  });

  group('FeatureFlagRegistry', () {
    test('returns count and enabled count', () {
      const registry = FeatureFlagRegistry(
        flags: [
          FeatureFlagEntry(key: 'a', status: FeatureFlagStatus.enabled),
          FeatureFlagEntry(key: 'b', status: FeatureFlagStatus.disabled),
          FeatureFlagEntry(key: 'c', status: FeatureFlagStatus.enabled),
        ],
      );
      expect(registry.count, 3);
      expect(registry.enabledCount, 2);
    });

    test('isEnabled returns true for enabled key', () {
      const registry = FeatureFlagRegistry(
        flags: [
          FeatureFlagEntry(key: 'dark_mode', status: FeatureFlagStatus.enabled),
        ],
      );
      expect(registry.isEnabled('dark_mode'), isTrue);
      expect(registry.isEnabled('charts'), isFalse);
    });

    test('flagFor returns entry or null', () {
      const registry = FeatureFlagRegistry(
        flags: [FeatureFlagEntry(key: 'x', status: FeatureFlagStatus.rollout)],
      );
      expect(registry.flagFor('x')!.key, 'x');
      expect(registry.flagFor('y'), isNull);
    });

    test('equality holds', () {
      const a = FeatureFlagRegistry(flags: []);
      const b = FeatureFlagRegistry(flags: []);
      expect(a, equals(b));
    });
  });
}
