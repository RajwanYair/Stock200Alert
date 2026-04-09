import 'package:equatable/equatable.dart';

/// A time-of-day window with a measured user-engagement score.
class EngagementTimeWindow extends Equatable {
  const EngagementTimeWindow({
    required this.startHour,
    required this.endHour,
    required this.engagementScore,
  }) : assert(startHour >= 0 && startHour < 24, 'startHour out of range'),
       assert(endHour > startHour && endHour <= 24, 'endHour out of range'),
       assert(
         engagementScore >= 0.0 && engagementScore <= 1.0,
         'engagementScore must be in [0, 1]',
       );

  /// Inclusive start hour (0–23).
  final int startHour;

  /// Exclusive end hour (1–24).
  final int endHour;

  /// Normalised score; 1.0 = highest engagement.
  final double engagementScore;

  bool containsHour(int hour) => hour >= startHour && hour < endHour;

  @override
  List<Object?> get props => [startHour, endHour, engagementScore];
}

/// ML-driven delivery timing model derived from [EngagementTimeWindow] history.
class SmartAlertSchedule extends Equatable {
  const SmartAlertSchedule({
    required this.windows,
    required this.updatedAt,
    this.minDeliveryIntervalMinutes = 15,
  }) : assert(
         minDeliveryIntervalMinutes >= 1,
         'minDeliveryIntervalMinutes must be at least 1',
       );

  final List<EngagementTimeWindow> windows;
  final DateTime updatedAt;

  /// Minimum gap between consecutive alert deliveries.
  final int minDeliveryIntervalMinutes;

  /// Best window overlapping [hour], or `null` if none.
  EngagementTimeWindow? bestWindowForHour(int hour) {
    final matching = windows.where((w) => w.containsHour(hour)).toList()
      ..sort((a, b) => b.engagementScore.compareTo(a.engagementScore));
    return matching.firstOrNull;
  }

  /// `true` if [hour] falls within any window with score ≥ 0.7.
  bool isWithinPeakWindow(int hour) => windows
      .where((w) => w.engagementScore >= 0.7)
      .any((w) => w.containsHour(hour));

  @override
  List<Object?> get props => [windows, updatedAt, minDeliveryIntervalMinutes];
}
