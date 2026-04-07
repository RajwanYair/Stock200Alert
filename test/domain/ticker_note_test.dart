import 'package:cross_tide/src/domain/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final created = DateTime(2025, 6, 1, 9, 0);
  final updated = DateTime(2025, 6, 2, 11, 30);

  group('TickerNote', () {
    test('holds all fields correctly', () {
      final note = TickerNote(
        id: 1,
        symbol: 'AAPL',
        content: 'Strong buy signal near SMA200.',
        createdAt: created,
        updatedAt: updated,
      );
      expect(note.id, 1);
      expect(note.symbol, 'AAPL');
      expect(note.content, 'Strong buy signal near SMA200.');
      expect(note.createdAt, created);
      expect(note.updatedAt, updated);
    });

    test('id defaults to null when omitted', () {
      final note = TickerNote(
        symbol: 'MSFT',
        content: 'Watch for breakout.',
        createdAt: created,
      );
      expect(note.id, isNull);
      expect(note.updatedAt, isNull);
    });

    group('isEdited', () {
      test('returns false when updatedAt is null', () {
        final note = TickerNote(
          symbol: 'TSLA',
          content: 'Initial note.',
          createdAt: created,
        );
        expect(note.isEdited, isFalse);
      });

      test('returns true when updatedAt is set', () {
        final note = TickerNote(
          symbol: 'TSLA',
          content: 'Edited note.',
          createdAt: created,
          updatedAt: updated,
        );
        expect(note.isEdited, isTrue);
      });
    });

    group('copyWith', () {
      test('updates content and updatedAt', () {
        final original = TickerNote(
          id: 5,
          symbol: 'NVDA',
          content: 'Old content.',
          createdAt: created,
        );
        final copy = original.copyWith(
          content: 'New content.',
          updatedAt: updated,
        );
        expect(copy.id, 5);
        expect(copy.symbol, 'NVDA');
        expect(copy.content, 'New content.');
        expect(copy.createdAt, created);
        expect(copy.updatedAt, updated);
      });

      test('leaves fields unchanged when arguments are null', () {
        final original = TickerNote(
          id: 3,
          symbol: 'GOOG',
          content: 'Stable content.',
          createdAt: created,
          updatedAt: updated,
        );
        final copy = original.copyWith();
        expect(copy.content, 'Stable content.');
        expect(copy.updatedAt, updated);
      });
    });

    group('equality', () {
      test('two notes with same fields are equal', () {
        final a = TickerNote(
          id: 1,
          symbol: 'AAPL',
          content: 'Note A.',
          createdAt: created,
          updatedAt: updated,
        );
        final b = TickerNote(
          id: 1,
          symbol: 'AAPL',
          content: 'Note A.',
          createdAt: created,
          updatedAt: updated,
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('notes with different content are not equal', () {
        final a = TickerNote(
          symbol: 'AAPL',
          content: 'Note A.',
          createdAt: created,
        );
        final b = TickerNote(
          symbol: 'AAPL',
          content: 'Note B.',
          createdAt: created,
        );
        expect(a, isNot(equals(b)));
      });

      test('notes with different symbols are not equal', () {
        final a = TickerNote(
          symbol: 'AAPL',
          content: 'Same content.',
          createdAt: created,
        );
        final b = TickerNote(
          symbol: 'MSFT',
          content: 'Same content.',
          createdAt: created,
        );
        expect(a, isNot(equals(b)));
      });
    });
  });
}
