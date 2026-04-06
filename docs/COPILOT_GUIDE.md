# Copilot Guide for Stock Alert

Coding conventions, prompt patterns, and guardrails for using GitHub Copilot effectively in this project.

## Coding Conventions

- **Dart style**: Follow `analysis_options.yaml` (prefer single quotes, const constructors, final locals)
- **Architecture**: Domain logic is pure Dart — no Flutter imports in `/domain/`
- **State management**: Riverpod — use `Provider`, `FutureProvider`, `StreamProvider`
- **Navigation**: GoRouter — define routes in `router.dart`
- **Persistence**: Drift — tables in `database.dart`, queries as methods on `AppDatabase`
- **Networking**: Dio with the `IMarketDataProvider` abstraction
- **Tests**: Domain logic must have tests. Test-first for new indicators/rules.

## Useful Copilot Prompts

### Add a new market data provider

```
Implement IMarketDataProvider for [Twelve Data / IEX Cloud].
Follow the pattern in alpha_vantage_provider.dart.
Parse the API response into List<DailyCandle> sorted ascending by date.
Handle rate limits and errors with MarketDataException.
Document the API's rate limits and required key.
```

### Add a new technical indicator

```
Create a pure Dart class in lib/src/domain/ that computes [EMA / RSI / MACD].
Follow SmaCalculator pattern: constructor is const, compute() returns nullable.
Add unit tests in test/domain/ covering: exact values, insufficient data, edge cases.
```

### Add a new screen

```
Create a ConsumerStatefulWidget in lib/src/presentation/screens/.
Add a GoRoute in router.dart.
Use ref.watch() for reactive state and ref.read() for actions.
Follow the pattern in ticker_list_screen.dart.
```

### Write tests for domain logic

```
Write unit tests for [class name] in test/domain/.
Cover: normal operation, edge cases (empty input, insufficient data),
boundary values (exactly N items), and error conditions.
Use _makeCandles helper to build test data.
```

## Guardrails

- **No secrets**: Never generate, hardcode, or suggest API keys in code
- **Test-first for domain**: Always write tests before or alongside domain logic
- **No side effects in domain**: Domain classes must be pure — no network, no DB, no Flutter
- **Type safety**: Use Drift's type-safe queries; avoid raw SQL
- **Error handling**: Wrap provider calls in try/catch; log errors; never crash background tasks

## Architecture Boundaries

| Layer | Can depend on | Cannot depend on |
|-------|--------------|-----------------|
| Domain | dart:core, equatable | Flutter, data, application, presentation |
| Data | Domain, drift, dio | Application, presentation |
| Application | Domain, data | Presentation |
| Presentation | All layers | — |
