# Stock Alert — SMA200 Cross-Up Monitor

Cross-platform Flutter app that monitors stock tickers for **200-day Simple Moving Average (SMA200) cross-up events** and fires local notifications. Targets **Android** + **Windows** from a single codebase.

> ⚠️ **Disclaimer**: This app is for informational and educational purposes only. It is NOT financial advice. Always do your own research.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     Presentation                        │
│  Screens │ Riverpod Providers │ GoRouter │ FL Chart      │
├─────────────────────────────────────────────────────────┤
│                     Application                         │
│  RefreshService │ NotificationService │ BackgroundService│
├─────────────────────────────────────────────────────────┤
│                       Domain                            │
│  SmaCalculator │ CrossUpDetector │ AlertStateMachine     │
│  Entities (DailyCandle, TickerAlertState, AppSettings)  │
├─────────────────────────────────────────────────────────┤
│                        Data                             │
│  IMarketDataProvider │ AlphaVantageProvider │ MockProvider│
│  StockRepository │ Drift/SQLite Database                 │
└─────────────────────────────────────────────────────────┘

Background Execution:
  Android → WorkManager (periodic, battery-aware, network-required)
  Windows → Timer.periodic (in-app, while running / system tray mode)
```

## Cross-Up Rule (KEY LOGIC)

```
close[t]   = latest trading day close
sma200[t]  = SMA of last 200 trading closes up to and including t (inclusive)

Cross-up:  close[t-1] <= sma200[t-1]  AND  close[t] > sma200[t]
Rising:    close[t] > close[t-1]  (configurable: 1–5 day trend strictness)
Alert:     Cross-up AND Rising AND not already alerted for this cross-up event
```

Alert is **idempotent**: fires once per cross-up event. Only fires again after the price crosses back below SMA200 and then crosses up again.

## Prerequisites

- **Flutter SDK** ≥ 3.16.0 (stable channel)
- **Android**: Android Studio or Android SDK with API 21+
- **Windows**: Visual Studio 2022 with "Desktop development with C++" workload
- **Git**

## Setup

```bash
# 1. Clone the repo
git clone <repo-url> && cd stock_alert

# 2. Copy environment file
cp .env.example .env
# Edit .env with your Alpha Vantage API key (or leave blank for mock data)

# 3. Install dependencies
flutter pub get

# 4. Generate code (Drift database, Freezed models)
dart run build_runner build --delete-conflicting-outputs

# 5. Run on Windows
flutter run -d windows

# 6. Run on Android emulator
flutter run -d emulator

# 7. Run tests
flutter test
```

## Market Data Provider

**Alpha Vantage** (default):
- Free tier: 25 requests/day, 5 requests/minute
- Get API key: https://www.alphavantage.co/support/#api-key
- Uses `TIME_SERIES_DAILY` with `outputsize=full`

**Mock Provider**: Generates synthetic data for offline development and testing.

The provider interface (`IMarketDataProvider`) is abstracted — swap in Twelve Data, IEX Cloud, or any other source by implementing the interface.

## Project Structure

```
lib/
├── main.dart                          # Entry point + bootstrap
└── src/
    ├── domain/                        # Pure business logic
    │   ├── entities.dart              # Value objects
    │   ├── sma_calculator.dart        # SMA computation
    │   ├── cross_up_detector.dart     # Cross-up detection
    │   └── alert_state_machine.dart   # Alert lifecycle FSM
    ├── data/                          # Data access layer
    │   ├── database/database.dart     # Drift schema + queries
    │   ├── providers/                 # Market data providers
    │   │   ├── market_data_provider.dart  # Interface
    │   │   ├── alpha_vantage_provider.dart
    │   │   └── mock_provider.dart
    │   └── repository.dart            # Cache + orchestration
    ├── application/                   # Services
    │   ├── refresh_service.dart       # Fetch → compute → alert
    │   ├── notification_service.dart  # Local notifications
    │   └── background_service.dart    # WorkManager + Timer
    └── presentation/                  # UI layer
        ├── providers.dart             # Riverpod providers
        ├── router.dart                # GoRouter config
        └── screens/
            ├── onboarding_screen.dart
            ├── ticker_list_screen.dart
            ├── ticker_detail_screen.dart
            └── settings_screen.dart

test/
└── domain/
    ├── sma_calculator_test.dart
    ├── cross_up_detector_test.dart
    └── alert_state_machine_test.dart
```

## Background Execution

| Platform | Mechanism | Limitations |
|----------|-----------|-------------|
| Android | `workmanager` periodic task | Min 15-min interval; OS may defer; requires network + battery not low |
| Windows | `Timer.periodic` in-app | Only works while app is running (foreground or tray mode) |

**Windows tray mode**: When enabled, the app minimizes to the system tray instead of closing, continuing periodic refresh via `Timer.periodic`.

**Future enhancement** (not implemented): A separate Windows helper process or Windows Task Scheduler entry could enable true background execution when the app is closed.

## Notifications

Uses `flutter_local_notifications`:
- **Android**: Notification channel with high importance; requests POST_NOTIFICATIONS permission on Android 13+
- **Windows**: Toast notifications; `cancel()` and `getActiveNotifications()` require MSIX package identity (handled gracefully)
- **Deep-link**: Tapping a notification navigates to the ticker detail screen

## Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| State management | Riverpod | Compile-safe, no BuildContext for providers, excellent testability, auto-dispose |
| Persistence | Drift (SQLite) | Type-safe queries, migration support, in-memory databases for testing |
| Notifications | flutter_local_notifications | Single plugin for Windows toasts + Android channels |
| Background (Android) | workmanager | Mature plugin for periodic tasks with OS constraints |

## License

MIT — see [LICENSE](LICENSE).
