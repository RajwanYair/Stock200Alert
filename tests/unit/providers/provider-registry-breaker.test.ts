/**
 * Tests for createBreakerAwareProvider internals.
 *
 * These tests intentionally do NOT mock `createProviderChain` so the real
 * chain calls each breaker-aware wrapper's methods, exercising the
 * recordSuccess / recordFailure / "circuit breaker is open" paths.
 */
import { describe, it, expect, vi, beforeEach } from "vitest";

// Mock providers (no real HTTP) but leave createProviderChain unmocked so the
// real chain proxies through the breaker-aware wrappers.
vi.mock("../../../src/providers/yahoo-provider", () => ({
  createYahooProvider: vi.fn(),
}));
vi.mock("../../../src/providers/finnhub-provider", () => ({
  createFinnhubProvider: vi.fn(),
}));
vi.mock("../../../src/providers/stooq-provider", () => ({
  createStooqProvider: vi.fn(),
}));

function makeProviderMock(
  name: string,
  getQuote: ReturnType<typeof vi.fn> = vi.fn().mockResolvedValue({}),
) {
  return {
    name,
    getQuote,
    getHistory: vi.fn().mockResolvedValue([]),
    search: vi.fn().mockResolvedValue([]),
    health: vi.fn(() => ({
      name,
      available: true,
      lastSuccessAt: null,
      lastErrorAt: null,
      consecutiveErrors: 0,
    })),
  };
}

describe("breaker-aware wrapper — real provider-chain integration", () => {
  beforeEach(() => {
    vi.resetModules();
  });

  it("getQuote() exercises recordSuccess path when call resolves", async () => {
    const { createYahooProvider } = await import("../../../src/providers/yahoo-provider");
    const { createStooqProvider } = await import("../../../src/providers/stooq-provider");
    vi.mocked(createYahooProvider).mockReturnValue(makeProviderMock("yahoo"));
    vi.mocked(createStooqProvider).mockReturnValue(makeProviderMock("stooq"));
    const { getChain } = await import("../../../src/providers/provider-registry");
    const quote = await getChain().getQuote("AAPL");
    expect(quote).toBeDefined();
  });

  it("getHistory() exercises recordSuccess path when call resolves", async () => {
    const { createYahooProvider } = await import("../../../src/providers/yahoo-provider");
    const { createStooqProvider } = await import("../../../src/providers/stooq-provider");
    vi.mocked(createYahooProvider).mockReturnValue(makeProviderMock("yahoo"));
    vi.mocked(createStooqProvider).mockReturnValue(makeProviderMock("stooq"));
    const { getChain } = await import("../../../src/providers/provider-registry");
    const candles = await getChain().getHistory("AAPL", 30);
    expect(Array.isArray(candles)).toBe(true);
  });

  it("search() exercises recordSuccess path when call resolves", async () => {
    const { createYahooProvider } = await import("../../../src/providers/yahoo-provider");
    const { createStooqProvider } = await import("../../../src/providers/stooq-provider");
    vi.mocked(createYahooProvider).mockReturnValue(makeProviderMock("yahoo"));
    vi.mocked(createStooqProvider).mockReturnValue(makeProviderMock("stooq"));
    const { getChain } = await import("../../../src/providers/provider-registry");
    const results = await getChain().search("apple");
    expect(Array.isArray(results)).toBe(true);
  });

  it("breaker-aware health() returns available:true when breaker is closed", async () => {
    const { createYahooProvider } = await import("../../../src/providers/yahoo-provider");
    const { createStooqProvider } = await import("../../../src/providers/stooq-provider");
    vi.mocked(createYahooProvider).mockReturnValue(makeProviderMock("yahoo"));
    vi.mocked(createStooqProvider).mockReturnValue(makeProviderMock("stooq"));
    const { getChain } = await import("../../../src/providers/provider-registry");
    // chain.health() calls provider.health() for each wrapped provider
    const h = getChain().health();
    expect(h.available).toBe(true);
  });

  it("exercises recordFailure then circuit breaker opens after threshold", async () => {
    const { createYahooProvider } = await import("../../../src/providers/yahoo-provider");
    const { createStooqProvider } = await import("../../../src/providers/stooq-provider");
    // Stooq also needs to fail for the test to exercise the Yahoo breaker in isolation
    const stooqGetQuote = vi.fn().mockRejectedValue(new Error("stooq-not-supported"));
    vi.mocked(createStooqProvider).mockReturnValue(makeProviderMock("stooq", stooqGetQuote));
    // Mock Yahoo fails 3 times — trips the breaker (threshold = 3)
    const mockGetQuote = vi
      .fn()
      .mockRejectedValueOnce(new Error("net-fail-1"))
      .mockRejectedValueOnce(new Error("net-fail-2"))
      .mockRejectedValueOnce(new Error("net-fail-3"))
      .mockResolvedValue({});
    vi.mocked(createYahooProvider).mockReturnValue(makeProviderMock("yahoo", mockGetQuote));
    const { getChain } = await import("../../../src/providers/provider-registry");
    const chain = getChain();

    // Failures 1 and 2: tryAll first-pass tries Yahoo, op() throws, recordFailure
    // then tries Stooq which also throws
    await expect(chain.getQuote("AAPL")).rejects.toThrow();
    await expect(chain.getQuote("AAPL")).rejects.toThrow();
    // Failure 3 trips the Yahoo breaker — the second pass tries the "unhealthy" providers
    await expect(chain.getQuote("AAPL")).rejects.toThrow();

    // After the breaker is open: Yahoo is skipped (breaker open), only Stooq tried
    await expect(chain.getQuote("AAPL")).rejects.toThrow();
  });
});
