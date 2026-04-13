import 'package:cross_tide/src/domain/cross_market_arbitrage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CrossMarketArbitrage', () {
    test('equality', () {
      const a = CrossMarketArbitrage(
        ticker: 'AAPL',
        exchange1: 'NASDAQ',
        exchange2: 'LSE',
        spreadPercent: 0.12,
        direction: ArbitrageDirection.longLeg,
      );
      const b = CrossMarketArbitrage(
        ticker: 'AAPL',
        exchange1: 'NASDAQ',
        exchange2: 'LSE',
        spreadPercent: 0.12,
        direction: ArbitrageDirection.longLeg,
      );
      expect(a, b);
    });

    test('copyWith changes spreadPercent', () {
      const base = CrossMarketArbitrage(
        ticker: 'AAPL',
        exchange1: 'NASDAQ',
        exchange2: 'LSE',
        spreadPercent: 0.12,
        direction: ArbitrageDirection.longLeg,
      );
      final updated = base.copyWith(spreadPercent: 0.15);
      expect(updated.spreadPercent, 0.15);
    });

    test('props length is 5', () {
      const obj = CrossMarketArbitrage(
        ticker: 'AAPL',
        exchange1: 'NASDAQ',
        exchange2: 'LSE',
        spreadPercent: 0.12,
        direction: ArbitrageDirection.longLeg,
      );
      expect(obj.props.length, 5);
    });
  });
}
