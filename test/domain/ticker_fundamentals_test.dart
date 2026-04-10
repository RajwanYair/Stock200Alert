import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TickerFundamentals', () {
    late DateTime fetchedAt;

    setUp(() => fetchedAt = DateTime(2025, 6, 1));

    test('creates instance with nulls for optional fields', () {
      final f = TickerFundamentals(symbol: 'AAPL', fetchedAt: fetchedAt);
      expect(f.symbol, 'AAPL');
      expect(f.peRatio, isNull);
      expect(f.eps, isNull);
      expect(f.beta, isNull);
    });

    test('isExpensive true when PE > 30', () {
      final f = TickerFundamentals(
        symbol: 'X',
        fetchedAt: fetchedAt,
        peRatio: 35.0,
      );
      expect(f.isExpensive, isTrue);
      expect(f.isCheap, isFalse);
    });

    test('isCheap true when PE < 10', () {
      final f = TickerFundamentals(
        symbol: 'X',
        fetchedAt: fetchedAt,
        peRatio: 8.0,
      );
      expect(f.isCheap, isTrue);
      expect(f.isExpensive, isFalse);
    });

    test('isExpensive and isCheap false when peRatio is null', () {
      final f = TickerFundamentals(symbol: 'X', fetchedAt: fetchedAt);
      expect(f.isExpensive, isFalse);
      expect(f.isCheap, isFalse);
    });

    test('hasGoodDividend true when yield >= 2.0', () {
      final f = TickerFundamentals(
        symbol: 'JNJ',
        fetchedAt: fetchedAt,
        dividendYieldPct: 2.5,
      );
      expect(f.hasGoodDividend, isTrue);
    });

    test('isHighBeta true when beta > 1.0', () {
      final f = TickerFundamentals(
        symbol: 'TSLA',
        fetchedAt: fetchedAt,
        beta: 1.8,
      );
      expect(f.isHighBeta, isTrue);
    });

    test('hasLargeCapSize true when marketCap >= 10B', () {
      final f = TickerFundamentals(
        symbol: 'AAPL',
        fetchedAt: fetchedAt,
        marketCapUsd: 3_000_000_000_000.0,
      );
      expect(f.hasLargeCapSize, isTrue);
    });

    test('equality holds for identical instances', () {
      final a = TickerFundamentals(symbol: 'AAPL', fetchedAt: fetchedAt);
      final b = TickerFundamentals(symbol: 'AAPL', fetchedAt: fetchedAt);
      expect(a, equals(b));
    });
  });
}
