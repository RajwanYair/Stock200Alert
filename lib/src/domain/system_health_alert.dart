import 'package:equatable/equatable.dart';

/// Severity level of a system health alert.
enum HealthAlertSeverity { info, warning, error, critical }

/// Category of component that raised the health alert.
enum HealthAlertCategory {
  database,
  network,
  dataFeed,
  backgroundTask,
  notification,
  storage,
  auth,
}

/// A system health alert raised by an internal component.
class SystemHealthAlert extends Equatable {
  const SystemHealthAlert({
    required this.alertId,
    required this.category,
    required this.severity,
    required this.message,
    required this.raisedAt,
    this.isResolved = false,
    this.resolvedAt,
    this.componentName,
  });

  final String alertId;
  final HealthAlertCategory category;
  final HealthAlertSeverity severity;
  final String message;
  final DateTime raisedAt;
  final bool isResolved;
  final DateTime? resolvedAt;
  final String? componentName;

  bool get isCritical => severity == HealthAlertSeverity.critical;
  bool get isError => severity == HealthAlertSeverity.error;
  bool get requiresAttention =>
      severity == HealthAlertSeverity.error ||
      severity == HealthAlertSeverity.critical;

  Duration? get resolutionTime {
    if (resolvedAt == null) return null;
    return resolvedAt!.difference(raisedAt);
  }

  SystemHealthAlert resolve(DateTime at) => SystemHealthAlert(
    alertId: alertId,
    category: category,
    severity: severity,
    message: message,
    raisedAt: raisedAt,
    isResolved: true,
    resolvedAt: at,
    componentName: componentName,
  );

  @override
  List<Object?> get props => [
    alertId,
    category,
    severity,
    message,
    raisedAt,
    isResolved,
    resolvedAt,
    componentName,
  ];
}
