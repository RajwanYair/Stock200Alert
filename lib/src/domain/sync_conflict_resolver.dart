import 'package:equatable/equatable.dart';

/// Strategy for resolving a sync conflict between local and remote values.
enum ConflictResolutionPolicy {
  lastWriteWins,
  remoteWins,
  localWins,
  mergeByField,
  requireManual,
}

/// Outcome of a conflict resolution attempt.
enum ConflictOutcome { resolved, requiresManual, skipped }

/// A detected conflict between a local and a remote entity value.
class SyncConflict extends Equatable {
  const SyncConflict({
    required this.entityType,
    required this.entityId,
    required this.localValue,
    required this.remoteValue,
    required this.localUpdatedAt,
    required this.remoteUpdatedAt,
  });

  final String entityType;
  final String entityId;
  final String localValue;
  final String remoteValue;
  final DateTime localUpdatedAt;
  final DateTime remoteUpdatedAt;

  bool get localIsNewer => localUpdatedAt.isAfter(remoteUpdatedAt);

  @override
  List<Object?> get props => [
    entityType,
    entityId,
    localValue,
    remoteValue,
    localUpdatedAt,
    remoteUpdatedAt,
  ];
}

/// The result of applying a [ConflictResolutionPolicy] to a [SyncConflict].
class ConflictResolution extends Equatable {
  const ConflictResolution({
    required this.conflict,
    required this.policy,
    required this.outcome,
    required this.resolvedValue,
    required this.resolvedAt,
  });

  final SyncConflict conflict;
  final ConflictResolutionPolicy policy;
  final ConflictOutcome outcome;
  final String resolvedValue;
  final DateTime resolvedAt;

  bool get isResolved => outcome == ConflictOutcome.resolved;

  @override
  List<Object?> get props => [
    conflict,
    policy,
    outcome,
    resolvedValue,
    resolvedAt,
  ];
}

/// Applies a [ConflictResolutionPolicy] to produce a [ConflictResolution].
class SyncConflictResolver extends Equatable {
  const SyncConflictResolver({required this.defaultPolicy});

  final ConflictResolutionPolicy defaultPolicy;

  ConflictResolution resolve(
    SyncConflict conflict, {
    required DateTime resolvedAt,
  }) {
    final String resolved;
    final ConflictOutcome outcome;

    switch (defaultPolicy) {
      case ConflictResolutionPolicy.lastWriteWins:
        resolved = conflict.localIsNewer
            ? conflict.localValue
            : conflict.remoteValue;
        outcome = ConflictOutcome.resolved;
      case ConflictResolutionPolicy.remoteWins:
        resolved = conflict.remoteValue;
        outcome = ConflictOutcome.resolved;
      case ConflictResolutionPolicy.localWins:
        resolved = conflict.localValue;
        outcome = ConflictOutcome.resolved;
      case ConflictResolutionPolicy.requireManual:
      case ConflictResolutionPolicy.mergeByField:
        resolved = conflict.localValue;
        outcome = ConflictOutcome.requiresManual;
    }

    return ConflictResolution(
      conflict: conflict,
      policy: defaultPolicy,
      outcome: outcome,
      resolvedValue: resolved,
      resolvedAt: resolvedAt,
    );
  }

  @override
  List<Object?> get props => [defaultPolicy];
}
