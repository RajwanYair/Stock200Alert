import 'package:cross_tide/src/domain/price_alert_history.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PriceAlertHistory', () {
    test('equality', () {
      final a = PriceAlertHistory(
        alertId: 'al-1',
        ticker: 'AAPL',
        triggerType: PriceAlertTriggerType.crossAbove,
        triggeredPrice: 200.0,
        triggeredAt: DateTime(2025, 1, 15),
      );
      final b = PriceAlertHistory(
        alertId: 'al-1',
        ticker: 'AAPL',
        triggerType: PriceAlertTriggerType.crossAbove,
        triggeredPrice: 200.0,
        triggeredAt: DateTime(2025, 1, 15),
      );
      expect(a, b);
    });

    test('copyWith changes triggeredPrice', () {
      final base = PriceAlertHistory(
        alertId: 'al-1',
        ticker: 'AAPL',
        triggerType: PriceAlertTriggerType.crossAbove,
        triggeredPrice: 200.0,
        triggeredAt: DateTime(2025, 1, 15),
      );
      final updated = base.copyWith(triggeredPrice: 205.0);
      expect(updated.triggeredPrice, 205.0);
    });

    test('props length is 5', () {
      final obj = PriceAlertHistory(
        alertId: 'al-1',
        ticker: 'AAPL',
        triggerType: PriceAlertTriggerType.crossAbove,
        triggeredPrice: 200.0,
        triggeredAt: DateTime(2025, 1, 15),
      );
      expect(obj.props.length, 5);
    });
  });
}
