import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PortfolioAllocationTarget', () {
    PortfolioAllocationTarget buildTarget({
      double currentPct = 28.0,
      double targetPct = 20.0,
      double maxDriftPct = 5.0,
    }) => PortfolioAllocationTarget(
      ticker: 'AAPL',
      targetPct: targetPct,
      currentPct: currentPct,
      assetClass: 'equity',
      maxDriftPct: maxDriftPct,
    );

    test('drift equals currentPct minus targetPct', () {
      expect(buildTarget().drift, closeTo(8.0, 0.001));
    });

    test('needsRebalance is true when drift exceeds maxDriftPct', () {
      expect(buildTarget().needsRebalance, isTrue);
    });

    test('needsRebalance is false when drift is within maxDriftPct', () {
      expect(
        buildTarget(
          currentPct: 22.0,
          targetPct: 20.0,
          maxDriftPct: 5.0,
        ).needsRebalance,
        isFalse,
      );
    });

    test('isOverweight is true when current > target', () {
      expect(buildTarget().isOverweight, isTrue);
    });

    test('isOverweight is false when current < target', () {
      expect(
        buildTarget(currentPct: 15.0, targetPct: 20.0).isOverweight,
        isFalse,
      );
    });

    test('default maxDriftPct is 5.0', () {
      const t = PortfolioAllocationTarget(
        ticker: 'X',
        targetPct: 10,
        currentPct: 10,
        assetClass: 'equity',
      );
      expect(t.maxDriftPct, 5.0);
    });

    test('equality holds for same props', () {
      expect(buildTarget(), equals(buildTarget()));
    });
  });
}
