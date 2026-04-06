// CrossTide — Cross-platform SMA crossover monitor.
//
// Architecture: Clean Architecture with Riverpod for DI/state management.
//   /domain   — Pure business logic (SMA calc, cross-up detection, alert FSM)
//   /data     — Providers, persistence (Drift/SQLite), repository
//   /application — Services (refresh, notifications, background)
//   /presentation — UI (screens, router, Riverpod providers)
//
// Targets: Android (WorkManager background) + Windows (timer + tray mode).
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

import 'src/presentation/presentation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final logger = Logger();

  // Load .env (non-fatal if missing; keys come from secure storage at runtime)
  try {
    await dotenv.load();
  } catch (e) {
    logger.w('.env file not found — using secure storage for keys');
  }

  // Create the Riverpod container
  final container = ProviderContainer();

  // Initialize notification service with deep-link handler
  final notificationService = container.read(notificationServiceProvider);
  await notificationService.initialize(
    onTap: (payload) {
      final route = parseNotificationPayload(payload);
      if (route != null) {
        appRouter.go(route);
      }
    },
  );

  // Initialize background service
  final bgService = container.read(backgroundServiceProvider);
  try {
    final repo = await container.read(repositoryProvider.future);
    final settings = await repo.getSettings();
    await bgService.initialize(
      refreshIntervalMinutes: settings.refreshIntervalMinutes,
    );

    // On Windows, start the in-app refresh timer
    if (Platform.isWindows) {
      final refreshService = await container.read(
        refreshServiceProvider.future,
      );
      bgService.startWindowsRefreshLoop(
        refreshService: refreshService,
        intervalMinutes: settings.refreshIntervalMinutes,
      );
    }
  } catch (e, st) {
    logger.e(
      'Failed to initialize background service',
      error: e,
      stackTrace: st,
    );
  }

  // Check onboarding status
  bool showOnboarding;
  try {
    showOnboarding = !(await container.read(onboardingCompleteProvider.future));
  } catch (_) {
    showOnboarding = true;
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: StockAlertApp(showOnboarding: showOnboarding),
    ),
  );
}

class StockAlertApp extends StatelessWidget {
  const StockAlertApp({super.key, this.showOnboarding = false});

  final bool showOnboarding;

  @override
  Widget build(BuildContext context) {
    // Override initial location if onboarding needed
    final router = showOnboarding
        ? GoRouter(
            initialLocation: '/onboarding',
            routes: appRouter.configuration.routes,
          )
        : appRouter;

    return MaterialApp.router(
      title: 'CrossTide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      routerConfig: router,
    );
  }
}
