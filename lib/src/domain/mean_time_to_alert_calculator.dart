/// Mean Time to Alert Calculator — pure domain logic.
///
/// Computes the average delay between a candle's market date and when
/// the alert was fired. Useful for measuring how quickly the system
/// detects and reports trading signals.
library;

import 'alert_event.dart';

/// Result of the mean-time-to-alert calculation.
class MeanTimeToAlertResult {
  const MeanTimeToAlertResult({
    required this.meanDuration,
    required this.minDuration,
    required this.maxDuration,
    required this.eventCount,
  });

  /// Average time between candle date and alert fire time.
  final Duration meanDuration;

  /// Fastest alert.
  final Duration minDuration;

  /// Slowest alert.
  final Duration maxDuration;

  /// Number of events analysed.
  final int eventCount;
}

/// Computes mean, min, and max time-to-alert from [AlertEvent] data.
class MeanTimeToAlertCalculator {
  const MeanTimeToAlertCalculator();

  /// Calculate time-to-alert statistics.
  ///
  /// [events] is a list of alert events. [candleDateFor] maps each event
  /// to the candle date that triggered it (typically the most recent trading
  /// date at the time the alert was evaluated).
  ///
  /// Returns null when [events] is empty.
  MeanTimeToAlertResult? compute({
    required List<AlertEvent> events,
    required DateTime Function(AlertEvent event) candleDateFor,
  }) {
    if (events.isEmpty) return null;

    Duration minD = const Duration(days: 999999);
    Duration maxD = Duration.zero;
    int totalMicroseconds = 0;

    for (final AlertEvent event in events) {
      final Duration delay = event.firedAt.difference(candleDateFor(event));
      if (delay < minD) minD = delay;
      if (delay > maxD) maxD = delay;
      totalMicroseconds += delay.inMicroseconds;
    }

    return MeanTimeToAlertResult(
      meanDuration: Duration(microseconds: totalMicroseconds ~/ events.length),
      minDuration: minD,
      maxDuration: maxD,
      eventCount: events.length,
    );
  }
}
