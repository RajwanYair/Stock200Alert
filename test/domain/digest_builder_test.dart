import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const DigestBuilder builder = DigestBuilder();

  AlertHistoryEntry makeEntry(
    String symbol,
    String alertType,
    DateTime firedAt,
  ) => AlertHistoryEntry(
    symbol: symbol,
    alertType: alertType,
    message: '$symbol $alertType',
    firedAt: firedAt,
  );

  group('DigestBuilder', () {
    test('buildBySymbol groups by symbol', () {
      final List<AlertHistoryEntry> entries = [
        makeEntry('AAPL', 'sma200CrossUp', DateTime(2024, 6, 15)),
        makeEntry('AAPL', 'michoMethodBuy', DateTime(2024, 6, 15)),
        makeEntry('MSFT', 'sma200CrossUp', DateTime(2024, 6, 15)),
      ];
      final List<AlertDigest> digests = builder.buildBySymbol(
        entries,
        asOf: DateTime(2024, 6, 15),
      );
      expect(digests.length, 2);
      expect(digests[0].symbols, ['AAPL']);
      expect(digests[0].count, 2);
      expect(digests[0].title, '2 alerts for AAPL');
      expect(digests[1].count, 1);
      expect(digests[1].title, '1 alert for MSFT');
    });

    test('buildBySymbol returns empty list for no entries', () {
      final List<AlertDigest> digests = builder.buildBySymbol(
        [],
        asOf: DateTime(2024, 6, 15),
      );
      expect(digests, isEmpty);
    });

    test('buildCombined creates single digest', () {
      final List<AlertHistoryEntry> entries = [
        makeEntry('AAPL', 'sma200CrossUp', DateTime(2024, 6, 15)),
        makeEntry('MSFT', 'michoMethodBuy', DateTime(2024, 6, 15)),
        makeEntry('GOOG', 'rsiMethodBuy', DateTime(2024, 6, 15)),
      ];
      final AlertDigest digest = builder.buildCombined(
        entries,
        asOf: DateTime(2024, 6, 15),
      );
      expect(digest.count, 3);
      expect(digest.symbols, ['AAPL', 'GOOG', 'MSFT']);
      expect(digest.title, '3 alerts across 3 symbols');
    });

    test('buildCombined singular forms', () {
      final List<AlertHistoryEntry> entries = [
        makeEntry('AAPL', 'sma200CrossUp', DateTime(2024, 6, 15)),
      ];
      final AlertDigest digest = builder.buildCombined(
        entries,
        asOf: DateTime(2024, 6, 15),
      );
      expect(digest.title, '1 alert across 1 symbol');
    });

    test('AlertDigest equality', () {
      final AlertDigest a = AlertDigest(
        title: 'Test',
        entries: const [],
        createdAt: DateTime(2024, 6, 15),
      );
      final AlertDigest b = AlertDigest(
        title: 'Test',
        entries: const [],
        createdAt: DateTime(2024, 6, 15),
      );
      expect(a, equals(b));
    });

    test('buildBySymbol alphabetical order', () {
      final List<AlertHistoryEntry> entries = [
        makeEntry('MSFT', 'sma200CrossUp', DateTime(2024, 6, 15)),
        makeEntry('AAPL', 'sma200CrossUp', DateTime(2024, 6, 15)),
      ];
      final List<AlertDigest> digests = builder.buildBySymbol(
        entries,
        asOf: DateTime(2024, 6, 15),
      );
      expect(digests[0].symbols, ['AAPL']);
      expect(digests[1].symbols, ['MSFT']);
    });
  });
}
