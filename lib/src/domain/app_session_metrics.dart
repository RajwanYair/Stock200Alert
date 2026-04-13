import 'package:equatable/equatable.dart';

/// App session metrics — engagement and interaction counts per session.
enum SessionEngagementLevel { low, medium, high, power }

class AppSessionMetrics extends Equatable {
  const AppSessionMetrics({
    required this.sessionId,
    required this.pageViews,
    required this.interactionCount,
    required this.engagementLevel,
    required this.durationSeconds,
  });

  final String sessionId;
  final int pageViews;
  final int interactionCount;
  final SessionEngagementLevel engagementLevel;
  final int durationSeconds;

  AppSessionMetrics copyWith({
    String? sessionId,
    int? pageViews,
    int? interactionCount,
    SessionEngagementLevel? engagementLevel,
    int? durationSeconds,
  }) => AppSessionMetrics(
    sessionId: sessionId ?? this.sessionId,
    pageViews: pageViews ?? this.pageViews,
    interactionCount: interactionCount ?? this.interactionCount,
    engagementLevel: engagementLevel ?? this.engagementLevel,
    durationSeconds: durationSeconds ?? this.durationSeconds,
  );

  @override
  List<Object?> get props => [
    sessionId,
    pageViews,
    interactionCount,
    engagementLevel,
    durationSeconds,
  ];
}
