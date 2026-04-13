import 'package:cross_tide/src/domain/ticker_price_history.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TickerPriceHistory', () {
    test('equality', () {
      const a = TickerPriceHistory(
        ticker: 'AAPL',
        granularity: PriceHistoryGranularity.daily,
        fromDate: '2024-01-01',
        toDate: '2025-01-01',
        candleCount: 252,
      );
      const b = TickerPriceHistory(
        ticker: 'AAPL',
        granularity: PriceHistoryGranularity.daily,
        fromDate: '2024-01-01',
        toDate: '2025-01-01',
        candleCount: 252,
      );
      expect(a, b);
    });

    test('copyWith changes candleCount', () {
      const base = TickerPriceHistory(
        ticker: 'AAPL',
        granularity: PriceHistoryGranularity.daily,
        fromDate: '2024-01-01',
        toDate: '2025-01-01',
        candleCount: 252,
      );
      final updated = base.copyWith(candleCount: 253);
      expect(updated.candleCount, 253);
    });

    test('props length is 5', () {
      const obj = TickerPriceHistory(
        ticker: 'AAPL',
        granularity: PriceHistoryGranularity.daily,
        fromDate: '2024-01-01',
        toDate: '2025-01-01',
        candleCount: 252,
      );
      expect(obj.props.length, 5);
    });
  });
}
