import 'package:cross_tide/src/domain/news_relevance_scorer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const scorer = NewsRelevanceScorer();

  final now = DateTime(2025, 4, 7, 12, 0);

  group('NewsRelevanceScorer.score', () {
    test('boosts score for ticker in tickers list and title', () {
      final item = NewsItem(
        title: 'AAPL beats earnings',
        source: 'Yahoo',
        publishedAt: now.subtract(const Duration(hours: 1)),
        url: 'https://example.com/1',
        tickers: const ['AAPL'],
        sentiment: NewsSentiment.positive,
      );

      final scored = scorer.score(item: item, ticker: 'AAPL', asOf: now);
      // ticker match (+40) + title match (+20) + recency <=1day (+30) +
      // sentiment (+10) = 100
      expect(scored.relevanceScore, closeTo(100, 1));
    });

    test('title-only mention is worth less than title+ticker list', () {
      final withTicker = NewsItem(
        title: 'AAPL surges',
        source: 'Reuters',
        publishedAt: now,
        url: 'https://example.com/1',
        tickers: const ['AAPL'],
        sentiment: NewsSentiment.positive,
      );
      final titleOnly = NewsItem(
        title: 'AAPL surges',
        source: 'Reuters',
        publishedAt: now,
        url: 'https://example.com/2',
        sentiment: NewsSentiment.positive,
      );

      final withScore = scorer.score(
        item: withTicker,
        ticker: 'AAPL',
        asOf: now,
      );
      final titleScore = scorer.score(
        item: titleOnly,
        ticker: 'AAPL',
        asOf: now,
      );
      expect(withScore.relevanceScore, greaterThan(titleScore.relevanceScore));
    });

    test('matchedTicker records the target ticker', () {
      final item = NewsItem(
        title: 'Tech rally',
        source: 'Bloomberg',
        publishedAt: now,
        url: 'https://example.com/3',
        tickers: const ['AAPL'],
      );

      final scored = scorer.score(item: item, ticker: 'AAPL', asOf: now);
      expect(scored.matchedTicker, 'AAPL');
    });

    test('old news gets lower recency bonus', () {
      final recent = NewsItem(
        title: 'AAPL news',
        source: 'X',
        publishedAt: now.subtract(const Duration(hours: 1)),
        url: 'https://e.com/1',
        tickers: const ['AAPL'],
      );
      final old = NewsItem(
        title: 'AAPL news',
        source: 'X',
        publishedAt: now.subtract(const Duration(days: 5)),
        url: 'https://e.com/2',
        tickers: const ['AAPL'],
      );

      final recentScore = scorer.score(item: recent, ticker: 'AAPL', asOf: now);
      final oldScore = scorer.score(item: old, ticker: 'AAPL', asOf: now);
      expect(recentScore.relevanceScore, greaterThan(oldScore.relevanceScore));
    });
  });

  group('NewsRelevanceScorer.rankForTicker', () {
    test('ranks items by relevance descending', () {
      final items = [
        NewsItem(
          title: 'Tech roundup',
          source: 'A',
          publishedAt: now.subtract(const Duration(days: 3)),
          url: 'https://e.com/1',
        ),
        NewsItem(
          title: 'AAPL breaks records',
          source: 'B',
          publishedAt: now.subtract(const Duration(hours: 1)),
          url: 'https://e.com/2',
          tickers: const ['AAPL'],
          sentiment: NewsSentiment.positive,
        ),
      ];

      final ranked = scorer.rankForTicker(
        items: items,
        ticker: 'AAPL',
        asOf: now,
      );
      expect(ranked.first.item.title, 'AAPL breaks records');
    });
  });

  group('NewsRelevanceScorer.summarize', () {
    test('returns summary with sentiment counts', () {
      final scored = [
        ScoredNewsItem(
          item: NewsItem(
            title: 'A',
            source: 'A',
            publishedAt: now,
            url: 'https://e.com/1',
            sentiment: NewsSentiment.positive,
          ),
          relevanceScore: 80,
          matchedTicker: 'AAPL',
        ),
        ScoredNewsItem(
          item: NewsItem(
            title: 'B',
            source: 'B',
            publishedAt: now,
            url: 'https://e.com/2',
            sentiment: NewsSentiment.negative,
          ),
          relevanceScore: 60,
          matchedTicker: 'AAPL',
        ),
      ];

      final summary = scorer.summarize(scored);
      expect(summary.totalItems, 2);
      expect(summary.positiveCount, 1);
      expect(summary.negativeCount, 1);
      expect(summary.neutralCount, 0);
    });
  });

  group('NewsItem props equality', () {
    test('equal instances match', () {
      final a = NewsItem(
        title: 'T',
        source: 'S',
        publishedAt: DateTime(2025, 1, 1),
        url: 'https://e.com',
      );
      final b = NewsItem(
        title: 'T',
        source: 'S',
        publishedAt: DateTime(2025, 1, 1),
        url: 'https://e.com',
      );
      expect(a, equals(b));
    });
  });

  group('ScoredNewsItem props equality', () {
    test('equal instances match', () {
      final item = NewsItem(
        title: 'T',
        source: 'S',
        publishedAt: DateTime(2025, 1, 1),
        url: 'https://e.com',
      );
      final a = ScoredNewsItem(
        item: item,
        relevanceScore: 50,
        matchedTicker: 'X',
      );
      final b = ScoredNewsItem(
        item: item,
        relevanceScore: 50,
        matchedTicker: 'X',
      );
      expect(a, equals(b));
    });
  });
}
