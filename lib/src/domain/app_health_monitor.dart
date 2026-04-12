import 'package:equatable/equatable.dart';

/// Severity level of an in-app health event.
enum HealthEventSeverity { info, warning, critical }

/// A single in-app health monitoring event captured at runtime.
class HealthEvent extends Equatable {
  const HealthEvent({
    required this.component,
    required this.severity,
    required this.message,
    required this.recordedAt,
  });

  final String component;
  final HealthEventSeverity severity;
  final String message;
  final DateTime recordedAt;

  @override
  List<Object?> get props => [component, severity, message, recordedAt];
}

/// Aggregated in-app health monitor that collects runtime health events
/// from all app components.
class AppHealthMonitor extends Equatable {
  const AppHealthMonitor({
    required this.sessionId,
    required this.events,
    required this.overallHealthy,
    required this.capturedAt,
  });

  final String sessionId;
  final List<HealthEvent> events;

  /// `true` when no critical events are present.
  final bool overallHealthy;

  final DateTime capturedAt;

  AppHealthMonitor copyWith({
    String? sessionId,
    List<HealthEvent>? events,
    bool? overallHealthy,
    DateTime? capturedAt,
  }) => AppHealthMonitor(
    sessionId: sessionId ?? this.sessionId,
    events: events ?? this.events,
    overallHealthy: overallHealthy ?? this.overallHealthy,
    capturedAt: capturedAt ?? this.capturedAt,
  );

  @override
  List<Object?> get props => [sessionId, events, overallHealthy, capturedAt];
}
