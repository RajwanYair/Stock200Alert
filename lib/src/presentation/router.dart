/// Router — go_router configuration with deep-link support.
library;

import 'package:go_router/go_router.dart';

import 'screens/onboarding_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/ticker_detail_screen.dart';
import 'screens/ticker_list_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'tickerList',
      builder: (context, state) => const TickerListScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/ticker/:symbol',
      name: 'tickerDetail',
      builder: (context, state) {
        final symbol = state.pathParameters['symbol'] ?? '';
        return TickerDetailScreen(symbol: symbol);
      },
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

/// Parse notification payload to extract deep-link route.
/// Payload format: "ticker:AAPL"
String? parseNotificationPayload(String? payload) {
  if (payload == null) return null;
  if (payload.startsWith('ticker:')) {
    final symbol = payload.substring(7);
    return '/ticker/$symbol';
  }
  return null;
}
