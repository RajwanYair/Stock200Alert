import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PaperTradeOrder', () {
    late DateTime createdAt;

    setUp(() {
      createdAt = DateTime(2025, 6, 1, 10);
    });

    test('creates pending buy order', () {
      final order = PaperTradeOrder(
        orderId: 'ord-001',
        symbol: 'AAPL',
        side: PaperTradeSide.buy,
        quantity: 10,
        limitPrice: 190.0,
        createdAt: createdAt,
      );
      expect(order.status, PaperTradeStatus.pending);
      expect(order.isBuy, isTrue);
      expect(order.isSell, isFalse);
      expect(order.isPending, isTrue);
      expect(order.isFilled, isFalse);
      expect(order.fillPrice, isNull);
      expect(order.notionalValue, isNull);
    });

    test('fill() returns filled order', () {
      final order = PaperTradeOrder(
        orderId: 'ord-002',
        symbol: 'MSFT',
        side: PaperTradeSide.buy,
        quantity: 5,
        limitPrice: 400.0,
        createdAt: createdAt,
      );
      final filled = order.fill(atPrice: 401.5, at: DateTime(2025, 6, 1, 11));
      expect(filled.isFilled, isTrue);
      expect(filled.fillPrice, 401.5);
      expect(filled.status, PaperTradeStatus.filled);
    });

    test('slippage is positive for adverse fill on buy', () {
      final order = PaperTradeOrder(
        orderId: 'ord-003',
        symbol: 'NVDA',
        side: PaperTradeSide.buy,
        quantity: 2,
        limitPrice: 500.0,
        createdAt: createdAt,
      ).fill(atPrice: 505.0, at: DateTime(2025, 6, 2));
      expect(order.slippage, closeTo(5.0, 0.001));
    });

    test('slippage is positive for adverse fill on sell', () {
      final order = PaperTradeOrder(
        orderId: 'ord-004',
        symbol: 'TSLA',
        side: PaperTradeSide.sell,
        quantity: 3,
        limitPrice: 250.0,
        createdAt: createdAt,
      ).fill(atPrice: 245.0, at: DateTime(2025, 6, 2));
      expect(order.slippage, closeTo(5.0, 0.001));
    });

    test('notionalValue computed on filled order', () {
      final order = PaperTradeOrder(
        orderId: 'ord-005',
        symbol: 'AMZN',
        side: PaperTradeSide.buy,
        quantity: 4,
        limitPrice: 200.0,
        createdAt: createdAt,
      ).fill(atPrice: 202.0, at: DateTime(2025, 6, 3));
      expect(order.notionalValue, closeTo(808.0, 0.001));
    });

    test('slippage null when order not filled', () {
      final order = PaperTradeOrder(
        orderId: 'ord-006',
        symbol: 'GOOG',
        side: PaperTradeSide.buy,
        quantity: 1,
        limitPrice: 100.0,
        createdAt: createdAt,
      );
      expect(order.slippage, isNull);
    });

    test('equality holds for identical orders', () {
      final a = PaperTradeOrder(
        orderId: 'x',
        symbol: 'SPY',
        side: PaperTradeSide.sell,
        quantity: 1,
        limitPrice: 450.0,
        createdAt: createdAt,
      );
      final b = PaperTradeOrder(
        orderId: 'x',
        symbol: 'SPY',
        side: PaperTradeSide.sell,
        quantity: 1,
        limitPrice: 450.0,
        createdAt: createdAt,
      );
      expect(a, equals(b));
    });
  });
}
