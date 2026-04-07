/// News Aggregator — domain entities for news/RSS feed items
/// and relevance scoring.
library;

import 'package:equatable/equatable.dart';

/// A single news article or RSS item.
class NewsItem extends Equatable {
  const NewsItem({
    required this.title,
    required this.source,
    required this.publishedAt,
    required this.url,
    this.summary = '',
    this.tickers = const [],
    this.sentiment = NewsSentiment.neutral,
  });

  final String title;
  final String source;
  final DateTime publishedAt;
  final String url;
  final String summary;

  /// Tickers mentioned in this article.
  final List<String> tickers;
  final NewsSentiment sentiment;

  @override
  List<Object?> get props => [
    title,
    source,
    publishedAt,
    url,
    summary,
    tickers,
    sentiment,
  ];
}

/// Sentiment classification for a news article.
enum NewsSentiment { positive, negative, neutral }

/// Relevance-scored news item for a specific ticker.
class ScoredNewsItem extends Equatable {
  const ScoredNewsItem({
    required this.item,
    required this.relevanceScore,
    required this.matchedTicker,
  });

  final NewsItem item;

  /// 0–100 relevance score based on ticker match, recency, source weight.
  final double relevanceScore;
  final String matchedTicker;

  @override
  List<Object?> get props => [item, relevanceScore, matchedTicker];
}

/// News feed summary for a watchlist.
class NewsFeedSummary extends Equatable {
  const NewsFeedSummary({
    required this.totalItems,
    required this.positiveCount,
    required this.negativeCount,
    required this.neutralCount,
    required this.topItems,
  });

  final int totalItems;
  final int positiveCount;
  final int negativeCount;
  final int neutralCount;

  /// Top-ranked items by relevance.
  final List<ScoredNewsItem> topItems;

  @override
  List<Object?> get props => [
    totalItems,
    positiveCount,
    negativeCount,
    neutralCount,
    topItems,
  ];
}

/// Scores and ranks news items by relevance to a watchlist.
class NewsRelevanceScorer {
  const NewsRelevanceScorer();

  /// Score a single news item against a target ticker.
  ScoredNewsItem score({
    required NewsItem item,
    required String ticker,
    required DateTime asOf,
  }) {
    var score = 0.0;

    // Ticker mention: +40
    if (item.tickers.contains(ticker.toUpperCase())) {
      score += 40;
    }

    // Title contains ticker: +20
    if (item.title.toUpperCase().contains(ticker.toUpperCase())) {
      score += 20;
    }

    // Recency: within 1 day +30, 3 days +20, 7 days +10
    final age = asOf.difference(item.publishedAt).inDays;
    if (age <= 1) {
      score += 30;
    } else if (age <= 3) {
      score += 20;
    } else if (age <= 7) {
      score += 10;
    }

    // Sentiment signal: +10 for non-neutral
    if (item.sentiment != NewsSentiment.neutral) {
      score += 10;
    }

    return ScoredNewsItem(
      item: item,
      relevanceScore: score.clamp(0, 100),
      matchedTicker: ticker,
    );
  }

  /// Score and rank all items for a ticker, returning top [limit].
  List<ScoredNewsItem> rankForTicker({
    required List<NewsItem> items,
    required String ticker,
    required DateTime asOf,
    int limit = 10,
  }) {
    final scored =
        items
            .map((NewsItem i) => score(item: i, ticker: ticker, asOf: asOf))
            .where((ScoredNewsItem s) => s.relevanceScore > 0)
            .toList()
          ..sort(
            (ScoredNewsItem a, ScoredNewsItem b) =>
                b.relevanceScore.compareTo(a.relevanceScore),
          );

    return scored.take(limit).toList();
  }

  /// Build a summary across all items.
  NewsFeedSummary summarize(List<ScoredNewsItem> scoredItems) {
    var positive = 0;
    var negative = 0;
    var neutral = 0;

    for (final ScoredNewsItem s in scoredItems) {
      switch (s.item.sentiment) {
        case NewsSentiment.positive:
          positive++;
        case NewsSentiment.negative:
          negative++;
        case NewsSentiment.neutral:
          neutral++;
      }
    }

    return NewsFeedSummary(
      totalItems: scoredItems.length,
      positiveCount: positive,
      negativeCount: negative,
      neutralCount: neutral,
      topItems: scoredItems.take(5).toList(),
    );
  }
}
