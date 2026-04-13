import 'package:cross_tide/src/domain/strategy_execution_metrics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StrategyExecutionMetrics', () {
    test('equality', () {
      const a = StrategyExecutionMetrics(
        strategyId: 'strat-1',
        status: StrategyExecutionStatus.running,
        totalSignals: 42,
        executedTrades: 38,
        successRate: 0.79,
      );
      const b = StrategyExecutionMetrics(
        strategyId: 'strat-1',
        status: StrategyExecutionStatus.running,
        totalSignals: 42,
        executedTrades: 38,
        successRate: 0.79,
      );
      expect(a, b);
    });

    test('copyWith changes executedTrades', () {
      const base = StrategyExecutionMetrics(
        strategyId: 'strat-1',
        status: StrategyExecutionStatus.running,
        totalSignals: 42,
        executedTrades: 38,
        successRate: 0.79,
      );
      final updated = base.copyWith(executedTrades: 40);
      expect(updated.executedTrades, 40);
    });

    test('props length is 5', () {
      const obj = StrategyExecutionMetrics(
        strategyId: 'strat-1',
        status: StrategyExecutionStatus.running,
        totalSignals: 42,
        executedTrades: 38,
        successRate: 0.79,
      );
      expect(obj.props.length, 5);
    });
  });
}
