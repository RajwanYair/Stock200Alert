import 'package:equatable/equatable.dart';

/// Curation style for auto-managing a watchlist.
enum CurationStyle {
  /// Add tickers entering user-defined criteria; never remove.
  addOnly,

  /// Remove tickers that no longer meet criteria.
  pruneOnly,

  /// Both add qualifying and remove non-qualifying tickers.
  fullCuration,

  /// Manual — no automatic changes.
  manual,
}

/// Profile describing how a watchlist is curated automatically.
class WatchlistCuratorProfile extends Equatable {
  const WatchlistCuratorProfile({
    required this.profileId,
    required this.watchlistId,
    required this.curationStyle,
    required this.maxSize,
    required this.lastCuratedAt,
    this.filterTagKeys = const [],
    this.isEnabled = true,
  });

  final String profileId;
  final String watchlistId;
  final CurationStyle curationStyle;

  /// Maximum number of tickers in the curated watchlist.
  final int maxSize;

  final DateTime lastCuratedAt;

  /// Tag keys used to filter eligible tickers.
  final List<String> filterTagKeys;

  final bool isEnabled;

  /// Returns true when automatic curation makes changes to the watchlist.
  bool get isActive => isEnabled && curationStyle != CurationStyle.manual;

  @override
  List<Object?> get props => [
    profileId,
    watchlistId,
    curationStyle,
    maxSize,
    lastCuratedAt,
    filterTagKeys,
    isEnabled,
  ];
}
