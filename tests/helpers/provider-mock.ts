/**
 * Reusable mock-provider factory for provider-level tests.
 *
 * Creates a fully-typed `MarketDataProvider` backed by `vi.fn()` stubs,
 * with sensible defaults that can be overridden per-test.
 *
 * Usage:
 *   const { provider, stubs } = createMockProvider({ name: "test" });
 *   stubs.getQuote.mockResolvedValue(makeQuote({ price: 42 }));
 *   const q = await provider.getQuote("AAPL");
 */
import { vi } from "vitest";
import type {
  MarketDataProvider,
  Quote,
  SearchResult,
  ProviderHealth,
} from "../../src/providers/types";
import type { DailyCandle } from "../../src/types/domain";

// ── Partial factories ────────────────────────────────────────────────────

/**
 * Build a `Quote` with sensible defaults; override any field.
 */
export function makeQuote(overrides: Partial<Quote> = {}): Quote {
  return {
    ticker: "AAPL",
    price: 150,
    open: 148,
    high: 152,
    low: 147,
    previousClose: 149,
    volume: 50_000_000,
    timestamp: Date.now(),
    ...overrides,
  };
}

/**
 * Build a `DailyCandle` array from close prices (delegates to date offset).
 */
export function makeCandles(closes: number[], startDate = "2024-01-01"): DailyCandle[] {
  const start = new Date(startDate);
  return closes.map((close, i) => {
    const d = new Date(start);
    d.setUTCDate(d.getUTCDate() + i);
    const date = d.toISOString().slice(0, 10);
    return {
      date,
      open: close - 1,
      high: close + 2,
      low: close - 2,
      close,
      volume: 1_000_000 + i * 100,
    };
  });
}

/**
 * Build a `SearchResult` with defaults.
 */
export function makeSearchResult(overrides: Partial<SearchResult> = {}): SearchResult {
  return {
    symbol: "AAPL",
    name: "Apple Inc.",
    exchange: "NASDAQ",
    type: "equity",
    ...overrides,
  };
}

/**
 * Build a `ProviderHealth` with defaults (available by default).
 */
export function makeHealth(overrides: Partial<ProviderHealth> = {}): ProviderHealth {
  return {
    name: "mock",
    available: true,
    lastSuccessAt: Date.now(),
    lastErrorAt: null,
    consecutiveErrors: 0,
    ...overrides,
  };
}

// ── Mock provider ────────────────────────────────────────────────────────

export interface MockProviderStubs {
  getQuote: ReturnType<typeof vi.fn<(ticker: string) => Promise<Quote>>>;
  getHistory: ReturnType<
    typeof vi.fn<(ticker: string, days: number) => Promise<readonly DailyCandle[]>>
  >;
  search: ReturnType<typeof vi.fn<(query: string) => Promise<readonly SearchResult[]>>>;
  health: ReturnType<typeof vi.fn<() => ProviderHealth>>;
}

export interface MockProviderResult {
  provider: MarketDataProvider;
  stubs: MockProviderStubs;
}

/**
 * Create a mock `MarketDataProvider` with vi.fn() stubs.
 *
 * All methods return sensible defaults by default. Override via `stubs`.
 */
export function createMockProvider(opts: { name?: string } = {}): MockProviderResult {
  const name = opts.name ?? "mock-provider";

  const stubs: MockProviderStubs = {
    getQuote: vi.fn<(ticker: string) => Promise<Quote>>().mockResolvedValue(makeQuote()),
    getHistory: vi
      .fn<(ticker: string, days: number) => Promise<readonly DailyCandle[]>>()
      .mockResolvedValue(makeCandles([100, 101, 102])),
    search: vi
      .fn<(query: string) => Promise<readonly SearchResult[]>>()
      .mockResolvedValue([makeSearchResult()]),
    health: vi.fn<() => ProviderHealth>().mockReturnValue(makeHealth({ name })),
  };

  const provider: MarketDataProvider = {
    name,
    getQuote: stubs.getQuote,
    getHistory: stubs.getHistory,
    search: stubs.search,
    health: stubs.health,
  };

  return { provider, stubs };
}
