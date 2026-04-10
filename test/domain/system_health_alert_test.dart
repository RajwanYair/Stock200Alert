import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SystemHealthAlert', () {
    late DateTime raised;

    setUp(() => raised = DateTime(2025, 6, 1, 8, 0));

    test('creates unresolved critical alert', () {
      final alert = SystemHealthAlert(
        alertId: 'ha-001',
        category: HealthAlertCategory.database,
        severity: HealthAlertSeverity.critical,
        message: 'DB connection pool exhausted',
        raisedAt: raised,
      );
      expect(alert.isCritical, isTrue);
      expect(alert.isError, isFalse);
      expect(alert.requiresAttention, isTrue);
      expect(alert.isResolved, isFalse);
      expect(alert.resolvedAt, isNull);
      expect(alert.resolutionTime, isNull);
    });

    test('resolve() returns resolved alert with duration', () {
      final alert = SystemHealthAlert(
        alertId: 'ha-002',
        category: HealthAlertCategory.network,
        severity: HealthAlertSeverity.error,
        message: 'Timeout',
        raisedAt: raised,
      );
      final resolved = alert.resolve(raised.add(const Duration(minutes: 15)));
      expect(resolved.isResolved, isTrue);
      expect(resolved.resolutionTime, const Duration(minutes: 15));
    });

    test('requiresAttention is false for info/warning severities', () {
      final info = SystemHealthAlert(
        alertId: 'ha-003',
        category: HealthAlertCategory.storage,
        severity: HealthAlertSeverity.info,
        message: 'Low disk space',
        raisedAt: raised,
      );
      expect(info.requiresAttention, isFalse);

      final warn = SystemHealthAlert(
        alertId: 'ha-004',
        category: HealthAlertCategory.backgroundTask,
        severity: HealthAlertSeverity.warning,
        message: 'WorkManager delayed',
        raisedAt: raised,
      );
      expect(warn.requiresAttention, isFalse);
    });

    test('equality holds for identical alerts', () {
      final a = SystemHealthAlert(
        alertId: 'x',
        category: HealthAlertCategory.auth,
        severity: HealthAlertSeverity.warning,
        message: 'Token refresh failed',
        raisedAt: raised,
      );
      final b = SystemHealthAlert(
        alertId: 'x',
        category: HealthAlertCategory.auth,
        severity: HealthAlertSeverity.warning,
        message: 'Token refresh failed',
        raisedAt: raised,
      );
      expect(a, equals(b));
    });
  });
}
