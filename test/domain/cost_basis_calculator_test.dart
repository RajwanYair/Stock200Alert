import 'package:cross_tide/src/domain/cost_basis_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calc = CostBasisCalculator();

  group('CostBasisCalculator', () {
    test('returns zero for empty trades', () {
      final result = calc.compute([]);
      expect(result.totalShares, 0);
      expect(result.averageCost, 0);
      expect(result.tradeCount, 0);
    });

    test('computes average cost from multiple buys', () {
      final trades = [
        TradeEntry(
          ticker: 'AAPL',
          direction: TradeDirection.buy,
          shares: 10,
          pricePerShare: 100,
          executedAt: DateTime(2025, 1, 1),
        ),
        TradeEntry(
          ticker: 'AAPL',
          direction: TradeDirection.buy,
          shares: 10,
          pricePerShare: 120,
          executedAt: DateTime(2025, 2, 1),
        ),
      ];

      final result = calc.compute(trades);
      expect(result.totalShares, 20);
      expect(result.averageCost, closeTo(110, 0.01));
      expect(result.totalInvested, closeTo(2200, 0.01));
      expect(result.tradeCount, 2);
    });

    test('sell reduces shares and adjusts cost', () {
      final trades = [
        TradeEntry(
          ticker: 'AAPL',
          direction: TradeDirection.buy,
          shares: 20,
          pricePerShare: 100,
          executedAt: DateTime(2025, 1, 1),
        ),
        TradeEntry(
          ticker: 'AAPL',
          direction: TradeDirection.sell,
          shares: 10,
          pricePerShare: 120,
          executedAt: DateTime(2025, 2, 1),
        ),
      ];

      final result = calc.compute(trades);
      expect(result.totalShares, 10);
      // Average cost should remain ~100
      expect(result.averageCost, closeTo(100, 1));
    });

    test('selling all shares zeros out', () {
      final trades = [
        TradeEntry(
          ticker: 'X',
          direction: TradeDirection.buy,
          shares: 10,
          pricePerShare: 50,
          executedAt: DateTime(2025, 1, 1),
        ),
        TradeEntry(
          ticker: 'X',
          direction: TradeDirection.sell,
          shares: 10,
          pricePerShare: 60,
          executedAt: DateTime(2025, 2, 1),
        ),
      ];

      final result = calc.compute(trades);
      expect(result.totalShares, 0);
      expect(result.averageCost, 0);
    });

    test('tracks total fees', () {
      final trades = [
        TradeEntry(
          ticker: 'X',
          direction: TradeDirection.buy,
          shares: 10,
          pricePerShare: 100,
          executedAt: DateTime(2025, 1, 1),
          fees: 5.0,
        ),
        TradeEntry(
          ticker: 'X',
          direction: TradeDirection.sell,
          shares: 5,
          pricePerShare: 110,
          executedAt: DateTime(2025, 2, 1),
          fees: 3.0,
        ),
      ];

      final result = calc.compute(trades);
      expect(result.totalFees, 8.0);
    });

    test('unrealizedPnl computes correctly', () {
      const result = CostBasisResult(
        ticker: 'AAPL',
        totalShares: 10,
        averageCost: 100,
        totalInvested: 1000,
        totalFees: 0,
        tradeCount: 1,
      );
      expect(result.unrealizedPnl(120), closeTo(200, 0.01));
      expect(result.unrealizedPnlPct(120), closeTo(20, 0.01));
    });

    test('TradeEntry totalCost includes fees', () {
      final t = TradeEntry(
        ticker: 'X',
        direction: TradeDirection.buy,
        shares: 10,
        pricePerShare: 100,
        executedAt: DateTime(2025, 1, 1),
        fees: 5,
      );
      expect(t.totalCost, 1005);
    });

    test('TradeEntry props equality', () {
      final a = TradeEntry(
        ticker: 'X',
        direction: TradeDirection.buy,
        shares: 10,
        pricePerShare: 100,
        executedAt: DateTime(2025, 1, 1),
      );
      final b = TradeEntry(
        ticker: 'X',
        direction: TradeDirection.buy,
        shares: 10,
        pricePerShare: 100,
        executedAt: DateTime(2025, 1, 1),
      );
      expect(a, equals(b));
    });

    test('CostBasisResult props equality', () {
      const a = CostBasisResult(
        ticker: 'X',
        totalShares: 10,
        averageCost: 100,
        totalInvested: 1000,
        totalFees: 0,
        tradeCount: 1,
      );
      const b = CostBasisResult(
        ticker: 'X',
        totalShares: 10,
        averageCost: 100,
        totalInvested: 1000,
        totalFees: 0,
        tradeCount: 1,
      );
      expect(a, equals(b));
    });
  });
}
