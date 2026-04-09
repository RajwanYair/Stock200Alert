/// Community Watchlist Subscription — tracks a user's subscription to a
/// community-curated watchlist (v1.8).
library;

import 'package:equatable/equatable.dart';

/// The current state of a community watchlist subscription.
enum SubscriptionState {
  /// User is actively subscribed and receiving updates.
  active,

  /// User has paused updates without unsubscribing.
  paused,

  /// User has unsubscribed; the watchlist may still be cached locally.
  unsubscribed,

  /// Subscription is pending moderator or system approval.
  pendingApproval,
}

/// Records a user's subscription to one community-curated watchlist.
class CommunityWatchlistSubscription extends Equatable {
  const CommunityWatchlistSubscription({
    required this.subscriptionId,
    required this.watchlistId,
    required this.watchlistName,
    required this.subscribedAt,
    required this.state,
    this.lastSyncedAt,
    this.autoFollow = true,
  });

  final String subscriptionId;
  final String watchlistId;
  final String watchlistName;
  final DateTime subscribedAt;
  final SubscriptionState state;

  /// When the local cache was last refreshed from the community source.
  final DateTime? lastSyncedAt;

  /// If true, new tickers added to the community watchlist are automatically
  /// added to the user's watchlist.
  final bool autoFollow;

  bool get isActive => state == SubscriptionState.active;

  /// Returns a copy with [state] set to [SubscriptionState.paused].
  CommunityWatchlistSubscription pause() => CommunityWatchlistSubscription(
    subscriptionId: subscriptionId,
    watchlistId: watchlistId,
    watchlistName: watchlistName,
    subscribedAt: subscribedAt,
    state: SubscriptionState.paused,
    lastSyncedAt: lastSyncedAt,
    autoFollow: autoFollow,
  );

  /// Returns a copy with [lastSyncedAt] updated to [syncedAt].
  CommunityWatchlistSubscription markSynced(DateTime syncedAt) =>
      CommunityWatchlistSubscription(
        subscriptionId: subscriptionId,
        watchlistId: watchlistId,
        watchlistName: watchlistName,
        subscribedAt: subscribedAt,
        state: state,
        lastSyncedAt: syncedAt,
        autoFollow: autoFollow,
      );

  @override
  List<Object?> get props => [
    subscriptionId,
    watchlistId,
    watchlistName,
    subscribedAt,
    state,
    lastSyncedAt,
    autoFollow,
  ];
}
