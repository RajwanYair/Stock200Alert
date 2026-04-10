import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SystemAuditEntry', () {
    late DateTime ts;

    setUp(() => ts = DateTime(2025, 6, 1, 9, 0, 0));

    test('creates user action entry', () {
      final entry = SystemAuditEntry(
        entryId: 'al-001',
        action: 'ticker.add',
        actorId: 'user-123',
        timestamp: ts,
        targetEntityType: 'Ticker',
        targetEntityId: 'AAPL',
      );
      expect(entry.hasTarget, isTrue);
      expect(entry.isSystemAction, isFalse);
      expect(entry.hasMetadata, isFalse);
    });

    test('creates system action entry', () {
      final entry = SystemAuditEntry(
        entryId: 'al-002',
        action: 'alert.fired',
        actorId: 'system',
        timestamp: ts,
        isSystemAction: true,
        metadata: const {'method': 'Micho', 'symbol': 'NVDA'},
      );
      expect(entry.isSystemAction, isTrue);
      expect(entry.hasMetadata, isTrue);
    });

    test('hasTarget false when no entity type', () {
      final entry = SystemAuditEntry(
        entryId: 'al-003',
        action: 'app.startup',
        actorId: 'system',
        timestamp: ts,
        isSystemAction: true,
      );
      expect(entry.hasTarget, isFalse);
    });

    test('equality holds for identical entries', () {
      final a = SystemAuditEntry(
        entryId: 'x',
        action: 'test',
        actorId: 'u',
        timestamp: ts,
      );
      final b = SystemAuditEntry(
        entryId: 'x',
        action: 'test',
        actorId: 'u',
        timestamp: ts,
      );
      expect(a, equals(b));
    });
  });
}
