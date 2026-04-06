# CrossTide — Development Roadmap

## Vision
CrossTide is a cross-platform stock monitoring toolkit that detects **moving-average crossover events** (SMA50 / SMA150 / SMA200), benchmarks ticker performance against the S&P 500, and empowers individual investors with actionable, real-time alerts — all without paid API keys.

---

## v1.1 — Multi-SMA Lines & Benchmark Comparison

### Chart Enhancements
- [ ] **SMA50 / SMA150 overlay lines** on ticker detail chart (toggle on/off)
- [ ] Color-coded lines: SMA50 (green), SMA150 (purple), SMA200 (orange)
- [ ] **S&P 500 benchmark overlay** — normalized percentage chart comparing ticker vs `^GSPC`
- [ ] Candlestick chart mode (OHLC bars alongside or instead of line chart)
- [ ] Volume bars below the price chart
- [ ] Chart time-range selector: 3M / 6M / 1Y / 2Y / 5Y / Max
- [ ] Pinch-to-zoom and pan on mobile
- [ ] Dark mode chart theme

### Cross-Up Detection Expansion
- [ ] Detect SMA50 and SMA150 cross-ups (not just SMA200)
- [ ] **Golden Cross** alert: SMA50 crosses above SMA200
- [ ] **Death Cross** alert: SMA50 crosses below SMA200
- [ ] User-selectable alert types per ticker (SMA200 cross-up, Golden Cross, etc.)

---

## v1.2 — Watchlist & Portfolio UX

### Watchlist Improvements
- [ ] **Watchlist groups** (e.g., "Tech", "Energy", "My Portfolio")
- [ ] Drag-to-reorder tickers
- [ ] Bulk add tickers (paste comma-separated list)
- [ ] Ticker search with auto-complete (fuzzy name + symbol)
- [ ] Market sector tags and color-coded badges

### Dashboard / Home Screen
- [ ] At-a-glance dashboard: tickers near SMA200, recent cross-ups, market status
- [ ] Heatmap — all watchlist tickers colored by distance-from-SMA200
- [ ] Sort/filter by: alphabetical, % above/below SMA, market cap, sector

---

## v1.3 — Advanced Technical Indicators

- [ ] **EMA (Exponential Moving Average)** — 12, 26, 50, 200 periods
- [ ] **RSI (Relative Strength Index)** — 14-day with overbought/oversold zones
- [ ] **MACD** — histogram + signal line
- [ ] **Bollinger Bands** — 20-day SMA ± 2σ
- [ ] Custom indicator builder — pick any SMA/EMA period
- [ ] Indicator panel below the main chart (split-pane layout)

---

## v1.4 — Notifications & Alert Engine

- [ ] **Price target alerts** — notify when price hits $X
- [ ] **Percentage move alerts** — notify on ±N% intraday move
- [ ] **Volume spike alerts** — 2× average daily volume
- [ ] Alert history timeline — scrollable log of all past alerts
- [ ] Export alert history to CSV
- [ ] Per-ticker notification sound customization
- [ ] **Telegram / Discord webhook** integration (push alerts to chat)
- [ ] Email digest — daily summary of watchlist status

---

## v1.5 — Data & Performance

- [ ] **Multiple data provider fallback chain** — Yahoo → AlphaVantage → Mock
- [ ] Intraday data support (1m / 5m / 15m candles)
- [ ] Pre-market / after-hours price display
- [ ] Offline mode — full SQLite cache, last-known data shown when offline
- [ ] Background sync optimization — delta fetch (only new candles)
- [ ] Data freshness indicator ("Updated 3 min ago")
- [ ] Rate-limit-aware request scheduler

---

## v1.6 — Platform & Distribution

### Android
- [ ] Widget: home-screen ticker card with SMA status
- [ ] Wear OS companion — wrist glance at cross-up alerts

### Windows
- [ ] System tray with popup summary
- [ ] Windows Task Scheduler integration for true background refresh
- [ ] MSIX packaging for Microsoft Store

### Cross-Platform
- [ ] **iOS** target (requires macOS build host)
- [ ] **macOS** desktop target
- [ ] **Web** target (Progressive Web App) — view-only dashboard
- [ ] Deep-link / universal-link support

---

## v1.7 — Social & Community Features

- [ ] **Share watchlist** — export/import as JSON or shareable link
- [ ] **Public leaderboard** — opt-in: "Most cross-ups caught this month"
- [ ] Community-curated watchlists (e.g., "ARK Innovation Picks")
- [ ] In-app news feed for watchlist tickers (RSS/Atom aggregation)

---

## v1.8 — AI & Smart Features

- [ ] **AI-powered pattern recognition** — flag similar historical SMA cross-up outcomes
- [ ] Sentiment analysis — aggregate news/social sentiment per ticker
- [ ] Smart notification timing — learn when user engages, deliver at optimal times
- [ ] Natural language ticker search ("show me tech stocks near their 200-day average")
- [ ] Copilot Chat integration — ask questions about your watchlist in-app

---

## v2.0 — Premium & Monetization (Optional)

- [ ] Unlimited watchlist tickers (free tier: 10)
- [ ] Real-time streaming quotes (WebSocket)
- [ ] Multi-device sync via Firebase/Supabase
- [ ] Custom alert rules DSL ("IF sma50 > sma200 AND rsi < 30 THEN alert")
- [ ] PDF report generation — weekly technical summary per watchlist
- [ ] Backtesting engine — "How did SMA200 cross-ups perform over 10 years?"

---

## Future Ideas (Backlog)

- Crypto support (BTC, ETH — via CoinGecko free API)
- Forex pairs
- Options chain viewer
- Earnings calendar integration
- Dividend tracker
- Multi-language localization (i18n)
- Accessibility audit (screen readers, high contrast)
- Plugin/extension system for community indicators
