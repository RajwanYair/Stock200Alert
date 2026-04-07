import 'package:cross_tide/src/domain/watchlist_share_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const codec = WatchlistShareCodec();

  group('WatchlistShareCodec.encode', () {
    test('encodes tickers and profile into URL', () {
      const payload = WatchlistSharePayload(
        tickers: ['AAPL', 'MSFT', 'GOOG'],
        profileName: 'aggressive',
      );

      final url = codec.encode(payload);
      expect(url, contains('crosstide://share'));
      expect(url, contains('v=1'));
      expect(url, contains('t=AAPL,MSFT,GOOG'));
      expect(url, contains('p=aggressive'));
    });

    test('omits profile when empty', () {
      const payload = WatchlistSharePayload(tickers: ['AAPL']);

      final url = codec.encode(payload);
      expect(url, isNot(contains('p=')));
    });
  });

  group('WatchlistShareCodec.decode', () {
    test('round-trips encode → decode', () {
      const original = WatchlistSharePayload(
        tickers: ['AAPL', 'MSFT'],
        profileName: 'balanced',
      );

      final url = codec.encode(original);
      final decoded = codec.decode(url);

      expect(decoded, isNotNull);
      expect(decoded!.tickers, ['AAPL', 'MSFT']);
      expect(decoded.profileName, 'balanced');
    });

    test('returns null for invalid URL', () {
      expect(codec.decode('https://example.com'), isNull);
    });

    test('returns null for wrong scheme', () {
      expect(codec.decode('https://share?v=1&t=AAPL'), isNull);
    });

    test('returns null when tickers missing', () {
      expect(codec.decode('crosstide://share?v=1'), isNull);
    });

    test('returns null for empty ticker list', () {
      expect(codec.decode('crosstide://share?v=1&t='), isNull);
    });
  });

  group('WatchlistShareCodec.isValid', () {
    test('validates correct URL', () {
      expect(codec.isValid('crosstide://share?v=1&t=AAPL'), isTrue);
    });

    test('rejects bad URL', () {
      expect(codec.isValid('not-a-url'), isFalse);
    });
  });

  group('WatchlistSharePayload', () {
    test('props equality', () {
      const a = WatchlistSharePayload(tickers: ['AAPL'], profileName: 'x');
      const b = WatchlistSharePayload(tickers: ['AAPL'], profileName: 'x');
      expect(a, equals(b));
    });
  });
}
