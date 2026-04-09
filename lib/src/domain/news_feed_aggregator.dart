/// News Feed Aggregator — groups `NewsArticle` items into per-ticker feeds
/// with staleness tracking and category filtering (v1.8).
library;

import 'package:equatable/equatable.dart';

import 'news_article.dart';

/// Category filter applied when building a ticker feed.
enum FeedCategory {
  /// Company-specific news (earnings, dividends, M&A).
  companyNews,

  /// Macro / sector-level news.
  marketNews,

  /// Analyst upgrades, downgrades, and price-target changes.
  analystRatings,

  /// Regulatory filings and government announcements.
  regulatory,

  /// All categories (no filter).
  all,
}

/// Filter criteria for constructing a [NewsFeedAggregator].
class FeedFilter extends Equatable {
  const FeedFilter({
    required this.ticker,
    this.category = FeedCategory.all,
    this.maxAgeHours = 48,
    this.maxItems = 50,
  }) : assert(maxAgeHours > 0, 'maxAgeHours must be positive'),
       assert(maxItems > 0, 'maxItems must be positive');

  final String ticker;
  final FeedCategory category;

  /// Only include articles published within this many hours of [now].
  final int maxAgeHours;

  /// Maximum number of articles to include in the resulting feed.
  final int maxItems;

  @override
  List<Object?> get props => [ticker, category, maxAgeHours, maxItems];
}

/// Aggregates [NewsArticle] items that pass a [FeedFilter] into a single feed.
class NewsFeedAggregator extends Equatable {
  const NewsFeedAggregator({
    required this.filter,
    required this.articles,
    required this.aggregatedAt,
  });

  final FeedFilter filter;
  final List<NewsArticle> articles;
  final DateTime aggregatedAt;

  /// Returns true if the feed has no articles.
  bool get isEmpty => articles.isEmpty;

  /// Returns the most recently published article, or null if empty.
  NewsArticle? get latestArticle => articles.isEmpty
      ? null
      : articles.reduce(
          (NewsArticle a, NewsArticle b) =>
              a.publishedAt.isAfter(b.publishedAt) ? a : b,
        );

  /// Returns a filtered list containing only high-relevance articles.
  List<NewsArticle> get highRelevanceArticles =>
      articles.where((NewsArticle a) => a.isHighRelevance).toList();

  @override
  List<Object?> get props => [filter, articles, aggregatedAt];
}
