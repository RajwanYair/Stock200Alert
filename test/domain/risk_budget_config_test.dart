import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StrategyRiskAllocation', () {
    test('creates instance correctly', () {
      const alloc = StrategyRiskAllocation(
        strategyName: 'Momentum',
        maxRiskPct: 10.0,
      );
      expect(alloc.strategyName, 'Momentum');
      expect(alloc.maxRiskPct, 10.0);
      expect(alloc.isUnallocated, isFalse);
    });

    test('isUnallocated when maxRiskPct is 0', () {
      const alloc = StrategyRiskAllocation(strategyName: 'X', maxRiskPct: 0.0);
      expect(alloc.isUnallocated, isTrue);
    });
  });

  group('RiskBudgetConfig', () {
    test('creates instance with allocations', () {
      const allocations = [
        StrategyRiskAllocation(strategyName: 'Trend', maxRiskPct: 15.0),
        StrategyRiskAllocation(strategyName: 'Mean Revert', maxRiskPct: 10.0),
      ];
      const config = RiskBudgetConfig(
        name: 'Conservative',
        allocations: allocations,
        totalBudgetPct: 30.0,
      );
      expect(config.name, 'Conservative');
      expect(config.usedBudgetPct, closeTo(25.0, 0.001));
      expect(config.remainingBudgetPct, closeTo(5.0, 0.001));
      expect(config.isOverallocated, isFalse);
      expect(config.isFullyAllocated, isFalse);
    });

    test('isOverallocated when used > total', () {
      const allocations = [
        StrategyRiskAllocation(strategyName: 'A', maxRiskPct: 40.0),
      ];
      const config = RiskBudgetConfig(
        name: 'Overcrowded',
        allocations: allocations,
        totalBudgetPct: 30.0,
      );
      expect(config.isOverallocated, isTrue);
    });

    test('isFullyAllocated when used == total', () {
      const allocations = [
        StrategyRiskAllocation(strategyName: 'A', maxRiskPct: 20.0),
        StrategyRiskAllocation(strategyName: 'B', maxRiskPct: 10.0),
      ];
      const config = RiskBudgetConfig(
        name: 'Full',
        allocations: allocations,
        totalBudgetPct: 30.0,
      );
      expect(config.isFullyAllocated, isTrue);
    });

    test('allocationFor returns correct entry or null', () {
      const allocations = [
        StrategyRiskAllocation(strategyName: 'Trend', maxRiskPct: 15.0),
      ];
      const config = RiskBudgetConfig(
        name: 'Test',
        allocations: allocations,
        totalBudgetPct: 20.0,
      );
      expect(config.allocationFor('Trend')!.maxRiskPct, 15.0);
      expect(config.allocationFor('Missing'), isNull);
    });

    test('equality holds for same values', () {
      const allocations = [
        StrategyRiskAllocation(strategyName: 'A', maxRiskPct: 10.0),
      ];
      const a = RiskBudgetConfig(
        name: 'R',
        allocations: allocations,
        totalBudgetPct: 20.0,
      );
      const b = RiskBudgetConfig(
        name: 'R',
        allocations: allocations,
        totalBudgetPct: 20.0,
      );
      expect(a, equals(b));
    });
  });
}
