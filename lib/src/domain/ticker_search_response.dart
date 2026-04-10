import 'package:equatable/equatable.dart';

/// A query result entry from the full-text ticker search index.
class TickerQueryResult extends Equatable {
  const TickerQueryResult({
    required this.symbol,
    required this.companyName,
    required this.exchange,
    required this.relevanceScore,
    this.sector,
    this.isActive = true,
  }) : assert(relevanceScore >= 0, 'relevanceScore must be >= 0');

  final String symbol;
  final String companyName;
  final String exchange;

  /// Normalised text-search relevance score (higher = more relevant).
  final double relevanceScore;
  final String? sector;
  final bool isActive;

  bool get hasSector => sector != null && sector!.isNotEmpty;

  @override
  List<Object?> get props => [
    symbol,
    companyName,
    exchange,
    relevanceScore,
    sector,
    isActive,
  ];
}

/// Container for a full-text ticker search query result set.
class TickerSearchResponse extends Equatable {
  const TickerSearchResponse({
    required this.query,
    required this.results,
    required this.executedAt,
    this.totalMatches = 0,
  });

  final String query;
  final List<TickerQueryResult> results;
  final DateTime executedAt;

  /// Total matches in the full index (may exceed results.length if paginated).
  final int totalMatches;

  bool get isEmpty => results.isEmpty;
  int get returnedCount => results.length;
  bool get hasPagination => totalMatches > returnedCount;

  TickerQueryResult? get topResult => results.isEmpty ? null : results.first;

  @override
  List<Object?> get props => [query, results, executedAt, totalMatches];
}
