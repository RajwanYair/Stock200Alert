import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MarketBreadthSnapshot', () {
    MarketBreadthSnapshot buildSnapshot({
      int advancers = 300,
      int decliners = 150,
      int unchanged = 50,
    }) {
      return MarketBreadthSnapshot(
        advancers: advancers,
        decliners: decliners,
        unchanged: unchanged,
        newHighs52w: 40,
        newLows52w: 10,
        snapshotDate: DateTime(2024, 6, 1),
      );
    }

    test('totalIssues sums advancers + decliners + unchanged', () {
      expect(buildSnapshot().totalIssues, 500);
    });

    test('netAdvancers is advancers minus decliners', () {
      expect(buildSnapshot().netAdvancers, 150);
    });

    test('adRatio returns advancers / decliners', () {
      expect(buildSnapshot().adRatio, closeTo(2.0, 0.001));
    });

    test('adRatio returns null when decliners is zero', () {
      final snap = buildSnapshot(decliners: 0);
      expect(snap.adRatio, isNull);
    });

    test('isBullish is true when advancers >= 60 percent of total', () {
      // 300/500 = 60%
      expect(buildSnapshot().isBullish, isTrue);
    });

    test('isBullish is false when advancers < 60 percent', () {
      // 200/500 = 40%
      expect(buildSnapshot(advancers: 200, decliners: 250).isBullish, isFalse);
    });

    test('isBullish is false when totalIssues is 0', () {
      final snap = buildSnapshot(advancers: 0, decliners: 0, unchanged: 0);
      expect(snap.isBullish, isFalse);
    });

    test('equality holds for same props', () {
      expect(buildSnapshot(), equals(buildSnapshot()));
    });
  });
}
