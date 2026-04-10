import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MultiCurrencyPosition', () {
    MultiCurrencyPosition buildPosition({
      double nativeMarketValue = 1000.0,
      double nativeCostBasis = 800.0,
      double fxRate = 1.25,
    }) => MultiCurrencyPosition(
      ticker: 'SHEL',
      nativeCurrency: 'GBP',
      baseCurrency: 'USD',
      nativeMarketValue: nativeMarketValue,
      fxRate: fxRate,
      updatedAt: DateTime(2024, 6, 1),
      quantity: 10,
      nativeCostBasis: nativeCostBasis,
    );

    test('baseMarketValue equals nativeMarketValue * fxRate', () {
      expect(buildPosition().baseMarketValue, closeTo(1250.0, 0.01));
    });

    test('baseCostBasis equals nativeCostBasis * fxRate', () {
      expect(buildPosition().baseCostBasis, closeTo(1000.0, 0.01));
    });

    test('unrealisedPnlBase = baseMarketValue - baseCostBasis', () {
      expect(buildPosition().unrealisedPnlBase, closeTo(250.0, 0.01));
    });

    test('isProfitable is true when unrealisedPnlBase > 0', () {
      expect(buildPosition().isProfitable, isTrue);
    });

    test('isProfitable is false when cost basis exceeds market value', () {
      expect(
        buildPosition(
          nativeMarketValue: 600.0,
          nativeCostBasis: 800.0,
        ).isProfitable,
        isFalse,
      );
    });

    test('equality holds for same props', () {
      expect(buildPosition(), equals(buildPosition()));
    });
  });
}
