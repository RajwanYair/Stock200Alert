import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PortfolioRebalanceAlert', () {
    PortfolioRebalanceAlert buildAlert({
      RebalanceAlertSeverity severity = RebalanceAlertSeverity.critical,
      double driftPct = 8.0,
    }) => PortfolioRebalanceAlert(
      ticker: 'NVDA',
      severity: severity,
      firedAt: DateTime(2024, 6, 1),
      currentPct: 28.0,
      targetPct: 20.0,
      driftPct: driftPct,
      suggestedActionUsd: 500.0,
    );

    test('isOverweight is true when driftPct > 0', () {
      expect(buildAlert(driftPct: 3.0).isOverweight, isTrue);
    });

    test('isOverweight is false when driftPct < 0', () {
      expect(buildAlert(driftPct: -3.0).isOverweight, isFalse);
    });

    test('isCritical is true for critical severity', () {
      expect(
        buildAlert(severity: RebalanceAlertSeverity.critical).isCritical,
        isTrue,
      );
    });

    test('isCritical is false for warning severity', () {
      expect(
        buildAlert(severity: RebalanceAlertSeverity.warning).isCritical,
        isFalse,
      );
    });

    test('suggestedActionUsd is stored when provided', () {
      expect(buildAlert().suggestedActionUsd, 500.0);
    });

    test('equality holds for same props', () {
      expect(buildAlert(), equals(buildAlert()));
    });
  });
}
