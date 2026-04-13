import 'package:equatable/equatable.dart';

/// Watchlist merge result — outcome of a multi-device watchlist merge.
enum MergeConflictStrategy { keepLocal, keepRemote, merge, manualReview }

class WatchlistMergeResult extends Equatable {
  const WatchlistMergeResult({
    required this.mergeId,
    required this.conflictStrategy,
    required this.addedCount,
    required this.removedCount,
    required this.conflictCount,
  });

  final String mergeId;
  final MergeConflictStrategy conflictStrategy;
  final int addedCount;
  final int removedCount;
  final int conflictCount;

  WatchlistMergeResult copyWith({
    String? mergeId,
    MergeConflictStrategy? conflictStrategy,
    int? addedCount,
    int? removedCount,
    int? conflictCount,
  }) => WatchlistMergeResult(
    mergeId: mergeId ?? this.mergeId,
    conflictStrategy: conflictStrategy ?? this.conflictStrategy,
    addedCount: addedCount ?? this.addedCount,
    removedCount: removedCount ?? this.removedCount,
    conflictCount: conflictCount ?? this.conflictCount,
  );

  @override
  List<Object?> get props => [
    mergeId,
    conflictStrategy,
    addedCount,
    removedCount,
    conflictCount,
  ];
}
