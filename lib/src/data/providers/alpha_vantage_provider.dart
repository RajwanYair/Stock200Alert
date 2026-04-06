/// Alpha Vantage Market Data Provider.
///
/// API docs: https://www.alphavantage.co/documentation/
/// Rate limits: Free tier = 25 requests/day, 5 requests/minute.
/// Required: API key from https://www.alphavantage.co/support/#api-key
///
/// Uses TIME_SERIES_DAILY with outputsize=full to get 200+ trading days.
library;

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../domain/entities.dart';
import 'market_data_provider.dart';

class AlphaVantageProvider implements IMarketDataProvider {
  AlphaVantageProvider({required this.apiKey, Dio? dio, Logger? logger})
    : _dio = dio ?? Dio(),
      _logger = logger ?? Logger();

  final String apiKey;
  final Dio _dio;
  final Logger _logger;

  static const _baseUrl = 'https://www.alphavantage.co/query';

  @override
  String get name => 'Alpha Vantage';

  @override
  String get id => 'alpha_vantage';

  @override
  Future<List<DailyCandle>> fetchDailyHistory(String ticker) async {
    _logger.i('Fetching daily history for $ticker from Alpha Vantage');
    final stopwatch = Stopwatch()..start();

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _baseUrl,
        queryParameters: {
          'function': 'TIME_SERIES_DAILY',
          'symbol': ticker,
          'outputsize': 'full',
          'apikey': apiKey,
        },
      );

      final data = response.data;
      if (data == null) {
        throw const MarketDataException('Empty response from Alpha Vantage');
      }

      // Check for API error messages
      if (data.containsKey('Error Message')) {
        throw MarketDataException(
          data['Error Message'] as String,
          isRetryable: false,
        );
      }
      if (data.containsKey('Note')) {
        // Rate limit hit
        throw MarketDataException(
          data['Note'] as String,
          statusCode: 429,
          isRetryable: true,
        );
      }
      if (data.containsKey('Information')) {
        throw MarketDataException(
          data['Information'] as String,
          statusCode: 429,
          isRetryable: true,
        );
      }

      final timeSeries = data['Time Series (Daily)'] as Map<String, dynamic>?;
      if (timeSeries == null || timeSeries.isEmpty) {
        throw const MarketDataException(
          'No time series data in response',
          isRetryable: true,
        );
      }

      final candles = <DailyCandle>[];
      for (final entry in timeSeries.entries) {
        final dateStr = entry.key;
        final values = entry.value as Map<String, dynamic>;
        candles.add(
          DailyCandle(
            date: DateTime.parse(dateStr),
            open: double.parse(values['1. open'] as String),
            high: double.parse(values['2. high'] as String),
            low: double.parse(values['3. low'] as String),
            close: double.parse(values['4. close'] as String),
            volume: int.parse(values['5. volume'] as String),
          ),
        );
      }

      // Sort ascending by date
      candles.sort((a, b) => a.date.compareTo(b.date));

      stopwatch.stop();
      _logger.i(
        'Fetched ${candles.length} candles for $ticker in ${stopwatch.elapsedMilliseconds}ms',
      );

      return candles;
    } on DioException catch (e) {
      stopwatch.stop();
      _logger.e('Dio error fetching $ticker: ${e.message}');
      throw MarketDataException(
        e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
        isRetryable: e.type != DioExceptionType.badResponse,
      );
    }
  }
}
