import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TradingJournalEntry', () {
    late DateTime recorded;

    setUp(() => recorded = DateTime(2025, 6, 15));

    test('creates an open entry without pnl', () {
      final entry = TradingJournalEntry(
        entryId: 'je-001',
        symbol: 'AAPL',
        setupType: 'Micho BUY',
        emotion: TraderEmotion.confident,
        outcome: TradeOutcome.open,
        recordedAt: recorded,
      );
      expect(entry.isOpen, isTrue);
      expect(entry.isWin, isFalse);
      expect(entry.hasPnl, isFalse);
      expect(entry.tags, isEmpty);
      expect(entry.isEmotional, isFalse);
    });

    test('emotional detection for fearful/greedy/impulsive/anxious', () {
      for (final em in [
        TraderEmotion.fearful,
        TraderEmotion.greedy,
        TraderEmotion.impulsive,
        TraderEmotion.anxious,
      ]) {
        final entry = TradingJournalEntry(
          entryId: 'x',
          symbol: 'X',
          setupType: 'RSI',
          emotion: em,
          outcome: TradeOutcome.loss,
          recordedAt: recorded,
        );
        expect(entry.isEmotional, isTrue, reason: 'Expected emotional for $em');
      }
    });

    test('non-emotional states are not isEmotional', () {
      for (final em in [
        TraderEmotion.confident,
        TraderEmotion.neutral,
        TraderEmotion.disciplined,
      ]) {
        final entry = TradingJournalEntry(
          entryId: 'x',
          symbol: 'X',
          setupType: 'MACD',
          emotion: em,
          outcome: TradeOutcome.win,
          recordedAt: recorded,
        );
        expect(entry.isEmotional, isFalse, reason: 'Expected calm for $em');
      }
    });

    test('isWin / isLoss flags work correctly', () {
      final win = TradingJournalEntry(
        entryId: 'w',
        symbol: 'MSFT',
        setupType: 'Golden Cross',
        emotion: TraderEmotion.disciplined,
        outcome: TradeOutcome.win,
        recordedAt: recorded,
        pnl: 250.0,
      );
      expect(win.isWin, isTrue);
      expect(win.isLoss, isFalse);
      expect(win.hasPnl, isTrue);
    });

    test('equality holds for identical entries', () {
      final a = TradingJournalEntry(
        entryId: 'e',
        symbol: 'Z',
        setupType: 'S',
        emotion: TraderEmotion.neutral,
        outcome: TradeOutcome.breakeven,
        recordedAt: recorded,
      );
      final b = TradingJournalEntry(
        entryId: 'e',
        symbol: 'Z',
        setupType: 'S',
        emotion: TraderEmotion.neutral,
        outcome: TradeOutcome.breakeven,
        recordedAt: recorded,
      );
      expect(a, equals(b));
    });
  });
}
