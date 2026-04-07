import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AlertDeduplicator', () {
    final AlertDedupKey key1 = AlertDedupKey(
      symbol: 'AAPL',
      alertType: 'sma200CrossUp',
      candleDate: DateTime(2024, 6, 15),
    );
    final AlertDedupKey key2 = AlertDedupKey(
      symbol: 'MSFT',
      alertType: 'sma200CrossUp',
      candleDate: DateTime(2024, 6, 15),
    );

    test('new key fires', () {
      const AlertDeduplicator dedup = AlertDeduplicator();
      expect(dedup.check(key1), DedupDecision.fire);
    });

    test('same key suppresses', () {
      final AlertDeduplicator dedup = AlertDeduplicator(firedKeys: {key1});
      expect(dedup.check(key1), DedupDecision.suppress);
    });

    test('different key fires', () {
      final AlertDeduplicator dedup = AlertDeduplicator(firedKeys: {key1});
      expect(dedup.check(key2), DedupDecision.fire);
    });

    test('recordFired adds key', () {
      const AlertDeduplicator dedup = AlertDeduplicator();
      final AlertDeduplicator updated = dedup.recordFired(key1);
      expect(updated.check(key1), DedupDecision.suppress);
      expect(dedup.check(key1), DedupDecision.fire); // original unchanged
    });

    test('checkWithCooldown fires when no history', () {
      const AlertDeduplicator dedup = AlertDeduplicator(
        cooldown: Duration(hours: 24),
      );
      expect(
        dedup.checkWithCooldown(
          key1,
          now: DateTime(2024, 6, 15, 12, 0),
          firedAt: {},
        ),
        DedupDecision.fire,
      );
    });

    test('checkWithCooldown suppresses within cooldown', () {
      const AlertDeduplicator dedup = AlertDeduplicator(
        cooldown: Duration(hours: 24),
      );
      expect(
        dedup.checkWithCooldown(
          key1,
          now: DateTime(2024, 6, 15, 12, 0),
          firedAt: {key1: DateTime(2024, 6, 15, 10, 0)},
        ),
        DedupDecision.suppress,
      );
    });

    test('checkWithCooldown fires after cooldown expires', () {
      const AlertDeduplicator dedup = AlertDeduplicator(
        cooldown: Duration(hours: 24),
      );
      expect(
        dedup.checkWithCooldown(
          key1,
          now: DateTime(2024, 6, 17, 12, 0),
          firedAt: {key1: DateTime(2024, 6, 15, 10, 0)},
        ),
        DedupDecision.fire,
      );
    });

    test('checkWithCooldown zero duration always suppresses existing key', () {
      const AlertDeduplicator dedup = AlertDeduplicator();
      expect(
        dedup.checkWithCooldown(
          key1,
          now: DateTime(2025, 1, 1),
          firedAt: {key1: DateTime(2024, 1, 1)},
        ),
        DedupDecision.suppress,
      );
    });

    test('AlertDedupKey equality', () {
      final AlertDedupKey a = AlertDedupKey(
        symbol: 'AAPL',
        alertType: 'sma200CrossUp',
        candleDate: DateTime(2024, 6, 15),
      );
      final AlertDedupKey b = AlertDedupKey(
        symbol: 'AAPL',
        alertType: 'sma200CrossUp',
        candleDate: DateTime(2024, 6, 15),
      );
      expect(a, equals(b));
    });

    test('different candle date is different key', () {
      final AlertDedupKey a = AlertDedupKey(
        symbol: 'AAPL',
        alertType: 'sma200CrossUp',
        candleDate: DateTime(2024, 6, 15),
      );
      final AlertDedupKey b = AlertDedupKey(
        symbol: 'AAPL',
        alertType: 'sma200CrossUp',
        candleDate: DateTime(2024, 6, 16),
      );
      expect(a, isNot(equals(b)));
    });
  });
}
