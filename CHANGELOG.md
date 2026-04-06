# Changelog

All notable changes to CrossTide are documented in this file.  
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).  
Versioning follows [Semantic Versioning](https://semver.org/).

---

## [1.1.0] — 2025-07-14

### Added
- **Volume spike alerts** (S33) — fires when today's volume exceeds N× the 20-day
  average; configurable multiplier (1.5×–5.0×) in Settings. `VolumeCalculator`
  domain class with `averageVolume`, `isSpike`, `spikeRatio` methods. K/M volume
  formatting in notification body.
- **Alert history timeline** (S34) — `/alert-history` screen showing every fired alert
  with timestamp, symbol, type badge, and message. Swipe-to-dismiss acknowledges.
  `AlertHistoryTable` (Drift schema v9).
- **Export alert history** (S35) — export CSV or JSON from the history screen
  `PopupMenuButton`. Files saved to `getApplicationDocumentsDirectory()` with
  timestamp in filename. Copy path action in SnackBar. RFC 4180 CSV escaping.
- **Upcoming earnings indicator** (S36) — `_EarningsBadge` chip in the ticker detail
  AppBar title row. Fetches `calendarEvents` from Yahoo Finance quoteSummary API;
  red ≤3 days, orange ≤7 days, green otherwise. `TickerEntry.nextEarningsAt`
  nullable field; `isEarningsSoon()` helper. Drift schema v10.
- **Dynamic accent color** (S37) — 10-swatch color palette picker in Settings
  (Ocean Blue, Sky Blue, Teal, Green, Purple, Indigo, Deep Orange, Pink, Amber,
  Slate). Persisted as `AppSettings.accentColorValue` (Drift schema v11). Live
  `colorSchemeSeed` updates for both light and dark `MaterialApp` themes.
- **Deep-link support** (S38) — custom `crosstide://` URI scheme registered in
  Android `AndroidManifest.xml`. GoRouter `redirect` normalises
  `crosstide://ticker/AAPL` → `/ticker/AAPL`. `parseNotificationPayload` updated.
- **Crash log viewer** (S39) — `/crash-logs` route; full-screen monospace log viewer
  backed by `CrashLogService`. AppBar actions: copy to clipboard, delete with
  confirmation. Accessible via "View Crash Logs" button in Settings.

### Changed
- AppSettings now has 10 Equatable props (was 9) — added `accentColorValue`.
- TickerEntry now has 11 Equatable props (was 10) — added `nextEarningsAt`.
- Drift database schema bumped v9 → v10 → v11 with backward-compatible migrations.
- Settings screen: new Theme section (ThemeMode picker already present) extended
  with `_AccentColorPicker`; "View Crash Logs" diagnostic button added above footer.
- `MaterialApp.router` `colorSchemeSeed` driven by `accentColorProvider` (was
  hardcoded `const Color(0xFF0D47A1)`).
- `Color.value` → `.toARGB32()` and `withOpacity` → `withValues(alpha:)` to align
  with Flutter 3.27+ deprecations.

### Fixed
- `DailyCandle.volume` (`int`) properly converted to `double` throughout
  `VolumeCalculator` and notification service formatting.
- `AlertHistoryEntry` entity insertion order in `entities.dart` fixed after
  accidental overwrite.
- Package name in test imports corrected: `stock_alert` → `cross_tide`.

---

## [1.0.0] — 2025-07-08

### Added
- Initial release.
- SMA50 / SMA150 / SMA200 cross-up detection with idempotent alerting.
- Golden Cross / Death Cross alerts.
- Yahoo Finance provider — no API key required.
- Drift SQLite database with TTL cache.
- Riverpod state management, GoRouter navigation.
- Local notifications — Android channels + Windows desktop toasts.
- WorkManager background service (Android) + Timer  (Windows, while app is running).
- Alert profiles: Aggressive / Balanced / Conservative / Custom presets.
- HealthCheckService — startup diagnostics (network, DB, data freshness).
- S&P 500 benchmark overlay chart (normalized %).
- SMA overlay lines on ticker-detail chart (SMA50/150/200, togglable).
- Volume bars below price chart.
- Time-range selector: 3M / 6M / 1Y / 2Y / 5Y.
- Watchlist groups — organize tickers by sector/strategy.
- Drag-to-reorder tickers; bulk add (comma-separated).
- Price target alerts — per-ticker, DB-backed, dismissable.
- Percentage-move alerts — per-ticker ±% threshold, ▲/▼ direction.
- Advanced mode toggle (hide/show expert settings).
- MACD + RSI indicator panels below chart.
- Bollinger Bands overlay.
- EMA overlay lines (12/26/50/200).
- GitHub Actions CI/CD: lint, test, build MSIX (Windows) + APK (Android), release.
- Pre-commit hooks: dart format, analyze, secret scan.
- Clean Architecture (domain / data / application / presentation) with strict
  layer-boundary enforcement.
- 147 passing unit tests (domain layer fully covered).
