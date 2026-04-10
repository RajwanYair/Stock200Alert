import 'package:equatable/equatable.dart';

/// A single line in an audit trail log.
class SystemAuditEntry extends Equatable {
  const SystemAuditEntry({
    required this.entryId,
    required this.action,
    required this.actorId,
    required this.timestamp,
    this.targetEntityType,
    this.targetEntityId,
    this.metadata = const {},
    this.isSystemAction = false,
  });

  final String entryId;

  /// Short verb describing the action performed (e.g. 'ticker.add', 'alert.fired').
  final String action;
  final String actorId;
  final DateTime timestamp;
  final String? targetEntityType;
  final String? targetEntityId;

  /// Arbitrary string metadata about the action.
  final Map<String, String> metadata;

  /// Whether the action was triggered by the system (vs. user).
  final bool isSystemAction;

  bool get hasTarget => targetEntityType != null;
  bool get hasMetadata => metadata.isNotEmpty;

  @override
  List<Object?> get props => [
    entryId,
    action,
    actorId,
    timestamp,
    targetEntityType,
    targetEntityId,
    metadata,
    isSystemAction,
  ];
}
