/// Notification Channel Ranker — scores and ranks available
/// notification channels by availability, reliability, and user preference.
library;

import 'package:equatable/equatable.dart';

/// Available notification channel types.
enum NotificationChannelType {
  push,
  windowsToast,
  inAppBanner,
  webhook,
  email,
  silentLog,
}

/// Status of a notification channel.
class ChannelStatus extends Equatable {
  const ChannelStatus({
    required this.channel,
    required this.isAvailable,
    required this.reliability,
    required this.lastSuccessAt,
    required this.failureCount,
  });

  final NotificationChannelType channel;
  final bool isAvailable;

  /// 0.0–1.0 success rate over recent attempts.
  final double reliability;
  final DateTime? lastSuccessAt;
  final int failureCount;

  @override
  List<Object?> get props => [
    channel,
    isAvailable,
    reliability,
    lastSuccessAt,
    failureCount,
  ];
}

/// Ranked channel with its computed priority score.
class RankedChannel extends Equatable {
  const RankedChannel({
    required this.channel,
    required this.score,
    required this.rank,
  });

  final NotificationChannelType channel;

  /// 0–100 priority score (higher = try first).
  final double score;
  final int rank;

  @override
  List<Object?> get props => [channel, score, rank];
}

/// Ranks notification channels by availability and reliability.
class NotificationChannelRanker {
  const NotificationChannelRanker();

  /// Base priority per channel type (user preference weighting).
  static const Map<NotificationChannelType, double> _basePriority = {
    NotificationChannelType.push: 90,
    NotificationChannelType.windowsToast: 80,
    NotificationChannelType.inAppBanner: 70,
    NotificationChannelType.webhook: 60,
    NotificationChannelType.email: 50,
    NotificationChannelType.silentLog: 20,
  };

  /// Rank available channels by score.
  ///
  /// Unavailable channels are excluded. Score is:
  /// `basePriority * reliability - failurePenalty`.
  List<RankedChannel> rank(List<ChannelStatus> statuses) {
    final available = statuses
        .where((ChannelStatus s) => s.isAvailable)
        .toList();

    if (available.isEmpty) return [];

    final scored = <(NotificationChannelType, double)>[];
    for (final ChannelStatus s in available) {
      final base = _basePriority[s.channel] ?? 50;
      final failurePenalty = (s.failureCount * 5.0).clamp(0, 40);
      final score = (base * s.reliability - failurePenalty).clamp(0, 100);
      scored.add((s.channel, score.toDouble()));
    }

    scored.sort(
      (
        (NotificationChannelType, double) a,
        (NotificationChannelType, double) b,
      ) => b.$2.compareTo(a.$2),
    );

    return [
      for (var i = 0; i < scored.length; i++)
        RankedChannel(channel: scored[i].$1, score: scored[i].$2, rank: i + 1),
    ];
  }
}
