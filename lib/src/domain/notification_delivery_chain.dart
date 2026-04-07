/// Notification Delivery Chain — pure domain utility.
///
/// Models an ordered sequence of delivery channels that are attempted in
/// order. If a higher-priority channel is muted/disabled, the chain falls
/// through to the next.
library;

import 'package:equatable/equatable.dart';

import 'notification_preference.dart';

/// Outcome of attempting delivery through a single channel.
enum DeliveryOutcome {
  /// Notification was delivered.
  delivered,

  /// Channel was skipped (muted, disabled, etc.).
  skipped,

  /// Delivery failed (error).
  failed,
}

/// Result of a single delivery attempt.
class DeliveryAttempt extends Equatable {
  const DeliveryAttempt({
    required this.channel,
    required this.outcome,
    this.reason,
  });

  /// The channel that was tried.
  final NotificationChannel channel;

  /// Result of the attempt.
  final DeliveryOutcome outcome;

  /// Optional human-readable reason for skip/failure.
  final String? reason;

  @override
  List<Object?> get props => [channel, outcome, reason];
}

/// Result of running the full delivery chain.
class DeliveryChainResult extends Equatable {
  const DeliveryChainResult({required this.attempts});

  /// All attempts in order.
  final List<DeliveryAttempt> attempts;

  /// Whether at least one channel delivered successfully.
  bool get wasDelivered => attempts.any(
    (DeliveryAttempt a) => a.outcome == DeliveryOutcome.delivered,
  );

  /// The channel that ultimately delivered, or null if none did.
  NotificationChannel? get deliveredVia {
    for (final DeliveryAttempt a in attempts) {
      if (a.outcome == DeliveryOutcome.delivered) return a.channel;
    }
    return null;
  }

  @override
  List<Object?> get props => [attempts];
}

/// Evaluates delivery through an ordered list of channels.
///
/// Pure domain logic — does **not** actually send notifications.
/// Returns which channel *should* be used and the chain trace.
class NotificationDeliveryChain {
  const NotificationDeliveryChain({
    this.channelOrder = const [
      NotificationChannel.push,
      NotificationChannel.inApp,
      NotificationChannel.silent,
    ],
  });

  /// Ordered list of channels to attempt.
  final List<NotificationChannel> channelOrder;

  /// Evaluate the chain for [pref] at [now].
  ///
  /// Skips muted channels and returns the trace of attempts.
  DeliveryChainResult evaluate(
    NotificationPreference pref, {
    required DateTime now,
    Set<NotificationChannel> disabledChannels = const {},
  }) {
    final List<DeliveryAttempt> attempts = [];
    for (final NotificationChannel ch in channelOrder) {
      if (disabledChannels.contains(ch)) {
        attempts.add(
          DeliveryAttempt(
            channel: ch,
            outcome: DeliveryOutcome.skipped,
            reason: 'Channel disabled',
          ),
        );
        continue;
      }
      if (pref.isMuted(now)) {
        attempts.add(
          DeliveryAttempt(
            channel: ch,
            outcome: DeliveryOutcome.skipped,
            reason: 'Muted until ${pref.mutedUntil}',
          ),
        );
        continue;
      }
      // First available channel delivers.
      attempts.add(
        DeliveryAttempt(channel: ch, outcome: DeliveryOutcome.delivered),
      );
      return DeliveryChainResult(attempts: attempts);
    }
    return DeliveryChainResult(attempts: attempts);
  }
}
