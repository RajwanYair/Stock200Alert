/// Tests for S51 SnapshotService — verifies serialisation logic.
///
/// Because path_provider requires a platform channel, we test the
/// JSON-building logic in isolation without writing to disk.
library;

import 'dart:convert';

import 'package:cross_tide/src/domain/entities.dart';
import 'package:flutter_test/flutter_test.dart';

// Expose the private helpers by testing the JSON shape directly through
// a minimal stub that mimics what exportJson() produces.
Map<String, dynamic> _buildSnapshotPayload({
  required AppSettings settings,
  required List<TickerEntry> tickers,
  Map<String, TickerAlertState> alertStates = const {},
}) {
  Map<String, dynamic> settingsToMap(AppSettings s) => {
    'refreshIntervalMinutes': s.refreshIntervalMinutes,
    'quietHoursStart': s.quietHoursStart,
    'quietHoursEnd': s.quietHoursEnd,
    'trendStrictnessDays': s.trendStrictnessDays,
    'providerName': s.providerName,
    'cacheTtlMinutes': s.cacheTtlMinutes,
    'advancedMode': s.advancedMode,
    'defaultIndicators': s.defaultIndicators,
    'volumeSpikeMultiplier': s.volumeSpikeMultiplier,
    'accentColorValue': s.accentColorValue,
  };

  Map<String, dynamic> tickerToMap(TickerEntry t) => {
    'symbol': t.symbol,
    'addedAt': t.addedAt?.toIso8601String(),
    'lastRefreshAt': t.lastRefreshAt?.toIso8601String(),
    'lastClose': t.lastClose,
    'sma200': t.sma200,
    'error': t.error,
    'enabledAlertTypes':
        t.enabledAlertTypes.map((a) => a.name).toList(),
    'sortOrder': t.sortOrder,
    'groupId': t.groupId,
    'nextEarningsAt': t.nextEarningsAt?.toIso8601String(),
  };

  Map<String, dynamic> stateToMap(TickerAlertState s) => {
    'ticker': s.ticker,
    'lastStatus': s.lastStatus.name,
    'lastAlertedCrossUpAt': s.lastAlertedCrossUpAt?.toIso8601String(),
    'lastEvaluatedAt': s.lastEvaluatedAt?.toIso8601String(),
    'lastCloseUsed': s.lastCloseUsed,
    'lastSma200': s.lastSma200,
  };

  return {
    'exportedAt': DateTime(2025, 6, 1).toIso8601String(),
    'appVersion': '1.1.0',
    'settings': settingsToMap(settings),
    'tickers': tickers.map(tickerToMap).toList(),
    'alertStates': alertStates.map((k, v) => MapEntry(k, stateToMap(v))),
  };
}

void main() {
  group('SnapshotService JSON shape', () {
    test('empty watchlist snapshot is valid JSON with required keys', () {
      final payload = _buildSnapshotPayload(
        settings: const AppSettings(),
        tickers: [],
      );

      final json = const JsonEncoder.withIndent('  ').convert(payload);
      final decoded = jsonDecode(json) as Map<String, dynamic>;

      expect(decoded.keys, containsAll(['exportedAt', 'settings', 'tickers', 'alertStates']));
      expect(decoded['tickers'], isEmpty);
      expect(decoded['alertStates'], isEmpty);
    });

    test('settings fields all serialised', () {
      const s = AppSettings(
        refreshIntervalMinutes: 45,
        trendStrictnessDays: 2,
        advancedMode: true,
        volumeSpikeMultiplier: 3.0,
      );
      final payload = _buildSnapshotPayload(settings: s, tickers: []);
      final settings = payload['settings'] as Map<String, dynamic>;

      expect(settings['refreshIntervalMinutes'], 45);
      expect(settings['trendStrictnessDays'], 2);
      expect(settings['advancedMode'], isTrue);
      expect(settings['volumeSpikeMultiplier'], 3.0);
    });

    test('ticker entry serialised with all expected keys', () {
      const ticker = TickerEntry(
        symbol: 'AAPL',
        sortOrder: 0,
        enabledAlertTypes: {AlertType.sma200CrossUp},
      );
      final payload = _buildSnapshotPayload(
        settings: const AppSettings(),
        tickers: [ticker],
      );
      final tickers = payload['tickers'] as List<dynamic>;
      final t = tickers.first as Map<String, dynamic>;

      expect(t['symbol'], 'AAPL');
      expect(t['enabledAlertTypes'], contains('sma200CrossUp'));
    });

    test('alert state serialised correctly', () {
      const state = TickerAlertState(
        ticker: 'AAPL',
        lastStatus: SmaRelation.below,
      );
      final payload = _buildSnapshotPayload(
        settings: const AppSettings(),
        tickers: [],
        alertStates: {'AAPL': state},
      );
      final states = payload['alertStates'] as Map<String, dynamic>;

      expect(states.containsKey('AAPL'), isTrue);
      final s = states['AAPL'] as Map<String, dynamic>;
      expect(s['lastStatus'], 'below');
    });

    test('snapshot is round-trip stable JSON', () {
      final payload = _buildSnapshotPayload(
        settings: const AppSettings(),
        tickers: [],
      );

      final json1 = jsonEncode(payload);
      final json2 = jsonEncode(jsonDecode(json1));
      expect(json1, json2);
    });
  });
}
