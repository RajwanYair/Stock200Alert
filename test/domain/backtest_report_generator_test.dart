import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const BacktestReportGenerator generator = BacktestReportGenerator();

  BacktestTrade makeTrade(double entry, double exit) => BacktestTrade(
    entryDate: DateTime(2024, 1, 1),
    entryPrice: entry,
    exitDate: DateTime(2024, 1, 10),
    exitPrice: exit,
    methodName: 'Test',
  );

  group('BacktestReportGenerator', () {
    test('empty trades produce zero report', () {
      final BacktestResult result = BacktestResult(
        ticker: 'AAPL',
        methodName: 'Test',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 6, 1),
        trades: const [],
        startingEquity: 10000,
      );
      final BacktestReport report = generator.generate(result);
      expect(report.totalTrades, 0);
      expect(report.profitFactor, 0);
      expect(report.sharpeRatio, 0);
    });

    test('profitable trades report', () {
      final BacktestResult result = BacktestResult(
        ticker: 'AAPL',
        methodName: 'Test',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 6, 1),
        trades: [makeTrade(100, 110), makeTrade(100, 120)],
        startingEquity: 10000,
      );
      final BacktestReport report = generator.generate(result);
      expect(report.totalTrades, 2);
      expect(report.winRate, 100);
      expect(report.profitFactor, greaterThan(0));
      expect(report.avgWinPct, greaterThan(0));
      expect(report.avgLossPct, 0);
      expect(report.maxConsecutiveWins, 2);
      expect(report.maxConsecutiveLosses, 0);
    });

    test('mixed trades report', () {
      final BacktestResult result = BacktestResult(
        ticker: 'AAPL',
        methodName: 'Test',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 6, 1),
        trades: [makeTrade(100, 110), makeTrade(100, 90), makeTrade(100, 105)],
        startingEquity: 10000,
      );
      final BacktestReport report = generator.generate(result);
      expect(report.totalTrades, 3);
      expect(report.winRate, closeTo(66.67, 0.1));
      expect(report.profitFactor, greaterThan(0));
      expect(report.maxConsecutiveWins, 1);
      expect(report.maxConsecutiveLosses, 1);
      expect(report.avgLossPct, lessThan(0));
    });

    test('max drawdown tracked through equity curve', () {
      final BacktestResult result = BacktestResult(
        ticker: 'AAPL',
        methodName: 'Test',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 6, 1),
        trades: [makeTrade(100, 110), makeTrade(100, 80)],
        startingEquity: 10000,
      );
      final BacktestReport report = generator.generate(result);
      expect(report.maxDrawdownPct, greaterThan(0));
    });

    test('sharpe ratio for single trade', () {
      final BacktestResult result = BacktestResult(
        ticker: 'AAPL',
        methodName: 'Test',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 6, 1),
        trades: [makeTrade(100, 110)],
        startingEquity: 10000,
      );
      final BacktestReport report = generator.generate(result);
      expect(report.sharpeRatio, 0); // need >= 2 for stddev
    });

    test('BacktestReport equality', () {
      const BacktestReport a = BacktestReport(
        ticker: 'AAPL',
        methodName: 'Test',
        totalTrades: 0,
        winRate: 0,
        totalReturnPct: 0,
        profitFactor: 0,
        maxConsecutiveWins: 0,
        maxConsecutiveLosses: 0,
        avgWinPct: 0,
        avgLossPct: 0,
        maxDrawdownPct: 0,
        sharpeRatio: 0,
      );
      const BacktestReport b = BacktestReport(
        ticker: 'AAPL',
        methodName: 'Test',
        totalTrades: 0,
        winRate: 0,
        totalReturnPct: 0,
        profitFactor: 0,
        maxConsecutiveWins: 0,
        maxConsecutiveLosses: 0,
        avgWinPct: 0,
        avgLossPct: 0,
        maxDrawdownPct: 0,
        sharpeRatio: 0,
      );
      expect(a, equals(b));
    });
  });
}
