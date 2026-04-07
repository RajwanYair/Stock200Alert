import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MonteCarloSimulator simulator = MonteCarloSimulator(defaultRuns: 100);

  BacktestResult makeResult(List<BacktestTrade> trades) => BacktestResult(
    ticker: 'AAPL',
    methodName: 'Test',
    startDate: DateTime(2024, 1, 1),
    endDate: DateTime(2024, 6, 1),
    trades: trades,
    startingEquity: 10000,
  );

  BacktestTrade makeTrade(double entry, double exit) => BacktestTrade(
    entryDate: DateTime(2024, 1, 1),
    entryPrice: entry,
    exitDate: DateTime(2024, 1, 10),
    exitPrice: exit,
    methodName: 'Test',
  );

  group('MonteCarloSimulator', () {
    test('empty trades produce zero summary', () {
      final MonteCarloSummary summary = simulator.simulate(makeResult([]));
      expect(summary.totalRuns, 0);
      expect(summary.medianReturnPct, 0);
    });

    test('deterministic with seed', () {
      final BacktestResult result = makeResult([
        makeTrade(100, 110),
        makeTrade(100, 90),
        makeTrade(100, 105),
      ]);
      final MonteCarloSummary s1 = simulator.simulate(result, seed: 42);
      final MonteCarloSummary s2 = simulator.simulate(result, seed: 42);
      expect(s1.medianReturnPct, s2.medianReturnPct);
      expect(s1.p5ReturnPct, s2.p5ReturnPct);
      expect(s1.p95ReturnPct, s2.p95ReturnPct);
    });

    test('produces expected number of runs', () {
      final BacktestResult result = makeResult([makeTrade(100, 110)]);
      final MonteCarloSummary summary = simulator.simulate(
        result,
        numRuns: 50,
        seed: 1,
      );
      expect(summary.totalRuns, 50);
    });

    test('p5 <= median <= p95', () {
      final BacktestResult result = makeResult([
        makeTrade(100, 110),
        makeTrade(100, 90),
        makeTrade(100, 105),
        makeTrade(100, 95),
      ]);
      final MonteCarloSummary summary = simulator.simulate(result, seed: 7);
      expect(summary.p5ReturnPct, lessThanOrEqualTo(summary.medianReturnPct));
      expect(summary.medianReturnPct, lessThanOrEqualTo(summary.p95ReturnPct));
    });

    test('worstMaxDrawdownPct is non-negative', () {
      final BacktestResult result = makeResult([
        makeTrade(100, 110),
        makeTrade(100, 80),
      ]);
      final MonteCarloSummary summary = simulator.simulate(result, seed: 42);
      expect(summary.worstMaxDrawdownPct, greaterThanOrEqualTo(0));
    });

    test('MonteCarloRun equality', () {
      const MonteCarloRun a = MonteCarloRun(
        runIndex: 0,
        finalEquity: 10000,
        totalReturnPct: 0,
        maxDrawdownPct: 0,
      );
      const MonteCarloRun b = MonteCarloRun(
        runIndex: 0,
        finalEquity: 10000,
        totalReturnPct: 0,
        maxDrawdownPct: 0,
      );
      expect(a, equals(b));
    });
  });
}
