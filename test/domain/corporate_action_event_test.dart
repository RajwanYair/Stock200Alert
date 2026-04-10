import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CorporateActionEvent', () {
    late DateTime effective;

    setUp(() => effective = DateTime(2025, 3, 15));

    test('creates stock split event', () {
      final event = CorporateActionEvent(
        symbol: 'NVDA',
        actionType: CorporateActionType.stockSplit,
        effectiveDate: effective,
        splitRatio: 10.0,
      );
      expect(event.isSplit, isTrue);
      expect(event.isReverseSplit, isFalse);
      expect(event.isDelisting, isFalse);
      expect(event.splitRatio, 10.0);
      expect(event.hasNotes, isFalse);
    });

    test('creates reverse split event', () {
      final event = CorporateActionEvent(
        symbol: 'BBRY',
        actionType: CorporateActionType.reverseSplit,
        effectiveDate: effective,
        splitRatio: 0.1,
        notes: '10-for-1 reverse',
      );
      expect(event.isReverseSplit, isTrue);
      expect(event.isSplit, isTrue);
      expect(event.hasNotes, isTrue);
    });

    test('creates delisting event', () {
      final event = CorporateActionEvent(
        symbol: 'GONE',
        actionType: CorporateActionType.delisting,
        effectiveDate: effective,
      );
      expect(event.isDelisting, isTrue);
      expect(event.isSplit, isFalse);
    });

    test('isSplit false for non-split actions', () {
      final event = CorporateActionEvent(
        symbol: 'AAPL',
        actionType: CorporateActionType.merger,
        effectiveDate: effective,
      );
      expect(event.isSplit, isFalse);
    });

    test('equality holds for identical events', () {
      final a = CorporateActionEvent(
        symbol: 'X',
        actionType: CorporateActionType.spinOff,
        effectiveDate: effective,
      );
      final b = CorporateActionEvent(
        symbol: 'X',
        actionType: CorporateActionType.spinOff,
        effectiveDate: effective,
      );
      expect(a, equals(b));
    });
  });
}
