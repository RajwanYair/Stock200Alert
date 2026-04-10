import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AlertDeduplicationLog', () {
    AlertDeduplicationLog buildLog({
      DeduplicationOutcome outcome = DeduplicationOutcome.suppressed,
    }) => AlertDeduplicationLog(
      alertId: 'alert-001',
      ticker: 'AAPL',
      methodKey: 'micho',
      outcome: outcome,
      evaluatedAt: DateTime(2024, 6, 1, 9, 30),
      priorAlertId: 'alert-000',
      cooldownSeconds: 3600,
    );

    test('isSuppressed is true when outcome is suppressed', () {
      expect(
        buildLog(outcome: DeduplicationOutcome.suppressed).isSuppressed,
        isTrue,
      );
    });

    test('isSuppressed is false for accepted outcome', () {
      expect(
        buildLog(outcome: DeduplicationOutcome.accepted).isSuppressed,
        isFalse,
      );
    });

    test('isAccepted is true for accepted outcome', () {
      expect(
        buildLog(outcome: DeduplicationOutcome.accepted).isAccepted,
        isTrue,
      );
    });

    test('isAccepted is true for cooldownExpired outcome', () {
      expect(
        buildLog(outcome: DeduplicationOutcome.cooldownExpired).isAccepted,
        isTrue,
      );
    });

    test('isAccepted is false for suppressed outcome', () {
      expect(
        buildLog(outcome: DeduplicationOutcome.suppressed).isAccepted,
        isFalse,
      );
    });

    test('equality holds for same props', () {
      expect(buildLog(), equals(buildLog()));
    });
  });
}
