import 'package:cross_tide/src/domain/watchlist_merge_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WatchlistMergeResult', () {
    test('equality', () {
      const a = WatchlistMergeResult(
        mergeId: 'merge-1',
        conflictStrategy: MergeConflictStrategy.merge,
        addedCount: 3,
        removedCount: 1,
        conflictCount: 2,
      );
      const b = WatchlistMergeResult(
        mergeId: 'merge-1',
        conflictStrategy: MergeConflictStrategy.merge,
        addedCount: 3,
        removedCount: 1,
        conflictCount: 2,
      );
      expect(a, b);
    });

    test('copyWith changes addedCount', () {
      const base = WatchlistMergeResult(
        mergeId: 'merge-1',
        conflictStrategy: MergeConflictStrategy.merge,
        addedCount: 3,
        removedCount: 1,
        conflictCount: 2,
      );
      final updated = base.copyWith(addedCount: 5);
      expect(updated.addedCount, 5);
    });

    test('props length is 5', () {
      const obj = WatchlistMergeResult(
        mergeId: 'merge-1',
        conflictStrategy: MergeConflictStrategy.merge,
        addedCount: 3,
        removedCount: 1,
        conflictCount: 2,
      );
      expect(obj.props.length, 5);
    });
  });
}
