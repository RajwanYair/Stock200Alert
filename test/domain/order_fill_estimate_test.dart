import 'package:cross_tide/src/domain/order_fill_estimate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderFillEstimate', () {
    test('equality', () {
      const a = OrderFillEstimate(
        orderId: 'ord-1',
        ticker: 'AAPL',
        estimatedFillPct: 98.5,
        estimatedSlippageBps: 3.2,
        confidence: FillConfidenceLevel.high,
      );
      const b = OrderFillEstimate(
        orderId: 'ord-1',
        ticker: 'AAPL',
        estimatedFillPct: 98.5,
        estimatedSlippageBps: 3.2,
        confidence: FillConfidenceLevel.high,
      );
      expect(a, b);
    });

    test('copyWith changes estimatedFillPct', () {
      const base = OrderFillEstimate(
        orderId: 'ord-1',
        ticker: 'AAPL',
        estimatedFillPct: 98.5,
        estimatedSlippageBps: 3.2,
        confidence: FillConfidenceLevel.high,
      );
      final updated = base.copyWith(estimatedFillPct: 99.0);
      expect(updated.estimatedFillPct, 99.0);
    });

    test('props length is 5', () {
      const obj = OrderFillEstimate(
        orderId: 'ord-1',
        ticker: 'AAPL',
        estimatedFillPct: 98.5,
        estimatedSlippageBps: 3.2,
        confidence: FillConfidenceLevel.high,
      );
      expect(obj.props.length, 5);
    });
  });
}
