import { describe, it, expect, vi, beforeEach } from "vitest";
import { createCoinGeckoProvider } from "../../../src/providers/coingecko-provider";
import type { MarketDataProvider } from "../../../src/providers/types";

const mockFetch = vi.fn();
vi.stubGlobal("fetch", mockFetch);

function jsonResponse(body: unknown, status = 200): Response {
  return {
    ok: status >= 200 && status < 300,
    status,
    statusText: status === 200 ? "OK" : "Error",
    json: async () => body,
    headers: new Headers(),
    redirected: false,
    type: "basic",
    url: "",
    body: null,
    bodyUsed: false,
    clone: () => jsonResponse(body, status),
    arrayBuffer: async () => new ArrayBuffer(0),
    blob: async () => new Blob(),
    formData: async () => new FormData(),
    text: async () => JSON.stringify(body),
    bytes: async () => new Uint8Array(),
  } as Response;
}

const SIMPLE_PRICE_RESPONSE = {
  bitcoin: {
    usd: 42000,
    usd_24h_change: 5.0,
    usd_24h_vol: 2_000_000_000,
    last_updated_at: 1700000000,
  },
};

// [timestamp_ms, open, high, low, close]
const OHLC_RESPONSE = [
  [1704067200000, 42000, 43000, 41000, 42500],
  [1704153600000, 42500, 44000, 42000, 43500],
  [1704240000000, 43500, 45000, 43000, 44000],
];

const SEARCH_RESPONSE = {
  coins: [
    { id: "bitcoin", name: "Bitcoin", symbol: "btc" },
    { id: "bitcoin-cash", name: "Bitcoin Cash", symbol: "bch" },
  ],
};

describe("coingecko-provider", () => {
  let provider: MarketDataProvider;

  beforeEach(() => {
    mockFetch.mockReset();
    provider = createCoinGeckoProvider("https://mock.coingecko");
  });

  describe("getQuote", () => {
    it("returns a quote with correct fields", async () => {
      mockFetch.mockResolvedValue(jsonResponse(SIMPLE_PRICE_RESPONSE));
      const q = await provider.getQuote("bitcoin");
      expect(q.ticker).toBe("BITCOIN");
      expect(q.price).toBe(42000);
      expect(q.volume).toBe(2_000_000_000);
      expect(q.timestamp).toBe(1700000000 * 1000);
    });

    it("lowercases ticker for coin ID lookup", async () => {
      mockFetch.mockResolvedValue(jsonResponse(SIMPLE_PRICE_RESPONSE));
      const q = await provider.getQuote("BITCOIN");
      expect(q.price).toBe(42000);
    });

    it("computes previousClose from 24h change", async () => {
      mockFetch.mockResolvedValue(jsonResponse(SIMPLE_PRICE_RESPONSE));
      const q = await provider.getQuote("bitcoin");
      // price=42000, change=5% → prevClose = 42000 / 1.05 ≈ 40000
      expect(q.previousClose).toBeCloseTo(40000, 0);
    });

    it("tracks health on success", async () => {
      mockFetch.mockResolvedValue(jsonResponse(SIMPLE_PRICE_RESPONSE));
      await provider.getQuote("bitcoin");
      expect(provider.health().available).toBe(true);
      expect(provider.health().lastSuccessAt).not.toBeNull();
    });

    it("throws when coin not in response", async () => {
      mockFetch.mockResolvedValue(jsonResponse({}));
      await expect(provider.getQuote("unknown")).rejects.toThrow();
    });

    it("marks unavailable after 3 errors", async () => {
      mockFetch.mockRejectedValue(new Error("fail"));
      for (let i = 0; i < 3; i++) {
        try {
          await provider.getQuote("X");
        } catch {}
      }
      expect(provider.health().available).toBe(false);
    });
  });

  describe("getHistory", () => {
    it("returns candles from OHLC data", async () => {
      mockFetch.mockResolvedValue(jsonResponse(OHLC_RESPONSE));
      const candles = await provider.getHistory("bitcoin", 3);
      expect(candles.length).toBeGreaterThan(0);
      expect(candles[0].open).toBe(42000);
      expect(candles[0].high).toBe(43000);
      expect(candles[0].low).toBe(41000);
      expect(candles[0].close).toBe(42500);
    });

    it("deduplicates to one candle per day", async () => {
      const duplicateDay = [
        [1704067200000, 42000, 43000, 41000, 42500],
        [1704067200000 + 3600000, 42500, 43500, 42000, 43000], // same day, 1hr later
        [1704153600000, 43000, 44000, 42000, 43500],
      ];
      mockFetch.mockResolvedValue(jsonResponse(duplicateDay));
      const candles = await provider.getHistory("bitcoin", 3);
      expect(candles).toHaveLength(2);
    });

    it("sorts candles by date ascending", async () => {
      mockFetch.mockResolvedValue(jsonResponse(OHLC_RESPONSE));
      const candles = await provider.getHistory("bitcoin", 3);
      for (let i = 1; i < candles.length; i++) {
        expect(candles[i].date >= candles[i - 1].date).toBe(true);
      }
    });

    it("throws on empty OHLC array", async () => {
      mockFetch.mockResolvedValue(jsonResponse([]));
      await expect(provider.getHistory("bitcoin", 30)).rejects.toThrow();
    });

    it("includes days param in URL", async () => {
      mockFetch.mockResolvedValue(jsonResponse(OHLC_RESPONSE));
      await provider.getHistory("bitcoin", 14);
      const url = mockFetch.mock.calls[0][0] as string;
      expect(url).toContain("days=14");
    });
  });

  describe("search", () => {
    it("returns coins with uppercased symbol", async () => {
      mockFetch.mockResolvedValue(jsonResponse(SEARCH_RESPONSE));
      const results = await provider.search("bitcoin");
      expect(results[0].symbol).toBe("BTC");
      expect(results[0].name).toBe("Bitcoin");
      expect(results[0].type).toBe("CRYPTO");
      expect(results[0].exchange).toBe("CoinGecko");
    });

    it("limits to 10 results", async () => {
      const manyCoins = Array.from({ length: 20 }, (_, i) => ({
        id: `coin-${i}`,
        name: `Coin ${i}`,
        symbol: `c${i}`,
      }));
      mockFetch.mockResolvedValue(jsonResponse({ coins: manyCoins }));
      const results = await provider.search("coin");
      expect(results).toHaveLength(10);
    });

    it("returns empty when no coins field", async () => {
      mockFetch.mockResolvedValue(jsonResponse({}));
      const results = await provider.search("xyz");
      expect(results).toHaveLength(0);
    });
  });

  describe("health", () => {
    it("starts healthy", () => {
      const h = provider.health();
      expect(h.name).toBe("coingecko");
      expect(h.available).toBe(true);
      expect(h.consecutiveErrors).toBe(0);
    });

    it("recovers after success", async () => {
      mockFetch.mockRejectedValue(new Error("fail"));
      try {
        await provider.getQuote("X");
      } catch {}
      mockFetch.mockResolvedValue(jsonResponse(SIMPLE_PRICE_RESPONSE));
      await provider.getQuote("bitcoin");
      expect(provider.health().consecutiveErrors).toBe(0);
    });
  });
});
