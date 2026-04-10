import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderFlowImbalance', () {
    late DateTime measured;

    setUp(() => measured = DateTime(2025, 6, 1, 14));

    test('creates instance with buy-dominated direction', () {
      final ofi = OrderFlowImbalance(
        symbol: 'AAPL',
        buyVolume: 800_000,
        sellVolume: 200_000,
        measuredAt: measured,
      );
      expect(ofi.totalVolume, closeTo(1_000_000, 0.001));
      expect(ofi.imbalanceRatio, closeTo(0.8, 0.001));
      expect(ofi.direction, ImbalanceDirection.buyDominated);
      expect(ofi.isBuyDominated, isTrue);
      expect(ofi.isSellDominated, isFalse);
      expect(ofi.isBalanced, isFalse);
    });

    test('sell-dominated direction', () {
      final ofi = OrderFlowImbalance(
        symbol: 'TSLA',
        buyVolume: 200_000,
        sellVolume: 800_000,
        measuredAt: measured,
      );
      expect(ofi.direction, ImbalanceDirection.sellDominated);
      expect(ofi.isSellDominated, isTrue);
    });

    test('balanced direction when ratio is between 0.45 and 0.55', () {
      final ofi = OrderFlowImbalance(
        symbol: 'SPY',
        buyVolume: 500_000,
        sellVolume: 500_000,
        measuredAt: measured,
      );
      expect(ofi.direction, ImbalanceDirection.balanced);
      expect(ofi.isBalanced, isTrue);
    });

    test('imbalanceRatio is 1.0 when total volume is 0', () {
      final ofi = OrderFlowImbalance(
        symbol: 'X',
        buyVolume: 0,
        sellVolume: 0,
        measuredAt: measured,
      );
      expect(ofi.imbalanceRatio, 1.0);
      expect(ofi.direction, ImbalanceDirection.balanced);
    });

    test('equality holds for identical instances', () {
      final a = OrderFlowImbalance(
        symbol: 'MSFT',
        buyVolume: 400,
        sellVolume: 600,
        measuredAt: measured,
      );
      final b = OrderFlowImbalance(
        symbol: 'MSFT',
        buyVolume: 400,
        sellVolume: 600,
        measuredAt: measured,
      );
      expect(a, equals(b));
    });
  });
}
