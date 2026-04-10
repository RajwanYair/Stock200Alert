import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WatchlistChangeLog', () {
    WatchlistChangeLog buildLog({
      WatchlistAuditChangeType changeType = WatchlistAuditChangeType.added,
    }) => WatchlistChangeLog(
      changeId: 'chg-001',
      watchlistId: 'wl-42',
      changeType: changeType,
      changedAt: DateTime(2024, 6, 1, 10),
      ticker: 'AAPL',
      detail: 'Manually added',
    );

    test('isTickerChange is true for added', () {
      expect(
        buildLog(changeType: WatchlistAuditChangeType.added).isTickerChange,
        isTrue,
      );
    });

    test('isTickerChange is true for removed', () {
      expect(
        buildLog(changeType: WatchlistAuditChangeType.removed).isTickerChange,
        isTrue,
      );
    });

    test('isTickerChange is true for edited', () {
      expect(
        buildLog(changeType: WatchlistAuditChangeType.edited).isTickerChange,
        isTrue,
      );
    });

    test('isTickerChange is false for renamed', () {
      expect(
        buildLog(changeType: WatchlistAuditChangeType.renamed).isTickerChange,
        isFalse,
      );
    });

    test('isTickerChange is false for bulkReplaced', () {
      expect(
        buildLog(
          changeType: WatchlistAuditChangeType.bulkReplaced,
        ).isTickerChange,
        isFalse,
      );
    });

    test('ticker defaults to null when omitted', () {
      final log = WatchlistChangeLog(
        changeId: 'chg-002',
        watchlistId: 'wl-42',
        changeType: WatchlistAuditChangeType.renamed,
        changedAt: DateTime(2024, 6, 1),
      );
      expect(log.ticker, isNull);
    });

    test('equality holds for same props', () {
      expect(buildLog(), equals(buildLog()));
    });
  });
}
