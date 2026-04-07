import 'package:cross_tide/src/application/data_freshness_tracker.dart';
import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DataFreshnessTracker', () {
    late DataFreshnessTracker tracker;
    final now = DateTime(2024, 6, 15, 12, 0);

    setUp(() {
      tracker = DataFreshnessTracker();
    });

    test('initially empty', () {
      expect(tracker.count, 0);
      expect(tracker.lastFetchedAt('AAPL'), isNull);
    });

    test('recordFetch stores timestamp', () {
      tracker.recordFetch('AAPL', fetchedAt: now);
      expect(tracker.lastFetchedAt('AAPL'), now);
      expect(tracker.count, 1);
    });

    test('recordFetch is case-insensitive', () {
      tracker.recordFetch('aapl', fetchedAt: now);
      expect(tracker.lastFetchedAt('AAPL'), now);
    });

    test('freshness returns DataFreshness', () {
      tracker.recordFetch(
        'AAPL',
        fetchedAt: now.subtract(const Duration(minutes: 30)),
      );
      final df = tracker.freshness('AAPL', now: now);
      expect(df, isNotNull);
      expect(df!.level, FreshnessLevel.fresh);
      expect(df.ticker, 'AAPL');
    });

    test('freshness returns null for unknown ticker', () {
      expect(tracker.freshness('TSLA', now: now), isNull);
    });

    test('all returns all tracked tickers', () {
      tracker.recordFetch('AAPL', fetchedAt: now);
      tracker.recordFetch('TSLA', fetchedAt: now);
      final all = tracker.all(now: now);
      expect(all.length, 2);
    });

    test('remove deletes ticker', () {
      tracker.recordFetch('AAPL', fetchedAt: now);
      tracker.remove('AAPL');
      expect(tracker.lastFetchedAt('AAPL'), isNull);
      expect(tracker.count, 0);
    });

    test('clear removes everything', () {
      tracker.recordFetch('AAPL', fetchedAt: now);
      tracker.recordFetch('TSLA', fetchedAt: now);
      tracker.clear();
      expect(tracker.count, 0);
    });

    test('overwrite timestamp', () {
      final earlier = now.subtract(const Duration(hours: 2));
      tracker.recordFetch('AAPL', fetchedAt: earlier);
      tracker.recordFetch('AAPL', fetchedAt: now);
      expect(tracker.lastFetchedAt('AAPL'), now);
    });
  });
}
