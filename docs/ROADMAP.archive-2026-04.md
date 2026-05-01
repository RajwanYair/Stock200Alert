# CrossTide — Strategic Roadmap (Deep Rethink)

> **Last updated:** April 25, 2026
> **Current declared version:** v6.0.0 (per `package.json`)
> **Actual maturity:** v6.0-rc — toolchain migrated, domain layer complete (~40 modules,
> ~98% coverage), feature cards mostly scaffolded but not wired, Worker proxy authored
> but not deployed.
> **Next target:** v6.1 *Best-in-Class Web Dashboard* — every decision below has been
> re-examined and is either reaffirmed, refined, or replaced.

This document supersedes the previous roadmap. It is the result of a deep rethink of
**every** architectural, tooling, and product decision taken so far — including the
"clean" ones — and consolidates outstanding work from earlier phases.

---

## Table of Contents

1. [State of the Project (Honest Audit)](#1-state-of-the-project-honest-audit)
2. [Decision Rethink Matrix](#2-decision-rethink-matrix)
3. [Best-in-Class Comparison](#3-best-in-class-comparison)
4. [Best Practices Harvested](#4-best-practices-harvested)
5. [Target Architecture (v6.1+)](#5-target-architecture-v61)
6. [Frontend Strategy](#6-frontend-strategy)
7. [Backend & Data Strategy](#7-backend--data-strategy)
8. [Storage & Sync Strategy](#8-storage--sync-strategy)
9. [Quality, Security & Observability](#9-quality-security--observability)
10. [Performance Budget](#10-performance-budget)
11. [Developer Experience](#11-developer-experience)
12. [Phased Roadmap](#12-phased-roadmap)
13. [Outstanding Work Consolidated from v5/v6](#13-outstanding-work-consolidated-from-v5v6)
14. [Decisions Reaffirmed / Reversed / New](#14-decisions-reaffirmed--reversed--new)
15. [Scope Boundaries](#15-scope-boundaries)
16. [Appendix: Flutter Archive](#16-appendix-flutter-archive)

---

## 1. State of the Project (Honest Audit)

### 1.1 What is genuinely done

| Area | Status | Notes |
|------|--------|-------|
| Domain layer (12 calculators + 12 methods + consensus + alerts + backtest) | ✅ Ported | `src/domain/*` — pure, tested |
| Unit tests (~40 files, ~500+ tests) | ✅ | 98%+ statements on covered modules |
| Toolchain shared with `MyScripts/tooling/*` | ✅ | TS 6, Vite 8, Vitest 4, ESLint 10 (per CHANGELOG) |
| Cloudflare Worker source (Yahoo / Twelve / CoinGecko / Polygon) | ✅ Authored | Not yet deployed; no integration tests |
| PWA scaffold (manifest + `sw.ts`) | ✅ Scaffold | SW is minimal precache + SWR; no Workbox/Background Sync |
| IndexedDB tier (`core/idb.ts`, `core/tiered-cache.ts`) | ✅ | Used internally; no LRU eviction yet |
| Card scaffolds (15 in `src/cards/*`) | ⚠️ Skeleton | Render summaries, not real charts/tables |
| `main.ts` bootstrap | ⚠️ Minimal | Only watchlist + theme + add/remove are wired |

### 1.2 What is missing or weak

- **No real charting** — `chart.ts` renders an OHLC table. Lightweight Charts is not a
  dependency yet.
- **Card registry not connected** — cards exist as files but `main.ts` does not
  lazy-load or compose them.
- **No live data path** — provider chain exists in code, but the Worker is not deployed
  and the browser still uses mock/cached candles in tests only.
- **No E2E tests** — `tests/` has no `e2e/` folder despite the plan.
- **No accessibility tests** — `axe-core` not integrated; only `a11y.css` exists.
- **No error tracking, no analytics, no Lighthouse CI** — claimed in roadmap, not in CI.
- **No streaming / WebSocket** — only polling.
- **No auth / cloud sync** — fine for v6.0 but blocks multi-device users.
- **No Web Worker offload** — backtests and full-history indicator scans run on the
  main thread.
- **Hash-based router** — works on GitHub Pages but fights deep linking, share URLs,
  SEO, and modern PWA navigation.
- **No i18n / RTL** — Hebrew was promised; nothing in the build.
- **No design system documentation** — tokens exist, but no Storybook / catalog.
- **Bundle budget unverified** — `check:bundle` exists but real LH score unknown.

This audit is the basis for everything below.

---

## 2. Decision Rethink Matrix

Every prior decision is re-examined. **Verdict** = `Keep` / `Refine` / `Replace`.

| # | Decision (current) | Verdict | Rationale & Action |
|---|--------------------|---------|---------------------|
| D1 | **Vanilla TS, no UI framework** | **Refine** | Keep zero-framework core, but adopt **Preact Signals** (`@preact/signals-core`, ~1.4 KB) for fine-grained reactivity instead of hand-rolled `EventTarget` pub/sub. Optional **Lit** (~5 KB) only for complex, reusable cards (chart toolbar, screener filter builder). Vanilla wins for cards that are mostly pure DOM. |
| D2 | **Hash-based router** | **Replace** | Move to **History API** with a fallback for GH Pages 404 (`404.html` redirect trick) or — better — host on **Cloudflare Pages** which supports SPA fallback natively. Enables real share URLs, OG previews, and clean deep links. |
| D3 | **EventTarget reactive store** | **Replace** | Replace with a thin `signal()`/`computed()`/`effect()` layer. Same DX, fine-grained DOM updates, no manual diffing. Wrap `localStorage` and `IndexedDB` as persistent signals. |
| D4 | **Vanilla CSS + tokens + `@layer`** | **Keep + Augment** | Tokens are correct. Add **OpenProps**-style scale, container queries, `:has()` patterns, and a **design-token export** (`tokens.json`) usable by the docs site. Reject Tailwind/UnoCSS — adds toolchain cost without payoff for our card system. |
| D5 | **Lightweight Charts (TradingView OSS)** | **Keep** | 40 KB, OHLC native, MIT. Confirmed best fit. Action: actually integrate it (currently absent from deps). Lazy-load via `import()`. Reject ECharts (250 KB) and D3 (own everything). |
| D6 | **Cloudflare Workers proxy** | **Keep + Extend** | Add **Durable Objects** for per-symbol WebSocket fan-out; add **R2** for cold history (>1 yr OHLC). Reject Vercel Edge (worse free tier for this use case). |
| D7 | **Yahoo Finance v8 (unofficial)** | **Refine** | Keep as primary for free tier, but add **Finnhub** (60 req/min free) as 2nd-tier and **Alpha Vantage** as 3rd. Polygon stays as paid escape hatch. Treat Yahoo as best-effort — never a contract. |
| D8 | **No backend / no auth (v6.0)** | **Refine** | Keep "no account required" as default. Add **optional Passkeys-only auth** in Phase 4 backed by Cloudflare Workers + KV — no passwords, no email required. Cloud sync is opt-in. |
| D9 | **GitHub Pages deploy** | **Replace** | Move to **Cloudflare Pages** + Workers. Same `$0/mo`, but native SPA fallback, instant rollback, preview deploys per PR, edge functions co-located with the proxy. |
| D10 | **Service Worker hand-rolled** | **Refine** | Replace ad-hoc `sw.ts` with **Workbox** (precache, runtime caching, Background Sync queue for failed POSTs, Navigation Preload). Adds ~10 KB but eliminates a class of bugs. |
| D11 | **Polling-only data** | **Extend** | Add **WebSocket streaming** (Finnhub or Polygon) behind a feature flag. Fall back to polling on disconnect. |
| D12 | **No Web Workers** | **Replace** | Move backtest engine, full-history indicator scans, and screener evaluation into a **dedicated Web Worker** with `comlink` (~1 KB). Keeps UI at 60 fps even on 5y daily backtests. |
| D13 | **`localStorage` + raw IndexedDB** | **Refine** | Keep tiered cache, but wrap IndexedDB with **`idb-keyval`** (~600 B) or our existing `idb.ts` only — reject Dexie (15 KB) for our schema. Add **LRU eviction** + storage-pressure handling (`navigator.storage.estimate()`). |
| D14 | **No runtime validation** | **Add** | Adopt **Zod** at every external boundary (provider responses, config import, URL state). ~12 KB but pays for itself in correctness. Branded types for `Ticker`, `ISODate`, `Price`. |
| D15 | **No error tracking** | **Add** | Self-hosted **GlitchTip** (Sentry-compatible, AGPL) on Fly.io or local Worker. Free, privacy-respecting. Sample rate < 100%. |
| D16 | **No telemetry** | **Add** | **Plausible** or **Umami** (self-hosted, cookieless). Track route changes, card mounts, error rates. No PII. |
| D17 | **No Lighthouse CI** | **Add** | `lhci autorun` in GH Actions with budgets file; fail PR on regression. |
| D18 | **No E2E tests** | **Add** | **Playwright** for 8–10 critical flows (add ticker, view chart, run backtest, toggle theme, offline mode). |
| D19 | **No a11y tests** | **Add** | `@axe-core/playwright` per E2E run; `vitest-axe` for component-level. WCAG 2.2 AA target. |
| D20 | **Manual versioning + CHANGELOG** | **Refine** | Adopt **Changesets** — every PR adds a changeset; release PR is auto-generated. Keeps SemVer honest. |
| D21 | **Local devDeps removed; shared MyScripts toolchain** | **Keep** | Reaffirmed — major DX win, single source of truth. Document escape hatch for tools we genuinely need locally. |
| D22 | **No Storybook / component catalog** | **Add (light)** | A single `/dev/components.html` page that mounts every card with mock data. Cheaper than Storybook, sufficient for vanilla TS. |
| D23 | **No CSP / SRI / supply-chain checks** | **Add** | CSP via Worker headers, SRI for any third-party CDN asset, **`socket.dev`** or `npm audit signatures` in CI. |
| D24 | **No i18n** | **Add (Phase 4)** | **`@formatjs/intl`** + ICU messages. English + Hebrew with RTL. Tokens already direction-agnostic. |
| D25 | **Markdown-only docs** | **Refine** | Add a tiny **Astro Starlight** docs site at `/docs/` deployed alongside app, with searchable indicator reference + API contracts. |
| D26 | **Single-tenant browser app** | **Keep** | No multi-user features in core. Cloud sync is per-user, opt-in, isolated. |
| D27 | **TypeScript strict** | **Keep + Tighten** | Enable `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`, `noPropertyAccessFromIndexSignature` if not already. Add `tsd` for public-API type tests. |
| D28 | **Vitest only** | **Keep** | + `vitest-axe`, `vitest-fetch-mock`, `@vitest/browser` for the 5% of tests that need a real browser. |
| D29 | **Manual provider health tracking** | **Refine** | Move to a tiny **circuit breaker** (closed/open/half-open) per provider, persisted in IndexedDB. Surface in Provider Health card. |
| D30 | **No docs for indicators** | **Add** | Per-indicator MDX in docs site: formula (KaTeX), defaults, references, test vectors. |

---

## 3. Best-in-Class Comparison

A focused comparison against the apps users will actually compare us against.

| Capability | **CrossTide (target v6.1)** | TradingView | FinViz | StockAnalysis | Koyfin | thinkorswim | Webull | GhostFolio | Yahoo Finance |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| Cost | Free / OSS | Freemium | Freemium | Freemium | Paid | Free (Schwab) | Free | OSS / Paid | Free |
| Real-time data | WebSocket (opt-in) | ✅ | Paid | ✅ | ✅ | ✅ | ✅ | EOD | Delayed |
| Candlestick + overlays | ✅ (LWC) | ✅✅✅ | static | ✅ | ✅✅ | ✅✅ | ✅ | ❌ | ✅ |
| Indicators | 12 methods + 12 calcs | 100+ | 50+ | 30+ | 80+ | 400+ | 50+ | 0 | ~10 |
| Multi-method **consensus engine** | ✅ unique | ❌ | ❌ | analyst-only | ❌ | ❌ | ❌ | ❌ | ❌ |
| Screener | Preset + custom | ✅ | best-in-class | ✅ | ✅ | ✅ | ✅ | ❌ | basic |
| Sector heatmap | Canvas treemap | ✅ | iconic | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Backtest engine | ✅ in-browser (Worker) | Pine Script | ❌ | ❌ | ✅ | thinkScript | ❌ | ❌ | ❌ |
| Portfolio + risk metrics | Sharpe / Sortino / DD | ❌ | ❌ | ✅ | ✅ | brokerage | brokerage | best-in-class | ✅ |
| Alerts (price + indicator) | ✅ + browser push | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ |
| Offline / PWA | ✅ Workbox | ❌ | ❌ | ❌ | ❌ | desktop | ❌ | ✅ | ❌ |
| Open source | MIT | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | AGPL | ❌ |
| Self-hostable | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | Docker | ❌ |
| No-account default | ✅ | limited | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | partial |
| Privacy (no tracking) | ✅ cookieless | ❌ | ads | ads | ❌ | broker | broker | ✅ | ads |
| Bundle size (initial JS) | <180 KB gz | ~5 MB | server-rendered | ~2 MB | ~3 MB | desktop | ~3 MB | ~500 KB | ~4 MB |
| Keyboard-first | ✅ (j/k, /, 1-9) | ✅ | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ |
| Accessible (WCAG AA) | ✅ tested | partial | ❌ | partial | partial | ❌ | partial | ✅ | partial |
| Multi-provider failover | ✅ circuit breaker | proprietary | proprietary | proprietary | proprietary | broker | broker | varies | proprietary |
| Per-asset deep-link share | History API + OG | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ | ✅ |

**Where we win:** OSS, self-hostable, consensus engine, offline, privacy, cost, bundle.
**Where we must close gaps:** real-time depth, indicator breadth, screener power,
charting polish.

---

## 4. Best Practices Harvested

| Practice | Source | Action in CrossTide |
|---|---|---|
| Treemap heatmap colored by % change | FinViz, TradingView | Canvas treemap card; click → chart |
| Multi-pane chart (price + sub-indicators) | TradingView, Koyfin | LWC + sub-panes via `chart-panels.ts` |
| Drawing tools (trendline, fib) | TradingView | Phase 4, optional `lightweight-charts-drawing` plugin |
| Pine-Script-style custom signals | TradingView | Mini DSL → AST → run in Web Worker (Phase 4 stretch) |
| 52-week range progress bar | StockAnalysis, Webull | Watchlist column |
| Sparklines in tables | FinViz, Robinhood | SVG `<path>` per row, no library |
| Risk dashboard (Sharpe, Sortino, max DD, beta) | GhostFolio, Koyfin | Reuse `analytics.ts`; render in Portfolio card |
| Benchmark comparison (vs SPY) | GhostFolio | Portfolio card overlay |
| Dividend projection | StockAnalysis, Webull | Optional Phase 3 |
| Preset screeners ("oversold", "breakout") | FinViz | `cards/preset-filters.ts` already scaffolded — finish |
| Keyboard nav: `j/k`, `/` search, `g h` go-home | TradingView, GitHub | Already scaffolded in `core/keyboard.ts` |
| Command palette (`⌘K`) | Linear, Raycast, GitHub | Add — fuzzy ticker + action search |
| Stale-while-revalidate caching | Workbox, SWR | Already in SW; tighten with Workbox |
| Stale-data badge | Robinhood | Already planned — render `(stale 12s)` |
| Optimistic UI on add/remove | Linear, Notion | Use signals + rollback on error |
| Cookieless analytics | Plausible, Fathom | Self-host Plausible or Umami |
| Passkey auth (no passwords) | Apple, GitHub | Phase 4 cloud sync |
| Background Sync for queued mutations | Workbox | Sync portfolio edits when offline |
| OG image per share URL | TradingView, Linear | Cloudflare Worker → render PNG of mini chart |
| Per-PR preview deploys | Vercel, CF Pages | CF Pages handles natively |
| Changesets-driven releases | npm OSS norm | Adopt |

---

## 5. Target Architecture (v6.1+)

```text
                     ┌─────────────────────────────────────┐
                     │  Browser (PWA, Workbox, signals)    │
                     │                                     │
                     │  main.ts ── card registry (lazy)    │
                     │     │                               │
                     │     ├─ signals store (persistent)   │
                     │     ├─ Worker: backtest / scan      │
                     │     └─ Service Worker (Workbox)     │
                     └────────────┬────────────────────────┘
                                  │ HTTPS + WSS
                     ┌────────────┴────────────────────────┐
                     │  Cloudflare Pages (static SPA)      │
                     │  + Pages Functions / Workers (API)  │
                     │     ├─ /api/*     proxy chain       │
                     │     ├─ /api/og    OG image render   │
                     │     ├─ Durable Objects (WS fanout)  │
                     │     ├─ KV (rate limit, hot quotes)  │
                     │     └─ R2 (historical OHLC, OG)     │
                     └────────────┬────────────────────────┘
                                  │
            ┌────────┬────────────┼────────────┬────────────┐
            ▼        ▼            ▼            ▼            ▼
         Yahoo    Finnhub     Alpha V.      Polygon     CoinGecko
         (free)   (free)      (free)        (paid)      (free)
```

### 5.1 Layered code structure (target)

```text
src/
  types/                  domain.ts, api.ts, branded.ts, zod-schemas.ts
  domain/                 pure functions (no I/O, no DOM)        ─ unchanged
  core/
    signals.ts            signal/computed/effect + persistence
    cache/
      memory.ts           L1 Map
      idb.ts              L3 IndexedDB + LRU
      tiered.ts           L1+L2+L3 facade
    fetch.ts              circuit-breaker-aware fetch
    workers/
      compute.worker.ts   backtest, scan, full-history calc
      compute.client.ts   comlink wrapper
    sw/                   Workbox config, runtime strategies
    config/               schema (zod), migrations
    keyboard.ts           command palette + j/k
    a11y.ts               focus traps, sr-only helpers
  providers/
    types.ts              MarketDataProvider + zod schema
    yahoo, finnhub, alpha-vantage, polygon, coingecko
    chain.ts              circuit breaker + health
  cards/
    <feature>/            index.ts (mount), styles.css, *.test.ts
  ui/
    router.ts             History API, route → card mapping
    theme.ts, toast.ts, modal.ts, command-palette.ts
  styles/                 tokens, base, layout, components, a11y
worker/                   Cloudflare Pages Functions / Workers
docs-site/                Astro Starlight (separate workspace pkg)
```

### 5.2 Dependency rules (enforced by ESLint `import/no-restricted-paths`)

```text
types/      ← nothing
domain/     ← types/                     (no DOM, no I/O)
core/       ← types/, domain/            (no UI)
providers/  ← types/, core/
cards/      ← types/, domain/, core/, providers/, ui/
ui/         ← types/, core/
worker/     ← independent (own tsconfig)
```

---

## 6. Frontend Strategy

### 6.1 Rendering model

- **Vanilla TS + Preact Signals** as the default (cheap, fine-grained).
- **Lit components** *only* when a card has nontrivial reusable subcomponents
  (chart toolbar, filter chip group, command palette).
- **No JSX runtime** in the bundle — Lit uses tagged templates; signals attach via
  small `bind(el, signal)` helpers.

### 6.2 Routing

- History API. Routes: `/`, `/watchlist`, `/chart/:symbol`, `/screener`,
  `/portfolio`, `/backtest/:symbol`, `/alerts`, `/settings`.
- Cloudflare Pages SPA fallback (or `404.html` redirect on GH Pages).
- Per-route lazy `import()` of card module.

### 6.3 State

- `signal<T>(initial)` is the only primitive.
- Persistent signals: `persistedSignal('watchlist', [], { storage: idb })`.
- Cross-tab sync via `BroadcastChannel`.

### 6.4 Charting

- `lightweight-charts@^5` dynamic import on chart route.
- Sub-panes for RSI / MACD / Stochastic / ADX (existing `chart-panels.ts`).
- Signal markers driven by domain `consensus-engine`.
- Saved chart state (overlays, range) persisted per symbol.

### 6.5 Accessibility

- Skip-link, landmark roles, focus rings honoring `:focus-visible`.
- All interactive cards keyboard-reachable; `role="application"` only on charts.
- `prefers-reduced-motion`, `prefers-contrast`, forced-colors mode.
- WCAG 2.2 AA via axe in CI.

### 6.6 Theming

- `data-theme="dark|light|auto"` + system preference.
- Optional **high-contrast** and **deuteranopia/protanopia** palettes (Phase 3).

### 6.7 Internationalization (Phase 4)

- `@formatjs/intl` + ICU.
- `dir="rtl"` for Hebrew; tokens already direction-agnostic.
- Date/number formatting via `Intl.*` (no `moment`, no `date-fns`).

---

## 7. Backend & Data Strategy

### 7.1 API surface (Cloudflare Pages Functions)

| Route | Purpose | Cache |
|---|---|---|
| `GET /api/health` | Status + provider health | none |
| `GET /api/quote/:symbol` | Spot quote | KV 60s (open) / 5m (closed) |
| `GET /api/history/:symbol?range=1y` | Daily OHLCV | KV 24h, R2 cold |
| `GET /api/search?q=` | Symbol autocomplete | KV 1h |
| `GET /api/og/:symbol.png` | OG image (mini chart) | edge cache 1h |
| `WS  /api/stream` | Live quotes (Durable Object) | n/a |
| `POST /api/errors` | Sampled error ingestion | none |

### 7.2 Provider chain

```text
quote:    Yahoo → Finnhub → Alpha Vantage  (circuit breaker per provider)
history:  Yahoo → Finnhub → Polygon
search:   Yahoo → Finnhub
crypto:   CoinGecko (only)
stream:   Finnhub (WS) → Polygon (WS)      (auth headers in Worker only)
```

### 7.3 Circuit breaker

- States: `closed` (normal), `open` (skip provider for 60 s), `half-open`
  (one probe).
- Per-provider counters in Worker memory + KV; surfaced to client via `/api/health`.

### 7.4 Secrets

- All API keys are **Worker env vars only**. No keys in browser, no keys in repo.
- `wrangler secret put` for production; `.dev.vars` (gitignored) for local.

### 7.5 Rate limits & abuse

- Per-IP token bucket (KV-backed) at 60 req/min per route.
- Reject requests without a known `Origin` header in production.
- Global daily budget alarm via Cloudflare Analytics.

---

## 8. Storage & Sync Strategy

### 8.1 Tiers (refined)

| Tier | Tech | Use | TTL / Cap |
|---|---|---|---|
| L1 | `Map` | Hot quotes, computed series | session |
| L2 | `localStorage` | Config, theme, last route | persistent, ~5 MB |
| L3 | IndexedDB (`idb.ts`) | Candles, alerts, portfolio, snapshots | LRU 50 MB |
| L4 | Service Worker Cache | App shell + API responses (SWR) | per-strategy |
| Edge | KV / R2 | Hot quotes / cold history | TTL / cold |
| Cloud (opt) | Worker + KV (Phase 4) | Per-passkey-user sync | per-user |

### 8.2 Storage pressure

- Listen to `navigator.storage.estimate()`; warn at 80%, evict L3 LRU.
- `navigator.storage.persist()` requested after first opt-in action.

### 8.3 Schema versioning

- IndexedDB version migrations in `core/cache/idb.ts`.
- Config schema validated by Zod; migrations declared per version bump.
- Export/import JSON gated by schema validation.

### 8.4 Cloud sync (Phase 4, optional)

- Passkeys → opaque user id → Worker stores **encrypted** blobs in KV.
- Client-side encryption with a derived key from a user-chosen pass-phrase.
- Server never sees plaintext watchlist/portfolio.

---

## 9. Quality, Security & Observability

### 9.1 Quality gates (CI, all required)

```text
typecheck            tsc --noEmit (strict + noUncheckedIndexedAccess)
lint                 eslint . --max-warnings 0
lint:css             stylelint
lint:html            htmlhint
lint:md              markdownlint-cli2
test                 vitest run --coverage  (≥90% statements, ≥80% branches)
test:e2e             playwright (8–10 flows)
a11y                 axe in E2E (0 serious/critical)
build                vite build
bundle               check-bundle-size.mjs (<180 KB gz initial)
lighthouse           lhci autorun (perf ≥90, a11y ≥95, best ≥95, SEO ≥90)
audit                npm audit --omit=dev (no high/critical) + audit-signatures
```

### 9.2 Security

- **CSP** via Worker headers: `default-src 'self'; script-src 'self'; connect-src 'self' https://api.crosstide.dev`.
- **SRI** on every third-party asset (none planned, but enforced).
- **Permissions-Policy** disabling camera/mic/geolocation.
- **Subresource hashes** verified in CI.
- **Zod validation** on every external input (provider responses, URL params, imported JSON).
- **No `dangerouslySetInnerHTML` equivalents** — `escapeHtml` enforced via custom ESLint rule.

### 9.3 Observability

- **Errors:** GlitchTip (self-hosted, Sentry-compatible). Sampled, scrubbed, no PII.
- **Analytics:** Plausible (cookieless). Route changes, card mounts, uncaught errors.
- **RUM:** `web-vitals` reported to Plausible custom events.
- **Server-side:** Cloudflare Analytics + structured logs via `console.log` → Logpush → R2.

---

## 10. Performance Budget

| Asset | Budget | Gate |
|---|---|---|
| HTML | < 8 KB | LH CI |
| CSS | < 30 KB gz | bundle check |
| JS initial | < 180 KB gz | `check:bundle` |
| Lazy card chunk | < 50 KB gz each | per-route |
| Lightweight Charts chunk | ~40 KB gz | dynamic import |
| Web Worker bundle | < 60 KB gz | per file |
| Fonts (subset, woff2) | < 80 KB | self-hosted |
| **Initial total** | **< 200 KB gz** | CI |
| LCP (4G, mid Android) | < 1.8 s | LH CI |
| INP (p75) | < 200 ms | LH CI |
| CLS | < 0.05 | LH CI |
| TTI | < 2.5 s | LH CI |

Tooling: `rollup-plugin-visualizer` artifact uploaded per PR.

---

## 11. Developer Experience

| Area | Decision |
|---|---|
| Package manager | npm (shared `MyScripts/node_modules`) — keep |
| Monorepo | Document `worker/` and `docs-site/` as workspaces in shared root |
| Git hooks | `simple-git-hooks` + `lint-staged` (no Husky bloat) |
| Commit style | Conventional Commits, enforced by `commitlint` |
| Releases | **Changesets** (auto-generated CHANGELOG + version bump PR) |
| PR previews | Cloudflare Pages auto preview per branch |
| Local Worker | `wrangler dev` proxied through Vite via `server.proxy` |
| Mock data | `tests/helpers/fixtures/` with realistic OHLC fixtures |
| Component dev | `dev/components.html` mounting every card with mock signals |
| Editor | `.vscode/settings.json` already shared |
| Docs | Astro Starlight site at `docs-site/`, deployed to `/docs` |

---

## 12. Phased Roadmap

### Phase A — v6.1 *Best-in-Class Web Dashboard* (NEXT)

Goal: turn scaffolds into a real product. Every gap in §1.2 closed.

| # | Task | Priority |
|---|---|:-:|
| A1 | Add `lightweight-charts` and integrate in `cards/chart.ts` (multi-pane, signal markers) | P0 |
| A2 | Wire `card-registry` in `main.ts` with lazy `import()` per route | P0 |
| A3 | Replace hash router with History API + 404 fallback | P0 |
| A4 | Replace `EventTarget` store with `@preact/signals-core` + `persistedSignal` | P0 |
| A5 | Move backtest + full-history scan into Web Worker via `comlink` | P0 |
| A6 | Workbox SW (precache, runtime caching, navigation preload) | P0 |
| A7 | Deploy Worker to Cloudflare; switch deploy target to Cloudflare Pages | P0 |
| A8 | Add Finnhub provider + circuit breaker + health surfacing | P0 |
| A9 | Zod schemas at every provider boundary; branded `Ticker`/`ISODate` | P0 |
| A10 | Command palette (`⌘K`) + finish keyboard shortcuts (`j/k`, `/`, `g h`) | P0 |
| A11 | Watchlist polish: sparkline, 52W range, volume vs avg, sort, drag reorder | P0 |
| A12 | Heatmap card (Canvas treemap) | P1 |
| A13 | Screener card with preset filters (oversold, breakout, golden cross) | P1 |
| A14 | Alert history card + browser notifications (with permission flow) | P1 |
| A15 | Playwright E2E (10 flows) + `@axe-core/playwright` | P0 |
| A16 | Lighthouse CI with budgets file | P0 |
| A17 | GlitchTip + Plausible self-host & integration (sampled) | P1 |
| A18 | Changesets + Conventional Commits + commitlint | P1 |
| A19 | Component preview page `dev/components.html` | P1 |
| A20 | CSP, Permissions-Policy, security headers via Worker | P0 |
| A21 | Storage pressure handling + LRU eviction in IDB | P1 |

### Phase B — v6.2 *Streaming & Portfolio*

| # | Task | Priority |
|---|---|:-:|
| B1 | WebSocket streaming via Finnhub (Durable Object fan-out) | P1 |
| B2 | Portfolio card: holdings, P/L, sector allocation, benchmark vs SPY | P1 |
| B3 | Risk metrics card: Sharpe, Sortino, max DD, beta, volatility | P1 |
| B4 | Backtest UI on top of existing engine (equity curve + perf table) | P1 |
| B5 | Provider Health card from circuit-breaker stats | P2 |
| B6 | Consensus history timeline | P2 |
| B7 | OG image rendering (`/api/og/:symbol.png`) | P2 |
| B8 | Polygon provider (paid escape hatch) | P2 |

### Phase C — v6.3 *Polish & Reach*

| # | Task | Priority |
|---|---|:-:|
| C1 | i18n (English + Hebrew RTL) | P2 |
| C2 | High-contrast & color-blind palettes | P2 |
| C3 | Astro Starlight docs site at `/docs` | P2 |
| C4 | Per-indicator MDX reference (formula + defaults + tests) | P2 |
| C5 | Mobile-first layout pass + container queries | P2 |
| C6 | Dividend projection in Portfolio | P3 |
| C7 | CSV/JSON full-data export with schema versioning | P2 |

### Phase D — v7.0 *Optional Cloud + Power Tools*

| # | Task | Priority |
|---|---|:-:|
| D1 | Passkey auth (WebAuthn) + opt-in cloud sync (E2E encrypted) | P3 |
| D2 | Multi-chart layout (2×2, 1+3) with synced crosshair | P3 |
| D3 | Drawing tools (trendline, fib retracement) | P3 |
| D4 | Custom-signal mini-DSL (JSON-AST → Web Worker) | P3 |
| D5 | Shared watchlist URLs (read-only encoded state) | P3 |
| D6 | Optional Supabase backend (self-host) for multi-device families | P4 |
| D7 | Native push via VAPID + Web Push | P3 |

---

## 13. Outstanding Work Consolidated from v5/v6

These were promised in the previous roadmap and are still open or only partially done.
They are folded into Phase A unless noted.

- ✅ Domain ports (calculators + methods + alert SM + backtest engine + analytics)
- ⏳ Cloudflare Worker **deployment** (code authored, not deployed) → A7
- ⏳ Yahoo provider in browser (uses Worker base URL) → A7
- ⏳ Watchlist enhancements (sparkline, 52W, volume, drag) → A11
- ⏳ Chart card real rendering → A1
- ⏳ Consensus dashboard wired → A2 + existing `cards/consensus.ts`
- ⏳ Settings card wired → A2 + existing `cards/settings.ts`
- ⏳ Keyboard shortcuts finished → A10
- ⏳ Service Worker hardened (Workbox) → A6
- ⏳ IndexedDB tier with eviction → A21
- ⏳ Domain test target ≥500 → already met; keep ratchet
- ⏳ Card / core / provider tests → A15 + ongoing
- ⏳ CI: Lighthouse + E2E → A15 / A16
- ⏳ Heatmap, Screener, Alert history cards → A12 / A13 / A14
- ⏳ Twelve Data provider in Worker → already coded; keep but downgrade to tertiary
- ⏳ Toast notification system → already exists in `cards/`; consolidate into `ui/toast.ts`
- ⏳ Responsive mobile layout → C5
- ⏳ Portfolio + Backtest cards → Phase B
- ⏳ Provider health dashboard → B5
- ⏳ Theme polish (high contrast) → C2
- ⏳ Polygon provider → B8
- ⏳ WebSocket streaming → B1
- ⏳ Browser push alerts → A14 (in-tab) / D7 (real Web Push)
- ⏳ Shared watchlist URLs → D5
- ⏳ i18n English + Hebrew → C1
- ⏳ Optional cloud backend → D1 / D6
- ⏳ Multi-chart layout → D2
- ⏳ Drawing tools → D3

Anything not listed is descoped.

---

## 14. Decisions Reaffirmed / Reversed / New

### Reaffirmed (kept after rethink)

- TypeScript strict, vanilla DOM, design tokens, IndexedDB+localStorage tiers,
  Lightweight Charts, Cloudflare Workers, MIT, no-account default, $0/mo target,
  shared MyScripts toolchain.

### Reversed (changed from prior plan)

- **Hash routing → History API** (D2)
- **EventTarget store → Preact Signals** (D3)
- **GitHub Pages → Cloudflare Pages** (D9)
- **Hand-rolled SW → Workbox** (D10)
- **Single-tier deploy → preview deploys per PR** (D9)
- **Manual versioning → Changesets** (D20)
- **Twelve Data primary fallback → Finnhub** (D7)

### New (added in this rethink)

- Web Worker compute, signals-based state, Zod boundaries, branded types,
  circuit breakers, GlitchTip + Plausible, Lighthouse CI, Playwright + axe,
  command palette, Workbox + Background Sync, OG image rendering,
  Durable-Object WS fan-out, R2 cold history, Passkey-only optional auth,
  client-side encrypted cloud sync, security headers via Worker, Astro
  Starlight docs site.

---

## 15. Scope Boundaries

**Building.** Browser-based stock & crypto monitoring dashboard, multi-method
consensus engine, charting, screener, alerts, backtest, portfolio, offline-first
PWA, optional encrypted cloud sync — open source, self-hostable, $0/mo default.

**Not building.**

- Brokerage / order execution / real money flow.
- Native mobile or desktop apps (web is the only target; PWA covers install).
- Social network, comments, follows, copy-trading.
- News aggregation feed (link-out only).
- Tick-by-tick L2 order book terminal.
- Account-required features in the core product.
- A clone of the archived Flutter app — web has its own UX.

Every feature must justify: (1) data source, (2) UI surface, (3) test coverage,
(4) bundle cost.

---

## 16. Appendix: Flutter Archive

<details>
<summary>Click to expand — Flutter app history (archived, no longer maintained)</summary>

**Final state (v2.27.0+41):** 3348+ passing tests, 0 analyzer issues, 100% domain
coverage, 470+ entities, 12 trading methods, 15 calculators. Platforms: Android
(APK), Windows (MSIX). Stack: Dart, Flutter, Riverpod, Drift (SQLite), GoRouter.

**Why archived.** The Flutter app proved the domain model. The web rewrite carries
forward all algorithms and test vectors. No native platform code is maintained
going forward.

**Shared assets carried forward.** Domain algorithms (ported 1:1 to TypeScript),
test vectors (same inputs/outputs), `sp500_tickers.json`, `sector_map.json`.

</details>

---

*This roadmap is the single source of truth. Any change to architecture, tooling,
or scope is reflected here first via a Changeset-tracked PR.*
