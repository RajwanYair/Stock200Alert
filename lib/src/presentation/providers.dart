/// Riverpod Providers — Dependency injection and state management.
///
/// Why Riverpod: Compile-time safety, no BuildContext dependency for providers,
/// excellent testability (override any provider), auto-dispose, and first-class
/// async support. Preferred over Bloc for this project's read-heavy, event-light
/// architecture.
library;

import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

import '../data/data.dart';
import '../application/application.dart';
import '../domain/entities.dart' as domain;

// ---------------------------------------------------------------------------
// Core singletons
// ---------------------------------------------------------------------------

final loggerProvider = Provider<Logger>((ref) => Logger());

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

// ---------------------------------------------------------------------------
// API key management
// ---------------------------------------------------------------------------

final apiKeyProvider = FutureProvider<String?>((ref) async {
  final storage = ref.watch(secureStorageProvider);
  return storage.read(key: 'market_data_api_key');
});

// ---------------------------------------------------------------------------
// Market data provider
// ---------------------------------------------------------------------------

final marketDataProviderProvider = FutureProvider<IMarketDataProvider>((
  ref,
) async {
  final db = ref.watch(databaseProvider);
  final settings = await db.getSettings();
  final providerName = settings?.providerName ?? 'alpha_vantage';

  if (providerName == 'mock') {
    return MockMarketDataProvider();
  }

  final storage = ref.watch(secureStorageProvider);
  final apiKey = await storage.read(key: 'market_data_api_key') ?? '';
  if (apiKey.isEmpty) {
    return MockMarketDataProvider();
  }

  return AlphaVantageProvider(apiKey: apiKey, logger: ref.read(loggerProvider));
});

// ---------------------------------------------------------------------------
// Repository
// ---------------------------------------------------------------------------

final repositoryProvider = FutureProvider<StockRepository>((ref) async {
  final db = ref.watch(databaseProvider);
  final provider = await ref.watch(marketDataProviderProvider.future);
  return StockRepository(
    db: db,
    provider: provider,
    logger: ref.read(loggerProvider),
  );
});

// ---------------------------------------------------------------------------
// Services
// ---------------------------------------------------------------------------

final notificationServiceProvider = Provider<INotificationService>((ref) {
  return LocalNotificationService(logger: ref.read(loggerProvider));
});

final refreshServiceProvider = FutureProvider<RefreshService>((ref) async {
  final repo = await ref.watch(repositoryProvider.future);
  return RefreshService(
    repository: repo,
    notificationService: ref.read(notificationServiceProvider),
    logger: ref.read(loggerProvider),
  );
});

final backgroundServiceProvider = Provider<BackgroundService>((ref) {
  return BackgroundService(logger: ref.read(loggerProvider));
});

// ---------------------------------------------------------------------------
// Ticker list state
// ---------------------------------------------------------------------------

final tickerListProvider = StreamProvider<List<Ticker>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllTickers();
});

// ---------------------------------------------------------------------------
// Settings state
// ---------------------------------------------------------------------------

final settingsProvider = FutureProvider<domain.AppSettings>((ref) async {
  final repo = await ref.watch(repositoryProvider.future);
  return repo.getSettings();
});

// ---------------------------------------------------------------------------
// Ticker detail state
// ---------------------------------------------------------------------------

final tickerCandlesProvider =
    FutureProvider.family<List<domain.DailyCandle>, String>((
      ref,
      ticker,
    ) async {
      final repo = await ref.watch(repositoryProvider.future);
      return repo.fetchAndCacheCandles(ticker);
    });

final tickerAlertStateProvider =
    FutureProvider.family<domain.TickerAlertState, String>((ref, ticker) async {
      final repo = await ref.watch(repositoryProvider.future);
      return repo.getAlertState(ticker);
    });

// ---------------------------------------------------------------------------
// Refresh action
// ---------------------------------------------------------------------------

final refreshAllProvider = FutureProvider<Map<String, bool>>((ref) async {
  final service = await ref.watch(refreshServiceProvider.future);
  return service.refreshAll();
});

// ---------------------------------------------------------------------------
// Has completed onboarding
// ---------------------------------------------------------------------------

final onboardingCompleteProvider = FutureProvider<bool>((ref) async {
  final storage = ref.watch(secureStorageProvider);
  final val = await storage.read(key: 'onboarding_complete');
  return val == 'true';
});

// ---------------------------------------------------------------------------
// Platform info
// ---------------------------------------------------------------------------

final isWindowsProvider = Provider<bool>((ref) => Platform.isWindows);
final isAndroidProvider = Provider<bool>((ref) => Platform.isAndroid);
