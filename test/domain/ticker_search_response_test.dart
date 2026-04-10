import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TickerQueryResult', () {
    test('creates result with optional sector', () {
      const result = TickerQueryResult(
        symbol: 'AAPL',
        companyName: 'Apple Inc.',
        exchange: 'NASDAQ',
        relevanceScore: 0.98,
        sector: 'Technology',
      );
      expect(result.hasSector, isTrue);
      expect(result.isActive, isTrue);
    });

    test('hasSector false when sector is null', () {
      const result = TickerQueryResult(
        symbol: 'X',
        companyName: 'X Corp',
        exchange: 'NYSE',
        relevanceScore: 0.5,
      );
      expect(result.hasSector, isFalse);
    });
  });

  group('TickerSearchResponse', () {
    late DateTime executed;

    setUp(() => executed = DateTime(2025, 6, 1, 10));

    test('creates response and reports isEmpty', () {
      final response = TickerSearchResponse(
        query: 'apple',
        results: const [],
        executedAt: executed,
      );
      expect(response.isEmpty, isTrue);
      expect(response.topResult, isNull);
      expect(response.hasPagination, isFalse);
    });

    test('returns topResult as first result', () {
      final response = TickerSearchResponse(
        query: 'aapl',
        results: const [
          TickerQueryResult(
            symbol: 'AAPL',
            companyName: 'Apple Inc.',
            exchange: 'NASDAQ',
            relevanceScore: 0.99,
          ),
          TickerQueryResult(
            symbol: 'AAPOS',
            companyName: 'Other',
            exchange: 'NYSE',
            relevanceScore: 0.5,
          ),
        ],
        executedAt: executed,
        totalMatches: 5,
      );
      expect(response.topResult!.symbol, 'AAPL');
      expect(response.returnedCount, 2);
      expect(response.hasPagination, isTrue);
    });

    test('equality holds for identical responses', () {
      final a = TickerSearchResponse(
        query: 'q',
        results: const [],
        executedAt: executed,
      );
      final b = TickerSearchResponse(
        query: 'q',
        results: const [],
        executedAt: executed,
      );
      expect(a, equals(b));
    });
  });
}
