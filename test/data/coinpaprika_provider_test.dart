import 'dart:convert';

import 'package:cross_tide/src/data/providers/coinpaprika_provider.dart';
import 'package:cross_tide/src/data/providers/market_data_provider.dart';
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
    return ResponseBody.fromString(
      _body,
      statusCode,
      headers: {
        'content-type': ['application/json; charset=utf-8'],
      },
    );
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
  group('CoinpaprikaProvider', () {
    test('id and name', () {
      final provider = CoinpaprikaProvider();
      expect(provider.id, 'coinpaprika');
      expect(provider.name, contains('Coinpaprika'));
    });

    test('parses valid OHLCV JSON', () async {
      final json = jsonEncode([
        {
          'time_open': '2024-01-01T00:00:00Z',
          'time_close': '2024-01-01T23:59:59Z',
          'open': 42000.0,
          'high': 43500.0,
          'low': 41800.0,
          'close': 43200.0,
          'volume': 12345678900,
          'market_cap': 820000000000,
        },
        {
          'time_open': '2024-01-02T00:00:00Z',
          'time_close': '2024-01-02T23:59:59Z',
          'open': 43200.0,
          'high': 44000.0,
          'low': 42500.0,
          'close': 43800.0,
          'volume': 11234567890,
          'market_cap': 830000000000,
        },
      ]);

      final dio = buildFakeDio(json);
      final provider = CoinpaprikaProvider(dio: dio);
      final candles = await provider.fetchDailyHistory('CRYPTO:btc-bitcoin');

      expect(candles, hasLength(2));
      expect(candles.first.date.year, 2024);
      expect(candles.first.date.month, 1);
      expect(candles.first.date.day, 1);
      expect(candles.first.open, 42000.0);
      expect(candles.first.high, 43500.0);
      expect(candles.first.close, 43200.0);
      expect(candles.first.volume, 12345678900);
      expect(candles.last.date.day, 2);
    });

    test('sorts ascending by date', () async {
      final json = jsonEncode([
        {
          'time_open': '2024-01-03T00:00:00Z',
          'open': 100.0,
          'high': 110.0,
          'low': 90.0,
          'close': 105.0,
          'volume': 1000,
        },
        {
          'time_open': '2024-01-01T00:00:00Z',
          'open': 50.0,
          'high': 55.0,
          'low': 48.0,
          'close': 52.0,
          'volume': 500,
        },
      ]);

      final dio = buildFakeDio(json);
      final provider = CoinpaprikaProvider(dio: dio);
      final candles = await provider.fetchDailyHistory('CRYPTO:eth-ethereum');

      expect(candles.first.date.day, 1);
      expect(candles.last.date.day, 3);
    });

    test('skips entries with null OHLC fields', () async {
      final json = jsonEncode([
        {
          'time_open': '2024-01-01T00:00:00Z',
          'open': 100.0,
          'high': 110.0,
          'low': 90.0,
          'close': 105.0,
          'volume': 1000,
        },
        {
          'time_open': '2024-01-02T00:00:00Z',
          'open': null,
          'high': 110.0,
          'low': 90.0,
          'close': 105.0,
          'volume': 1000,
        },
      ]);

      final dio = buildFakeDio(json);
      final provider = CoinpaprikaProvider(dio: dio);
      final candles = await provider.fetchDailyHistory('CRYPTO:btc-bitcoin');

      expect(candles, hasLength(1));
      expect(candles.first.date.day, 1);
    });

    test('handles CRYPTO: prefix case-insensitively', () async {
      final json = jsonEncode([
        {
          'time_open': '2024-01-01T00:00:00Z',
          'open': 100.0,
          'high': 110.0,
          'low': 90.0,
          'close': 105.0,
          'volume': 1000,
        },
      ]);

      final dio = buildFakeDio(json);
      final provider = CoinpaprikaProvider(dio: dio);
      // Should work with uppercase CRYPTO: prefix
      final candles = await provider.fetchDailyHistory('CRYPTO:BTC-BITCOIN');
      expect(candles, hasLength(1));
    });

    test('throws MarketDataException on empty response', () async {
      final dio = buildFakeDio('[]');
      final provider = CoinpaprikaProvider(dio: dio);

      expect(
        () => provider.fetchDailyHistory('CRYPTO:btc-bitcoin'),
        throwsA(isA<MarketDataException>()),
      );
    });

    test('defaults volume to 0 when missing', () async {
      final json = jsonEncode([
        {
          'time_open': '2024-01-01T00:00:00Z',
          'open': 100.0,
          'high': 110.0,
          'low': 90.0,
          'close': 105.0,
        },
      ]);

      final dio = buildFakeDio(json);
      final provider = CoinpaprikaProvider(dio: dio);
      final candles = await provider.fetchDailyHistory('CRYPTO:btc-bitcoin');

      expect(candles, hasLength(1));
      expect(candles.first.volume, 0);
    });
  });
}
