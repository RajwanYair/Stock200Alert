import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfigSnapshot', () {
    AppConfigSnapshot buildSnapshot() => AppConfigSnapshot(
      snapshotId: 'snap-001',
      appVersion: '2.6.0+20',
      capturedAt: DateTime(2024, 6, 1, 12),
      settings: const {'theme': 'dark', 'refreshInterval': 30},
      label: 'Pre-migration',
    );

    test('hasSettings is true when settings map is non-empty', () {
      expect(buildSnapshot().hasSettings, isTrue);
    });

    test('hasSettings is false for empty settings', () {
      final empty = AppConfigSnapshot(
        snapshotId: 'snap-002',
        appVersion: '2.6.0+20',
        capturedAt: DateTime(2024, 6, 1),
        settings: const {},
      );
      expect(empty.hasSettings, isFalse);
    });

    test('settingCount reflects map length', () {
      expect(buildSnapshot().settingCount, 2);
    });

    test('label defaults to null when omitted', () {
      final noLabel = AppConfigSnapshot(
        snapshotId: 'snap-003',
        appVersion: '2.6.0+20',
        capturedAt: DateTime(2024, 6, 1),
        settings: const {},
      );
      expect(noLabel.label, isNull);
    });

    test('equality holds for same props', () {
      expect(buildSnapshot(), equals(buildSnapshot()));
    });
  });
}
