import 'package:equatable/equatable.dart';

/// Quiet hours override — per-profile quiet window with bypass mode.
enum QuietHoursMode { enforced, bypassed, scheduled, smart }

class QuietHoursOverride extends Equatable {
  const QuietHoursOverride({
    required this.profileId,
    required this.mode,
    required this.startHour,
    required this.endHour,
    required this.overrideUrgent,
  });

  final String profileId;
  final QuietHoursMode mode;

  /// Start hour in 24-hour format (0–23).
  final int startHour;

  /// End hour in 24-hour format (0–23).
  final int endHour;
  final bool overrideUrgent;

  QuietHoursOverride copyWith({
    String? profileId,
    QuietHoursMode? mode,
    int? startHour,
    int? endHour,
    bool? overrideUrgent,
  }) => QuietHoursOverride(
    profileId: profileId ?? this.profileId,
    mode: mode ?? this.mode,
    startHour: startHour ?? this.startHour,
    endHour: endHour ?? this.endHour,
    overrideUrgent: overrideUrgent ?? this.overrideUrgent,
  );

  @override
  List<Object?> get props => [
    profileId,
    mode,
    startHour,
    endHour,
    overrideUrgent,
  ];
}
