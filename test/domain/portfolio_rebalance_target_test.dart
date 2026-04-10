import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AllocationTarget', () {
    test('creates instance with required fields', () {
      const target = AllocationTarget(symbol: 'AAPL', targetWeight: 25.0);
      expect(target.symbol, 'AAPL');
      expect(target.targetWeight, 25.0);
      expect(target.driftTolerancePct, 5.0);
    });

    test('lowerBound and upperBound computed correctly', () {
      const target = AllocationTarget(
        symbol: 'MSFT',
        targetWeight: 20.0,
        driftTolerancePct: 3.0,
      );
      expect(target.lowerBound, 17.0);
      expect(target.upperBound, 23.0);
    });

    test('isWithinTolerance returns true for in-band weight', () {
      const target = AllocationTarget(symbol: 'NVDA', targetWeight: 15.0);
      expect(target.isWithinTolerance(17.0), isTrue);
      expect(target.isWithinTolerance(9.9), isFalse);
      expect(target.isWithinTolerance(20.1), isFalse);
    });
  });

  group('PortfolioRebalanceTarget', () {
    test('creates instance with allocations', () {
      const targets = [
        AllocationTarget(symbol: 'AAPL', targetWeight: 50.0),
        AllocationTarget(symbol: 'MSFT', targetWeight: 50.0),
      ];
      const prt = PortfolioRebalanceTarget(
        name: 'Core Portfolio',
        targets: targets,
      );
      expect(prt.name, 'Core Portfolio');
      expect(prt.symbolCount, 2);
      expect(prt.rebalanceFrequencyDays, 90);
    });

    test('totalWeight sums allocations', () {
      const targets = [
        AllocationTarget(symbol: 'AAPL', targetWeight: 60.0),
        AllocationTarget(symbol: 'MSFT', targetWeight: 40.0),
      ];
      const prt = PortfolioRebalanceTarget(name: 'Test', targets: targets);
      expect(prt.totalWeight, closeTo(100.0, 0.001));
      expect(prt.isFullyAllocated, isTrue);
    });

    test('isFullyAllocated is false when weights do not sum to 100', () {
      const targets = [AllocationTarget(symbol: 'AAPL', targetWeight: 60.0)];
      const prt = PortfolioRebalanceTarget(name: 'Partial', targets: targets);
      expect(prt.isFullyAllocated, isFalse);
    });

    test('targetFor returns correct allocation', () {
      const targets = [
        AllocationTarget(symbol: 'AAPL', targetWeight: 50.0),
        AllocationTarget(symbol: 'MSFT', targetWeight: 50.0),
      ];
      const prt = PortfolioRebalanceTarget(name: 'T', targets: targets);
      expect(prt.targetFor('AAPL')!.targetWeight, 50.0);
      expect(prt.targetFor('TSLA'), isNull);
    });

    test('equality holds for same instance values', () {
      const targets = [AllocationTarget(symbol: 'X', targetWeight: 100.0)];
      const a = PortfolioRebalanceTarget(name: 'A', targets: targets);
      const b = PortfolioRebalanceTarget(name: 'A', targets: targets);
      expect(a, equals(b));
    });
  });
}
