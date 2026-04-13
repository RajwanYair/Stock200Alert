import 'package:cross_tide/src/domain/quiet_hours_override.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuietHoursOverride', () {
    test('equality', () {
      const a = QuietHoursOverride(
        profileId: 'prof-1',
        mode: QuietHoursMode.scheduled,
        startHour: 22,
        endHour: 7,
        overrideUrgent: true,
      );
      const b = QuietHoursOverride(
        profileId: 'prof-1',
        mode: QuietHoursMode.scheduled,
        startHour: 22,
        endHour: 7,
        overrideUrgent: true,
      );
      expect(a, b);
    });

    test('copyWith changes startHour', () {
      const base = QuietHoursOverride(
        profileId: 'prof-1',
        mode: QuietHoursMode.scheduled,
        startHour: 22,
        endHour: 7,
        overrideUrgent: true,
      );
      final updated = base.copyWith(startHour: 23);
      expect(updated.startHour, 23);
    });

    test('props length is 5', () {
      const obj = QuietHoursOverride(
        profileId: 'prof-1',
        mode: QuietHoursMode.scheduled,
        startHour: 22,
        endHour: 7,
        overrideUrgent: true,
      );
      expect(obj.props.length, 5);
    });
  });
}
