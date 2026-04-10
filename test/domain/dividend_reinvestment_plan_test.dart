import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DividendReinvestmentPlan', () {
    test(
      'hasFractionalShares is true when fractionalSharesAccumulated > 0',
      () {
        const plan = DividendReinvestmentPlan(
          ticker: 'MSFT',
          isEnabled: true,
          frequency: DripFrequency.quarterly,
          fractionalSharesAccumulated: 0.35,
        );
        expect(plan.hasFractionalShares, isTrue);
      },
    );

    test(
      'hasFractionalShares is false when fractionalSharesAccumulated is 0',
      () {
        const plan = DividendReinvestmentPlan(
          ticker: 'MSFT',
          isEnabled: true,
          frequency: DripFrequency.monthly,
          fractionalSharesAccumulated: 0.0,
        );
        expect(plan.hasFractionalShares, isFalse);
      },
    );

    test('startedAt defaults to null when omitted', () {
      const plan = DividendReinvestmentPlan(
        ticker: 'AAPL',
        isEnabled: false,
        frequency: DripFrequency.annually,
        fractionalSharesAccumulated: 0,
      );
      expect(plan.startedAt, isNull);
    });

    test('minimumCashThreshold is stored when provided', () {
      const plan = DividendReinvestmentPlan(
        ticker: 'VTI',
        isEnabled: true,
        frequency: DripFrequency.thresholdBased,
        fractionalSharesAccumulated: 0,
        minimumCashThreshold: 100.0,
      );
      expect(plan.minimumCashThreshold, 100.0);
    });

    test('equality holds for same props', () {
      const a = DividendReinvestmentPlan(
        ticker: 'VTI',
        isEnabled: true,
        frequency: DripFrequency.quarterly,
        fractionalSharesAccumulated: 1.5,
      );
      const b = DividendReinvestmentPlan(
        ticker: 'VTI',
        isEnabled: true,
        frequency: DripFrequency.quarterly,
        fractionalSharesAccumulated: 1.5,
      );
      expect(a, equals(b));
    });
  });
}
