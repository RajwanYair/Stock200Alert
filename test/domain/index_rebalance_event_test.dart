import 'package:cross_tide/src/domain/index_rebalance_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IndexRebalanceEvent', () {
    test('equality', () {
      final a = IndexRebalanceEvent(
        indexId: 'SPX',
        indexName: 'S&P 500',
        eventType: IndexRebalanceType.addition,
        affectedTicker: 'PLTR',
        effectiveDate: DateTime(2025, 12, 20),
      );
      final b = IndexRebalanceEvent(
        indexId: 'SPX',
        indexName: 'S&P 500',
        eventType: IndexRebalanceType.addition,
        affectedTicker: 'PLTR',
        effectiveDate: DateTime(2025, 12, 20),
      );
      expect(a, b);
    });

    test('copyWith changes affectedTicker', () {
      final base = IndexRebalanceEvent(
        indexId: 'SPX',
        indexName: 'S&P 500',
        eventType: IndexRebalanceType.addition,
        affectedTicker: 'PLTR',
        effectiveDate: DateTime(2025, 12, 20),
      );
      final updated = base.copyWith(affectedTicker: 'NVDA');
      expect(updated.affectedTicker, 'NVDA');
    });

    test('props length is 8', () {
      final obj = IndexRebalanceEvent(
        indexId: 'SPX',
        indexName: 'S&P 500',
        eventType: IndexRebalanceType.addition,
        affectedTicker: 'PLTR',
        effectiveDate: DateTime(2025, 12, 20),
      );
      expect(obj.props.length, 8);
    });
  });
}
