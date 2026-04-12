import 'package:cross_tide/src/domain/signal_divergence_alert.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SignalDivergenceAlert', () {
    test('equality', () {
      final a = SignalDivergenceAlert(
        ticker: 'MSFT',
        methodName: 'RSI',
        direction: DivergenceDirection.bearish,
        pricePivot: 150.0,
        indicatorPivot: 65.0,
        detectedAt: DateTime(2025, 3, 1),
      );
      final b = SignalDivergenceAlert(
        ticker: 'MSFT',
        methodName: 'RSI',
        direction: DivergenceDirection.bearish,
        pricePivot: 150.0,
        indicatorPivot: 65.0,
        detectedAt: DateTime(2025, 3, 1),
      );
      expect(a, b);
    });

    test('copyWith changes pricePivot', () {
      final base = SignalDivergenceAlert(
        ticker: 'MSFT',
        methodName: 'RSI',
        direction: DivergenceDirection.bearish,
        pricePivot: 150.0,
        indicatorPivot: 65.0,
        detectedAt: DateTime(2025, 3, 1),
      );
      final updated = base.copyWith(pricePivot: 155.0);
      expect(updated.pricePivot, 155.0);
    });

    test('props length is 7', () {
      final obj = SignalDivergenceAlert(
        ticker: 'MSFT',
        methodName: 'RSI',
        direction: DivergenceDirection.bearish,
        pricePivot: 150.0,
        indicatorPivot: 65.0,
        detectedAt: DateTime(2025, 3, 1),
      );
      expect(obj.props.length, 7);
    });
  });
}
