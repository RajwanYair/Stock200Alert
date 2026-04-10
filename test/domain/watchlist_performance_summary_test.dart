import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WatchlistPerformanceSummary', () {
    late DateTime calculated;

    setUp(() => calculated = DateTime(2025, 7, 1));

    test('creates summary with correct fields', () {
      final summary = WatchlistPerformanceSummary(
        groupName: 'Tech',
        symbols: const ['AAPL', 'MSFT', 'NVDA'],
        avgReturnPct: 12.5,
        bestPerformerSymbol: 'NVDA',
        worstPerformerSymbol: 'MSFT',
        bestReturnPct: 40.0,
        worstReturnPct: -5.0,
        calculatedAt: calculated,
      );
      expect(summary.symbolCount, 3);
      expect(summary.returnSpread, closeTo(45.0, 0.001));
      expect(summary.isGroupPositive, isTrue);
      expect(summary.hasHighDispersion, isTrue);
    });

    test('isGroupPositive false when avg return < 0', () {
      final summary = WatchlistPerformanceSummary(
        groupName: 'Demo',
        symbols: const ['A'],
        avgReturnPct: -3.0,
        bestPerformerSymbol: 'A',
        worstPerformerSymbol: 'A',
        bestReturnPct: 5.0,
        worstReturnPct: -10.0,
        calculatedAt: calculated,
      );
      expect(summary.isGroupPositive, isFalse);
    });

    test('hasHighDispersion false when returnSpread <= 20', () {
      final summary = WatchlistPerformanceSummary(
        groupName: 'Stable',
        symbols: const ['A', 'B'],
        avgReturnPct: 5.0,
        bestPerformerSymbol: 'A',
        worstPerformerSymbol: 'B',
        bestReturnPct: 15.0,
        worstReturnPct: 5.0,
        calculatedAt: calculated,
      );
      expect(summary.hasHighDispersion, isFalse);
    });

    test('returnSpread is bestReturnPct minus worstReturnPct', () {
      final summary = WatchlistPerformanceSummary(
        groupName: 'X',
        symbols: const ['X'],
        avgReturnPct: 0,
        bestPerformerSymbol: 'X',
        worstPerformerSymbol: 'X',
        bestReturnPct: 30.0,
        worstReturnPct: 10.0,
        calculatedAt: calculated,
      );
      expect(summary.returnSpread, closeTo(20.0, 0.001));
    });

    test('equality holds for identical summaries', () {
      final a = WatchlistPerformanceSummary(
        groupName: 'G',
        symbols: const ['A'],
        avgReturnPct: 5.0,
        bestPerformerSymbol: 'A',
        worstPerformerSymbol: 'A',
        bestReturnPct: 10.0,
        worstReturnPct: 0.0,
        calculatedAt: calculated,
      );
      final b = WatchlistPerformanceSummary(
        groupName: 'G',
        symbols: const ['A'],
        avgReturnPct: 5.0,
        bestPerformerSymbol: 'A',
        worstPerformerSymbol: 'A',
        bestReturnPct: 10.0,
        worstReturnPct: 0.0,
        calculatedAt: calculated,
      );
      expect(a, equals(b));
    });
  });
}
