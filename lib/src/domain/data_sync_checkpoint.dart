import 'package:equatable/equatable.dart';

/// A versioned checkpoint for tracking data synchronization progress (S473).
class DataSyncCheckpoint extends Equatable {
  const DataSyncCheckpoint({
    required this.checkpointId,
    required this.sourceId,
    required this.lastSyncedSequence,
    required this.lastSyncedVersion,
    this.isConsistent = true,
    this.pendingCount = 0,
  });

  final String checkpointId;
  final String sourceId;
  final int lastSyncedSequence;
  final String lastSyncedVersion;
  final bool isConsistent;
  final int pendingCount;

  bool get hasPendingChanges => pendingCount > 0;
  bool get isUpToDate => isConsistent && !hasPendingChanges;

  @override
  List<Object?> get props => [
    checkpointId,
    sourceId,
    lastSyncedSequence,
    lastSyncedVersion,
    isConsistent,
    pendingCount,
  ];
}
