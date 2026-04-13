import 'package:cross_tide/src/domain/user_session_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserSessionRecord', () {
    test('equality', () {
      final a = UserSessionRecord(
        sessionId: 'sess-1',
        startedAt: DateTime(2025, 1, 1),
        durationSeconds: 300,
        terminationReason: SessionTerminationReason.userLogout,
        screenCount: 7,
      );
      final b = UserSessionRecord(
        sessionId: 'sess-1',
        startedAt: DateTime(2025, 1, 1),
        durationSeconds: 300,
        terminationReason: SessionTerminationReason.userLogout,
        screenCount: 7,
      );
      expect(a, b);
    });

    test('copyWith changes screenCount', () {
      final base = UserSessionRecord(
        sessionId: 'sess-1',
        startedAt: DateTime(2025, 1, 1),
        durationSeconds: 300,
        terminationReason: SessionTerminationReason.userLogout,
        screenCount: 7,
      );
      final updated = base.copyWith(screenCount: 8);
      expect(updated.screenCount, 8);
    });

    test('props length is 5', () {
      final obj = UserSessionRecord(
        sessionId: 'sess-1',
        startedAt: DateTime(2025, 1, 1),
        durationSeconds: 300,
        terminationReason: SessionTerminationReason.userLogout,
        screenCount: 7,
      );
      expect(obj.props.length, 5);
    });
  });
}
