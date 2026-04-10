import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HoldingCostAnalysis', () {
    test('creates instance and computes basic values', () {
      const h = HoldingCostAnalysis(
        symbol: 'AAPL',
        avgCostBasis: 150.0,
        currentPrice: 200.0,
        quantity: 10,
        holdingDays: 400,
      );
      expect(h.totalCostBasis, closeTo(1500.0, 0.001));
      expect(h.marketValue, closeTo(2000.0, 0.001));
      expect(h.unrealizedPnl, closeTo(500.0, 0.001));
      expect(h.unrealizedPnlPct, closeTo(33.33, 0.01));
    });

    test('isProfit and isLoss correct', () {
      const profit = HoldingCostAnalysis(
        symbol: 'MSFT',
        avgCostBasis: 100.0,
        currentPrice: 120.0,
        quantity: 1,
        holdingDays: 100,
      );
      expect(profit.isProfit, isTrue);
      expect(profit.isLoss, isFalse);

      const loss = HoldingCostAnalysis(
        symbol: 'MSFT',
        avgCostBasis: 100.0,
        currentPrice: 80.0,
        quantity: 1,
        holdingDays: 100,
      );
      expect(loss.isProfit, isFalse);
      expect(loss.isLoss, isTrue);
    });

    test('isLongTerm true when holdingDays >= 365', () {
      const longTerm = HoldingCostAnalysis(
        symbol: 'X',
        avgCostBasis: 50.0,
        currentPrice: 55.0,
        quantity: 2,
        holdingDays: 365,
      );
      expect(longTerm.isLongTerm, isTrue);

      const shortTerm = HoldingCostAnalysis(
        symbol: 'X',
        avgCostBasis: 50.0,
        currentPrice: 55.0,
        quantity: 2,
        holdingDays: 364,
      );
      expect(shortTerm.isLongTerm, isFalse);
    });

    test('equality holds for identical instances', () {
      const a = HoldingCostAnalysis(
        symbol: 'Z',
        avgCostBasis: 10.0,
        currentPrice: 12.0,
        quantity: 3,
        holdingDays: 100,
      );
      const b = HoldingCostAnalysis(
        symbol: 'Z',
        avgCostBasis: 10.0,
        currentPrice: 12.0,
        quantity: 3,
        holdingDays: 100,
      );
      expect(a, equals(b));
    });
  });
}
