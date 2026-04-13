import 'package:cross_tide/src/domain/data_export_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DataExportSchedule', () {
    test('equality', () {
      const a = DataExportSchedule(
        scheduleId: 'sched-1',
        dataScope: ExportDataScope.all,
        cronExpression: '0 8 * * 1',
        destinationPath: '/exports',
        isEnabled: true,
      );
      const b = DataExportSchedule(
        scheduleId: 'sched-1',
        dataScope: ExportDataScope.all,
        cronExpression: '0 8 * * 1',
        destinationPath: '/exports',
        isEnabled: true,
      );
      expect(a, b);
    });

    test('copyWith changes isEnabled', () {
      const base = DataExportSchedule(
        scheduleId: 'sched-1',
        dataScope: ExportDataScope.all,
        cronExpression: '0 8 * * 1',
        destinationPath: '/exports',
        isEnabled: true,
      );
      final updated = base.copyWith(isEnabled: false);
      expect(updated.isEnabled, false);
    });

    test('props length is 5', () {
      const obj = DataExportSchedule(
        scheduleId: 'sched-1',
        dataScope: ExportDataScope.all,
        cronExpression: '0 8 * * 1',
        destinationPath: '/exports',
        isEnabled: true,
      );
      expect(obj.props.length, 5);
    });
  });
}
