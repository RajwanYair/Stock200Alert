import 'package:equatable/equatable.dart';

/// Type of change recorded in a watchlist audit log entry.
enum WatchlistAuditChangeType {
  /// A ticker was added to the watchlist.
  added,

  /// A ticker was removed from the watchlist.
  removed,

  /// An existing ticker's metadata was edited.
  edited,

  /// The watchlist was renamed.
  renamed,

  /// All tickers were replaced (bulk import).
  bulkReplaced,
}

/// An immutable audit record for a single change to a watchlist.
class WatchlistChangeLog extends Equatable {
  /// Creates a [WatchlistChangeLog].
  const WatchlistChangeLog({
    required this.changeId,
    required this.watchlistId,
    required this.changeType,
    required this.changedAt,
    this.ticker,
    this.detail,
  });

  /// Unique identifier for this change record.
  final String changeId;

  /// ID of the watchlist that was modified.
  final String watchlistId;

  /// Type of change.
  final WatchlistAuditChangeType changeType;

  /// Timestamp when the change occurred.
  final DateTime changedAt;

  /// The affected ticker symbol, if applicable.
  final String? ticker;

  /// Optional human-readable detail string.
  final String? detail;

  /// Returns `true` when this log entry affects a specific ticker.
  bool get isTickerChange =>
      changeType == WatchlistAuditChangeType.added ||
      changeType == WatchlistAuditChangeType.removed ||
      changeType == WatchlistAuditChangeType.edited;

  @override
  List<Object?> get props => [
    changeId,
    watchlistId,
    changeType,
    changedAt,
    ticker,
    detail,
  ];
}
