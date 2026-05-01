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
    vi.mocked(createYahooProvider).mockReturnValue(makeProviderMock("yahoo"));
    const { getChain } = await import("../../../src/providers/provider-registry");
    const quote = await getChain().getQuote("AAPL");
    expect(quote).toBeDefined();
  });

  it("getHistory() exercises recordSuccess path when call resolves", async () => {
    const { createYahooProvider } = await import("../../../src/providers/yahoo-provider");
    vi.mocked(createYahooProvider).mockReturnValue(makeProviderMock("yahoo"));
    const { getChain } = await import("../../../src/providers/provider-registry");
    const candles = await getChain().getHistory("AAPL", 30);
    expect(Array.isArray(candles)).toBe(true);
  });

  it("search() exercises recordSuccess path when call resolves", async () => {
    const { createYahooProvider } = await import("../../../src/providers/yahoo-provider");
    vi.mocked(createYahooProvider).mockReturnValue(makeProviderMock("yahoo"));
    const { getChain } = await import("../../../src/providers/provider-registry");
    const results = await getChain().search("apple");
    expect(Array.isArray(results)).toBe(true);
  });

  it("breaker-aware health() returns available:true when breaker is closed", async () => {
    const { createYahooProvider } = await import("../../../src/providers/yahoo-provider");
    vi.mocked(createYahooProvider).mockReturnValue(makeProviderMock("yahoo"));
    const { getChain } = await import("../../../src/providers/provider-registry");
    // chain.health() calls provider.health() for each wrapped provider
    const h = getChain().health();
    expect(h.available).toBe(true);
  });

  it("exercises recordFailure then circuit breaker opens after threshold", async () => {
    const { createYahooProvider } = await import("../../../src/providers/yahoo-provider");
    // Mock fails 3 times — trips the breaker (threshold = 3)
    const mockGetQuote = vi
      .fn()
      .mockRejectedValueOnce(new Error("net-fail-1"))
      .mockRejectedValueOnce(new Error("net-fail-2"))
      .mockRejectedValueOnce(new Error("net-fail-3"))
      .mockResolvedValue({});
    vi.mocked(createYahooProvider).mockReturnValue(makeProviderMock("yahoo", mockGetQuote));
    const { getChain } = await import("../../../src/providers/provider-registry");
    const chain = getChain();

    // Failures 1 and 2: tryAll first-pass tries provider, op() throws, recordFailure
    await expect(chain.getQuote("AAPL")).rejects.toThrow(/net-fail-1|circuit breaker/);
    await expect(chain.getQuote("AAPL")).rejects.toThrow(/net-fail-2|circuit breaker/);
    // Failure 3 trips the breaker — the second pass throws "circuit breaker is open"
    await expect(chain.getQuote("AAPL")).rejects.toThrow(/circuit breaker is open/);

    // After the breaker is open: subsequent calls also throw "circuit breaker is open"
    await expect(chain.getQuote("AAPL")).rejects.toThrow(/circuit breaker is open/);
  });
});
