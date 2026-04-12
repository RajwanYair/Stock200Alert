import 'package:equatable/equatable.dart';

/// Notification badge state for a specific app section (S488).
class AppNotificationBadge extends Equatable {
  const AppNotificationBadge({
    required this.badgeId,
    required this.section,
    required this.count,
    this.isVisible = true,
    this.isPriority = false,
  });

  final String badgeId;

  /// The app section to which this badge applies (e.g. 'watchlist', 'alerts').
  final String section;

  /// Number of unread/pending items.
  final int count;
  final bool isVisible;
  final bool isPriority;

  bool get hasItems => count > 0;
  bool get isHighCount => count >= 10;
  bool get shouldDisplay => isVisible && hasItems;

  @override
  List<Object?> get props => [badgeId, section, count, isVisible, isPriority];
}
