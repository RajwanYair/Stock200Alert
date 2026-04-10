import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TickerImportSession', () {
    late DateTime started;

    setUp(() => started = DateTime(2025, 6, 10, 9, 0));

    test('creates pending session', () {
      final session = TickerImportSession(
        sessionId: 'imp-001',
        sessionType: ImportSessionType.csvFile,
        totalRequested: 50,
        totalImported: 0,
        totalFailed: 0,
        startedAt: started,
      );
      expect(session.status, ImportSessionStatus.pending);
      expect(session.isComplete, isFalse);
      expect(session.isFailed, isFalse);
      expect(session.hasErrors, isFalse);
    });

    test('successRate computed correctly', () {
      final session = TickerImportSession(
        sessionId: 'imp-002',
        sessionType: ImportSessionType.pasteText,
        totalRequested: 20,
        totalImported: 18,
        totalFailed: 2,
        startedAt: started,
        status: ImportSessionStatus.partiallyCompleted,
      );
      expect(session.successRate, closeTo(0.9, 0.001));
      expect(session.isPartial, isTrue);
      expect(session.hasErrors, isTrue);
    });

    test('successRate is 1.0 when totalRequested is 0', () {
      final session = TickerImportSession(
        sessionId: 'imp-003',
        sessionType: ImportSessionType.manualEntry,
        totalRequested: 0,
        totalImported: 0,
        totalFailed: 0,
        startedAt: started,
      );
      expect(session.successRate, 1.0);
    });

    test('duration computed from completedAt', () {
      final completed = started.add(const Duration(seconds: 45));
      final session = TickerImportSession(
        sessionId: 'imp-004',
        sessionType: ImportSessionType.qrCode,
        totalRequested: 10,
        totalImported: 10,
        totalFailed: 0,
        startedAt: started,
        status: ImportSessionStatus.completed,
        completedAt: completed,
      );
      expect(session.isComplete, isTrue);
      expect(session.duration, const Duration(seconds: 45));
    });

    test('duration is null when not completed', () {
      final session = TickerImportSession(
        sessionId: 'imp-005',
        sessionType: ImportSessionType.deepLink,
        totalRequested: 5,
        totalImported: 0,
        totalFailed: 0,
        startedAt: started,
      );
      expect(session.duration, isNull);
    });

    test('equality holds for identical sessions', () {
      final a = TickerImportSession(
        sessionId: 'x',
        sessionType: ImportSessionType.csvFile,
        totalRequested: 1,
        totalImported: 1,
        totalFailed: 0,
        startedAt: started,
      );
      final b = TickerImportSession(
        sessionId: 'x',
        sessionType: ImportSessionType.csvFile,
        totalRequested: 1,
        totalImported: 1,
        totalFailed: 0,
        startedAt: started,
      );
      expect(a, equals(b));
    });
  });
}
