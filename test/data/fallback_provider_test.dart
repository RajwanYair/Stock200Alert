// Tests for FallbackMarketDataProvider.
import 'package:cross_tide/src/data/providers/fallback_provider.dart';
import 'package:cross_tide/src/data/providers/market_data_provider.dart';
import 'package:cross_tide/src/domain/entities.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _OkProvider implements IMarketDataProvider {
  _OkProvider(this.id, {this.candles = const []});
  @override
  final String id;
  @override
  String get name => 'OK-$id';
  final List<DailyCandle> candles;
  int calls = 0;

  @override
  Future<List<DailyCandle>> fetchDailyHistory(String ticker) async {
    calls++;
    return candles;
  }
}

class _FailProvider implements IMarketDataProvider {
  _FailProvider(this.id);
  @override
  final String id;
  @override
  String get name => 'Fail-$id';
  int calls = 0;

  @override
  Future<List<DailyCandle>> fetchDailyHistory(String ticker) async {
    calls++;
    throw MarketDataException('$id failed', isRetryable: true);
  }
}

final _candle = DailyCandle(
  date: DateTime(2024),
  open: 100,
  high: 110,
  low: 90,
  close: 105,
  volume: 1000,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('FallbackMarketDataProvider', () {
    test('returns result from first provider when it succeeds', () async {
      final p1 = _OkProvider('p1', candles: [_candle]);
      final p2 = _OkProvider('p2');
      final fallback = FallbackMarketDataProvider(providers: [p1, p2]);

      final result = await fallback.fetchDailyHistory('AAPL');
      expect(result, [_candle]);
      expect(p1.calls, 1);
      expect(p2.calls, 0, reason: 'p2 should not be called when p1 succeeds');
    });

    test('falls back to second provider when first fails', () async {
      final p1 = _FailProvider('p1');
      final p2 = _OkProvider('p2', candles: [_candle]);
      final fallback = FallbackMarketDataProvider(providers: [p1, p2]);

      final result = await fallback.fetchDailyHistory('AAPL');
      expect(result, [_candle]);
      expect(p1.calls, 1);
      expect(p2.calls, 1);
    });

    test('falls back through entire chain', () async {
      final p1 = _FailProvider('p1');
      final p2 = _FailProvider('p2');
      final p3 = _OkProvider('p3', candles: [_candle]);
      final fallback = FallbackMarketDataProvider(providers: [p1, p2, p3]);

      final result = await fallback.fetchDailyHistory('AAPL');
      expect(result, [_candle]);
      expect(p1.calls, 1);
      expect(p2.calls, 1);
      expect(p3.calls, 1);
    });

    test('throws MarketDataException when all providers fail', () async {
      final p1 = _FailProvider('p1');
      final p2 = _FailProvider('p2');
      final fallback = FallbackMarketDataProvider(providers: [p1, p2]);

      expect(
        () => fallback.fetchDailyHistory('AAPL'),
        throwsA(isA<MarketDataException>()),
      );
    });

    test('id returns first provider id', () {
      final p1 = _OkProvider('yahoo');
      final p2 = _OkProvider('mock');
      final fallback = FallbackMarketDataProvider(providers: [p1, p2]);
      expect(fallback.id, 'yahoo');
    });

    test('lastUsedProviderId updates to successful provider', () async {
      final p1 = _FailProvider('p1');
      final p2 = _OkProvider('p2', candles: [_candle]);
      final fallback = FallbackMarketDataProvider(providers: [p1, p2]);

      expect(fallback.lastUsedProviderId, isNull);
      await fallback.fetchDailyHistory('AAPL');
      expect(fallback.lastUsedProviderId, 'p2');
    });
  });
}
