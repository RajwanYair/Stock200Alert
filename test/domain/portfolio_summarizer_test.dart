import 'package:cross_tide/src/domain/portfolio_summarizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const summarizer = PortfolioSummarizer();

  group('PortfolioHolding', () {
    test('computes derived fields', () {
      const h = PortfolioHolding(
        ticker: 'AAPL',
        shares: 10,
        averageCost: 100,
        currentPrice: 120,
      );
      expect(h.costBasis, 1000);
      expect(h.marketValue, 1200);
      expect(h.unrealizedPnl, 200);
      expect(h.unrealizedPnlPct, closeTo(20, 0.01));
    });

    test('unrealizedPnlPct returns 0 when costBasis is 0', () {
      const h = PortfolioHolding(
        ticker: 'X',
        shares: 0,
        averageCost: 0,
        currentPrice: 100,
      );
      expect(h.unrealizedPnlPct, 0);
    });

    test('props equality', () {
      const a = PortfolioHolding(
        ticker: 'AAPL',
        shares: 10,
        averageCost: 100,
        currentPrice: 120,
      );
      const b = PortfolioHolding(
        ticker: 'AAPL',
        shares: 10,
        averageCost: 100,
        currentPrice: 120,
      );
      expect(a, equals(b));
    });
  });

  group('PortfolioSummarizer', () {
    test('returns null for empty holdings', () {
      expect(summarizer.summarize([]), isNull);
    });

    test('summarizes single holding', () {
      final result = summarizer.summarize(const [
        PortfolioHolding(
          ticker: 'AAPL',
          shares: 10,
          averageCost: 100,
          currentPrice: 150,
          sector: 'Tech',
        ),
      ]);

      expect(result, isNotNull);
      expect(result!.holdingCount, 1);
      expect(result.totalCost, 1000);
      expect(result.totalValue, 1500);
      expect(result.totalUnrealizedPnl, 500);
      expect(result.totalUnrealizedPnlPct, closeTo(50, 0.01));
      expect(result.topGainer, 'AAPL');
      expect(result.topLoser, 'AAPL');
      expect(result.sectorWeights['Tech'], closeTo(1.0, 0.01));
    });

    test('identifies top gainer and loser', () {
      final result = summarizer.summarize(const [
        PortfolioHolding(
          ticker: 'AAPL',
          shares: 10,
          averageCost: 100,
          currentPrice: 150,
        ),
        PortfolioHolding(
          ticker: 'MSFT',
          shares: 10,
          averageCost: 200,
          currentPrice: 180,
        ),
      ]);

      expect(result!.topGainer, 'AAPL');
      expect(result.topLoser, 'MSFT');
    });

    test('computes sector weights', () {
      final result = summarizer.summarize(const [
        PortfolioHolding(
          ticker: 'AAPL',
          shares: 10,
          averageCost: 100,
          currentPrice: 100,
          sector: 'Tech',
        ),
        PortfolioHolding(
          ticker: 'XOM',
          shares: 10,
          averageCost: 100,
          currentPrice: 100,
          sector: 'Energy',
        ),
      ]);

      expect(result!.sectorWeights['Tech'], closeTo(0.5, 0.01));
      expect(result.sectorWeights['Energy'], closeTo(0.5, 0.01));
    });

    test('PortfolioSummary props equality', () {
      const a = PortfolioSummary(
        totalCost: 100,
        totalValue: 120,
        holdingCount: 1,
        topGainer: 'A',
        topLoser: 'A',
        sectorWeights: {},
      );
      const b = PortfolioSummary(
        totalCost: 100,
        totalValue: 120,
        holdingCount: 1,
        topGainer: 'A',
        topLoser: 'A',
        sectorWeights: {},
      );
      expect(a, equals(b));
    });
  });
}
