import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EscalationChannel', () {
    test('has 4 values', () {
      expect(EscalationChannel.values.length, 4);
    });
  });

  group('AlertEscalationPolicy', () {
    const base = AlertEscalationPolicy(
      policyId: 'pol1',
      escalationChannel: EscalationChannel.pushNotification,
      initialDelayMinutes: 10,
      repeatIntervalMinutes: 5,
      maxEscalations: 3,
    );

    test('isRepeating is true when repeatIntervalMinutes > 0', () {
      expect(base.isRepeating, isTrue);
    });

    test('isRepeating is false when repeatIntervalMinutes is 0', () {
      const p = AlertEscalationPolicy(
        policyId: 'p2',
        escalationChannel: EscalationChannel.email,
        initialDelayMinutes: 5,
        repeatIntervalMinutes: 0,
        maxEscalations: 1,
      );
      expect(p.isRepeating, isFalse);
    });

    test('isUnbounded is true when maxEscalations is 0', () {
      const p = AlertEscalationPolicy(
        policyId: 'p3',
        escalationChannel: EscalationChannel.sms,
        initialDelayMinutes: 5,
        repeatIntervalMinutes: 10,
        maxEscalations: 0,
      );
      expect(p.isUnbounded, isTrue);
    });

    test('isUnbounded is false when maxEscalations > 0', () {
      expect(base.isUnbounded, isFalse);
    });

    test('isEnabled defaults to true', () {
      expect(base.isEnabled, isTrue);
    });

    test('equality holds for same props', () {
      const copy = AlertEscalationPolicy(
        policyId: 'pol1',
        escalationChannel: EscalationChannel.pushNotification,
        initialDelayMinutes: 10,
        repeatIntervalMinutes: 5,
        maxEscalations: 3,
      );
      expect(base, equals(copy));
    });
  });
}
