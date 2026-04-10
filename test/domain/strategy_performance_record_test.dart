import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StrategyCategory', () {
    test('has expected values', () {
      expect(StrategyCategory.values.length, 5);
      expect(StrategyCategory.trendFollowing.name, 'trendFollowing');
      expect(StrategyCategory.arbitrage.name, 'arbitrage');
    });
  });

  group('StrategyPerformanceRecord', () {
    StrategyPerformanceRecord buildRecord({
      double totalReturnPct = 15.0,
      double maxDrawdownPct = 8.0,
      double winRatePct = 55.0,
      int totalTrades = 100,
      double sharpeRatio = 1.2,
    }) {
      return StrategyPerformanceRecord(
        strategyId: 'trend_01',
        strategyName: 'Trend Master',
        category: StrategyCategory.trendFollowing,
        totalReturnPct: totalReturnPct,
        maxDrawdownPct: maxDrawdownPct,
        winRatePct: winRatePct,
        totalTrades: totalTrades,
        sharpeRatio: sharpeRatio,
        evaluatedAt: DateTime(2024, 6, 1),
      );
    }

    test('isViable is true with positive Sharpe and win rate >= 50', () {
      final record = buildRecord(sharpeRatio: 0.1, winRatePct: 50.0);
      expect(record.isViable, isTrue);
    });

    test('isViable is false when winRate < 50', () {
      final record = buildRecord(winRatePct: 49.0);
      expect(record.isViable, isFalse);
    });

    test('isViable is false when sharpeRatio <= 0', () {
      final record = buildRecord(sharpeRatio: 0.0);
      expect(record.isViable, isFalse);
    });

    test('qualityLabel returns Excellent for sharpe >= 2.0', () {
      expect(buildRecord(sharpeRatio: 2.0).qualityLabel, 'Excellent');
    });

    test('qualityLabel returns Good for sharpe >= 1.0 < 2.0', () {
      expect(buildRecord(sharpeRatio: 1.0).qualityLabel, 'Good');
    });

    test('qualityLabel returns Acceptable for sharpe >= 0.5 < 1.0', () {
      expect(buildRecord(sharpeRatio: 0.5).qualityLabel, 'Acceptable');
    });

    test('qualityLabel returns Poor for sharpe < 0.5', () {
      expect(buildRecord(sharpeRatio: 0.4).qualityLabel, 'Poor');
    });

    test('equality holds for same props', () {
      final a = buildRecord();
      final b = buildRecord();
      expect(a, equals(b));
    });
  });
}
