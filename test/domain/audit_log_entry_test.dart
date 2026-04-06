import 'package:cross_tide/src/domain/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final ts = DateTime(2025, 6, 1, 10, 30);

  group('AuditLogEntry', () {
    test('holds all fields correctly', () {
      final entry = AuditLogEntry(
        id: 1,
        timestamp: ts,
        field: 'refreshIntervalMinutes',
        oldValue: '60',
        newValue: '30',
        screen: 'SettingsScreen',
      );

      expect(entry.id, 1);
      expect(entry.timestamp, ts);
      expect(entry.field, 'refreshIntervalMinutes');
      expect(entry.oldValue, '60');
      expect(entry.newValue, '30');
      expect(entry.screen, 'SettingsScreen');
    });

    test('screen defaults to empty string', () {
      final entry = AuditLogEntry(
        timestamp: ts,
        field: 'advancedMode',
        oldValue: 'false',
        newValue: 'true',
      );
      expect(entry.screen, '');
    });

    test('id defaults to null', () {
      final entry = AuditLogEntry(
        timestamp: ts,
        field: 'x',
        oldValue: '1',
        newValue: '2',
      );
      expect(entry.id, isNull);
    });

    test('Equatable: equal when all props match', () {
      final a = AuditLogEntry(
        id: 5,
        timestamp: ts,
        field: 'providerName',
        oldValue: 'yahoo',
        newValue: 'alpha_vantage',
        screen: 'S',
      );
      final b = AuditLogEntry(
        id: 5,
        timestamp: ts,
        field: 'providerName',
        oldValue: 'yahoo',
        newValue: 'alpha_vantage',
        screen: 'S',
      );
      expect(a, equals(b));
    });

    test('Equatable: not equal when field differs', () {
      final a = AuditLogEntry(
        timestamp: ts,
        field: 'a',
        oldValue: '1',
        newValue: '2',
      );
      final b = AuditLogEntry(
        timestamp: ts,
        field: 'b',
        oldValue: '1',
        newValue: '2',
      );
      expect(a, isNot(equals(b)));
    });

    test('props list has 6 elements', () {
      final entry = AuditLogEntry(
        id: 3,
        timestamp: ts,
        field: 'f',
        oldValue: 'o',
        newValue: 'n',
        screen: 's',
      );
      expect(entry.props.length, 6);
    });
  });
}
