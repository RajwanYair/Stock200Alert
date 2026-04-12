import 'package:cross_tide/src/domain/technical_alert_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TechnicalAlertSummary', () {
    test('equality', () {
      final a = TechnicalAlertSummary(
        ticker: 'NVDA',
        activeBuyAlerts: 3,
        activeSellAlerts: 1,
        methodNames: const ['Micho', 'RSI', 'MACD'],
        consensusBuy: true,
        consensusSell: false,
        summarisedAt: DateTime(2025, 11, 1),
      );
      final b = TechnicalAlertSummary(
        ticker: 'NVDA',
        activeBuyAlerts: 3,
        activeSellAlerts: 1,
        methodNames: const ['Micho', 'RSI', 'MACD'],
        consensusBuy: true,
        consensusSell: false,
        summarisedAt: DateTime(2025, 11, 1),
      );
      expect(a, b);
    });

    test('copyWith changes activeBuyAlerts', () {
      final base = TechnicalAlertSummary(
        ticker: 'NVDA',
        activeBuyAlerts: 3,
        activeSellAlerts: 1,
        methodNames: const ['Micho', 'RSI', 'MACD'],
        consensusBuy: true,
        consensusSell: false,
        summarisedAt: DateTime(2025, 11, 1),
      );
      final updated = base.copyWith(activeBuyAlerts: 4);
      expect(updated.activeBuyAlerts, 4);
    });

    test('props length is 7', () {
      final obj = TechnicalAlertSummary(
        ticker: 'NVDA',
        activeBuyAlerts: 3,
        activeSellAlerts: 1,
        methodNames: const ['Micho', 'RSI', 'MACD'],
        consensusBuy: true,
        consensusSell: false,
        summarisedAt: DateTime(2025, 11, 1),
      );
      expect(obj.props.length, 7);
    });
  });
}
