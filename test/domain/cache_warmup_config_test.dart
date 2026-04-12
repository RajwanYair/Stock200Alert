import 'package:cross_tide/src/domain/cache_warmup_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CacheWarmupConfig', () {
    test('equality', () {
      const a = CacheWarmupConfig(
        strategy: WarmupStrategy.watchlistFirst,
        maxTickersToWarm: 20,
        lookbackDays: 252,
      );
      const b = CacheWarmupConfig(
        strategy: WarmupStrategy.watchlistFirst,
        maxTickersToWarm: 20,
        lookbackDays: 252,
      );
      expect(a, b);
    });

    test('copyWith changes maxTickersToWarm', () {
      const base = CacheWarmupConfig(
        strategy: WarmupStrategy.watchlistFirst,
        maxTickersToWarm: 20,
        lookbackDays: 252,
      );
      final updated = base.copyWith(maxTickersToWarm: 30);
      expect(updated.maxTickersToWarm, 30);
    });

    test('props length is 5', () {
      const obj = CacheWarmupConfig(
        strategy: WarmupStrategy.watchlistFirst,
        maxTickersToWarm: 20,
        lookbackDays: 252,
      );
      expect(obj.props.length, 5);
    });
  });
}
