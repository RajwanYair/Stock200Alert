import 'package:cross_tide/src/domain/sector_heatmap_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const builder = SectorHeatmapBuilder();

  group('SectorHeatmapBuilder', () {
    test('returns empty for no tickers', () {
      expect(builder.build([]), isEmpty);
    });

    test('groups tickers by sector and computes averages', () {
      final result = builder.build(const [
        TickerSectorReturn(ticker: 'AAPL', sector: 'Tech', returnPct: 10),
        TickerSectorReturn(ticker: 'MSFT', sector: 'Tech', returnPct: 8),
        TickerSectorReturn(ticker: 'XOM', sector: 'Energy', returnPct: -3),
      ]);

      expect(result, hasLength(2));
      expect(result.first.sector, 'Tech');
      expect(result.first.averageReturnPct, closeTo(9, 0.01));
      expect(result.first.bestTicker, 'AAPL');
      expect(result.first.worstTicker, 'MSFT');
      expect(result.first.tickerCount, 2);
      expect(result.last.sector, 'Energy');
    });

    test('sorts by average return descending', () {
      final result = builder.build(const [
        TickerSectorReturn(ticker: 'A', sector: 'Low', returnPct: -5),
        TickerSectorReturn(ticker: 'B', sector: 'High', returnPct: 15),
      ]);

      expect(result.first.sector, 'High');
      expect(result.last.sector, 'Low');
    });

    test('SectorHeatmapCell props equality', () {
      const a = SectorHeatmapCell(
        sector: 'Tech',
        tickerCount: 2,
        averageReturnPct: 5,
        bestTicker: 'A',
        worstTicker: 'B',
      );
      const b = SectorHeatmapCell(
        sector: 'Tech',
        tickerCount: 2,
        averageReturnPct: 5,
        bestTicker: 'A',
        worstTicker: 'B',
      );
      expect(a, equals(b));
    });

    test('TickerSectorReturn props equality', () {
      const a = TickerSectorReturn(
        ticker: 'AAPL',
        sector: 'Tech',
        returnPct: 10,
      );
      const b = TickerSectorReturn(
        ticker: 'AAPL',
        sector: 'Tech',
        returnPct: 10,
      );
      expect(a, equals(b));
    });
  });
}
