import 'package:cross_tide/src/data/providers/market_data_provider.dart';
import 'package:cross_tide/src/data/providers/marketwatch_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Fake Dio adapter that returns canned responses
// ---------------------------------------------------------------------------

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._body, {this.statusCode = 200});

  final String _body;
  final int statusCode;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(_body, statusCode);
  }

  @override
  void close({bool force = false}) {}
}

Dio buildFakeDio(String body, {int statusCode = 200}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://fake.test'));
  dio.httpClientAdapter = _FakeAdapter(body, statusCode: statusCode);
  return dio;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('MarketWatchProvider', () {
    test('id and name', () {
      final provider = MarketWatchProvider();
      expect(provider.id, 'marketwatch');
      expect(provider.name, contains('MarketWatch'));
    });

    test('parses valid CSV with dollar signs and commas', () async {
      const csv =
          'Date, Open, High, Low, Close, Volume\n'
          '04/07/2025, \$220.50, \$225.00, \$218.00, \$222.30, "45,000,000"\n'
          '04/04/2025, \$215.00, \$221.00, \$214.00, \$220.50, "38,500,000"\n';

      final dio = buildFakeDio(csv);
      final provider = MarketWatchProvider(dio: dio);
      final candles = await provider.fetchDailyHistory('AAPL');

      expect(candles, hasLength(2));
      // Should be sorted ascending (04/04 before 04/07)
      expect(candles.first.date, DateTime(2025, 4, 4));
      expect(candles.last.date, DateTime(2025, 4, 7));
      expect(candles.last.open, closeTo(220.50, 0.01));
      expect(candles.last.close, closeTo(222.30, 0.01));
      expect(candles.first.volume, 38500000);
    });

    test('parses prices without dollar sign', () async {
      const csv =
          'Date, Open, High, Low, Close, Volume\n'
          '01/15/2025, 100.00, 110.00, 95.00, 105.00, 1000000\n';

      final dio = buildFakeDio(csv);
      final provider = MarketWatchProvider(dio: dio);
      final candles = await provider.fetchDailyHistory('MSFT');

      expect(candles, hasLength(1));
      expect(candles.first.open, 100.0);
      expect(candles.first.high, 110.0);
      expect(candles.first.low, 95.0);
      expect(candles.first.close, 105.0);
    });

    test('skips malformed rows', () async {
      const csv =
          'Date, Open, High, Low, Close, Volume\n'
          '04/07/2025, \$220.50, \$225.00, \$218.00, \$222.30, 45000000\n'
          'bad-row, x, y,\n'
          '04/06/2025, \$219.00, \$221.00, \$217.00, \$220.00, 12000000\n';

      final dio = buildFakeDio(csv);
      final provider = MarketWatchProvider(dio: dio);
      final candles = await provider.fetchDailyHistory('AAPL');

      expect(candles, hasLength(2));
    });

    test('throws MarketDataException on empty response', () async {
      final dio = buildFakeDio('');
      final provider = MarketWatchProvider(dio: dio);

      expect(
        () => provider.fetchDailyHistory('AAPL'),
        throwsA(isA<MarketDataException>()),
      );
    });

    test('throws MarketDataException on header-only CSV', () async {
      const csv = 'Date, Open, High, Low, Close, Volume\n';
      final dio = buildFakeDio(csv);
      final provider = MarketWatchProvider(dio: dio);

      expect(
        () => provider.fetchDailyHistory('AAPL'),
        throwsA(isA<MarketDataException>()),
      );
    });

    test('throws MarketDataException on HTTP error', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://fake.test'));
      dio.httpClientAdapter = _FakeAdapter('error', statusCode: 500);
      // Dio throws DioException for non-2xx by default. Add a response interceptor.
      dio.options.validateStatus = (status) => status != null && status < 300;

      final provider = MarketWatchProvider(dio: dio);
      expect(
        () => provider.fetchDailyHistory('AAPL'),
        throwsA(isA<MarketDataException>()),
      );
    });
  });
}
