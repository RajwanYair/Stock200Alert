import 'package:cross_tide/src/domain/market_ticker_alias.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MarketTickerAlias', () {
    test('equality', () {
      const a = MarketTickerAlias(
        primaryTicker: 'AAPL',
        alias: 'US0378331005',
        aliasSource: TickerAliasSource.isin,
        exchange: 'NASDAQ',
        isActive: true,
      );
      const b = MarketTickerAlias(
        primaryTicker: 'AAPL',
        alias: 'US0378331005',
        aliasSource: TickerAliasSource.isin,
        exchange: 'NASDAQ',
        isActive: true,
      );
      expect(a, b);
    });

    test('copyWith changes isActive', () {
      const base = MarketTickerAlias(
        primaryTicker: 'AAPL',
        alias: 'US0378331005',
        aliasSource: TickerAliasSource.isin,
        exchange: 'NASDAQ',
        isActive: true,
      );
      final updated = base.copyWith(isActive: false);
      expect(updated.isActive, false);
    });

    test('props length is 5', () {
      const obj = MarketTickerAlias(
        primaryTicker: 'AAPL',
        alias: 'US0378331005',
        aliasSource: TickerAliasSource.isin,
        exchange: 'NASDAQ',
        isActive: true,
      );
      expect(obj.props.length, 5);
    });
  });
}
