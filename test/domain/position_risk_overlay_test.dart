import 'package:cross_tide/src/domain/position_risk_overlay.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PositionRiskOverlay', () {
    test('equality', () {
      const a = PositionRiskOverlay(
        ticker: 'AAPL',
        overlayType: RiskOverlayType.stopLoss,
        triggerPrice: 180.0,
        currentPrice: 195.0,
        isActive: true,
      );
      const b = PositionRiskOverlay(
        ticker: 'AAPL',
        overlayType: RiskOverlayType.stopLoss,
        triggerPrice: 180.0,
        currentPrice: 195.0,
        isActive: true,
      );
      expect(a, b);
    });

    test('copyWith changes isActive', () {
      const base = PositionRiskOverlay(
        ticker: 'AAPL',
        overlayType: RiskOverlayType.stopLoss,
        triggerPrice: 180.0,
        currentPrice: 195.0,
        isActive: true,
      );
      final updated = base.copyWith(isActive: false);
      expect(updated.isActive, false);
    });

    test('props length is 5', () {
      const obj = PositionRiskOverlay(
        ticker: 'AAPL',
        overlayType: RiskOverlayType.stopLoss,
        triggerPrice: 180.0,
        currentPrice: 195.0,
        isActive: true,
      );
      expect(obj.props.length, 5);
    });
  });
}
