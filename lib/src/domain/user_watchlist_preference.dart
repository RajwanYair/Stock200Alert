import 'package:equatable/equatable.dart';

/// Default display and notification preferences per watchlist (S465).
class UserWatchlistPreference extends Equatable {
  const UserWatchlistPreference({
    required this.userId,
    required this.watchlistId,
    required this.defaultSortField,
    this.showPercentChange = true,
    this.showVolume = false,
    this.showAlertBadge = true,
    this.notificationsEnabled = true,
    this.compactView = false,
  });

  final String userId;
  final String watchlistId;
  final String defaultSortField;
  final bool showPercentChange;
  final bool showVolume;
  final bool showAlertBadge;
  final bool notificationsEnabled;
  final bool compactView;

  bool get hasCustomDisplay => !showPercentChange || showVolume || compactView;
  bool get isFullyEnabled => notificationsEnabled && showAlertBadge;

  @override
  List<Object?> get props => [
    userId,
    watchlistId,
    defaultSortField,
    showPercentChange,
    showVolume,
    showAlertBadge,
    notificationsEnabled,
    compactView,
  ];
}
