import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AlertPriorityLevel', () {
    test('has 5 values', () {
      expect(AlertPriorityLevel.values.length, 5);
    });

    test('critical is index 0 (lowest sort rank)', () {
      expect(AlertPriorityLevel.critical.index, 0);
    });
  });

  group('AlertPriorityEntry', () {
    final base = AlertPriorityEntry(
      alertId: 'a1',
      ticker: 'AAPL',
      priorityLevel: AlertPriorityLevel.critical,
      createdAt: DateTime(2024, 1, 1),
      note: 'Watch closely',
    );

    test('isUrgent is true for critical', () {
      expect(base.isUrgent, isTrue);
    });

    test('isUrgent is true for high', () {
      final e = AlertPriorityEntry(
        alertId: 'a2',
        ticker: 'MSFT',
        priorityLevel: AlertPriorityLevel.high,
        createdAt: DateTime(2024, 1, 1),
      );
      expect(e.isUrgent, isTrue);
    });

    test('isUrgent is false for medium', () {
      final e = AlertPriorityEntry(
        alertId: 'a3',
        ticker: 'GOOGL',
        priorityLevel: AlertPriorityLevel.medium,
        createdAt: DateTime(2024, 1, 1),
      );
      expect(e.isUrgent, isFalse);
    });

    test('sortRank equals priority level index', () {
      expect(base.sortRank, AlertPriorityLevel.critical.index);
    });

    test('note is nullable', () {
      final noNote = AlertPriorityEntry(
        alertId: 'a4',
        ticker: 'TSLA',
        priorityLevel: AlertPriorityLevel.low,
        createdAt: DateTime(2024, 1, 1),
      );
      expect(noNote.note, isNull);
    });

    test('equality holds for same data', () {
      final copy = AlertPriorityEntry(
        alertId: 'a1',
        ticker: 'AAPL',
        priorityLevel: AlertPriorityLevel.critical,
        createdAt: DateTime(2024, 1, 1),
        note: 'Watch closely',
      );
      expect(base, equals(copy));
    });
  });
}
