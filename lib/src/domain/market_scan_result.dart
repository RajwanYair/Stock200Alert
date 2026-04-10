import 'package:equatable/equatable.dart';

/// The outcome status of a single ticker in a market scan.
enum ScanMatchStatus {
  /// All criteria were satisfied.
  matched,

  /// The ticker was excluded by a pre-filter.
  skipped,

  /// The ticker failed one or more criteria.
  rejected,

  /// Data was insufficient to evaluate the ticker.
  dataGap,
}

/// Result record for a single ticker evaluated by a market scan.
class MarketScanResult extends Equatable {
  /// Creates a [MarketScanResult].
  const MarketScanResult({
    required this.ticker,
    required this.status,
    required this.scannedAt,
    required this.score,
    this.matchedCriteria = const [],
    this.failedCriteria = const [],
  });

  /// Ticker symbol evaluated.
  final String ticker;

  /// Outcome of the scan for this ticker.
  final ScanMatchStatus status;

  /// Timestamp of the scan evaluation.
  final DateTime scannedAt;

  /// Composite match score (higher = stronger match).
  final double score;

  /// Criteria keys that were satisfied.
  final List<String> matchedCriteria;

  /// Criteria keys that were not met.
  final List<String> failedCriteria;

  /// Returns `true` when this ticker fully matched all scan criteria.
  bool get isMatch => status == ScanMatchStatus.matched;

  /// Number of criteria passed.
  int get passCount => matchedCriteria.length;

  @override
  List<Object?> get props => [
    ticker,
    status,
    scannedAt,
    score,
    matchedCriteria,
    failedCriteria,
  ];
}
