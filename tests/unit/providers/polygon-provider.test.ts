import { describe, it, expect, vi, beforeEach } from "vitest";
import { createPolygonProvider } from "../../../src/providers/polygon-provider";
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

const PREV_CLOSE_RESPONSE = {
  status: "OK",
  results: [{ T: "AAPL", o: 149.0, h: 152.0, l: 148.0, c: 150.5, v: 50_000_000, t: 1700000000000 }],
};

const AGGS_RESPONSE = {
  status: "OK",
  results: [
    { o: 148.0, h: 151.0, l: 147.0, c: 149.0, v: 35_000_000, t: 1704067200000 },
    { o: 150.0, h: 151.0, l: 149.0, c: 150.5, v: 40_000_000, t: 1704153600000 },
    { o: 151.0, h: 153.0, l: 150.0, c: 152.0, v: 45_000_000, t: 1704240000000 },
  ],
};

const TICKERS_RESPONSE = {
  status: "OK",
  results: [
    { ticker: "AAPL", name: "Apple Inc.", primary_exchange: "XNAS", type: "CS" },
    { ticker: "AAPD", name: "Direxion Daily AAPL Bear", primary_exchange: "ARCX", type: "ETV" },
  ],
};

describe("polygon-provider", () => {
  let provider: MarketDataProvider;

  beforeEach(() => {
    mockFetch.mockReset();
    provider = createPolygonProvider("test-api-key", "https://mock.polygon");
  });

  describe("getQuote", () => {
    it("returns a quote with correct fields", async () => {
      mockFetch.mockResolvedValue(jsonResponse(PREV_CLOSE_RESPONSE));
      const q = await provider.getQuote("AAPL");
      expect(q.ticker).toBe("AAPL");
      expect(q.price).toBe(150.5);
      expect(q.open).toBe(149.0);
      expect(q.high).toBe(152.0);
      expect(q.low).toBe(148.0);
      expect(q.volume).toBe(50_000_000);
    });

    it("includes apiKey in request URL", async () => {
      mockFetch.mockResolvedValue(jsonResponse(PREV_CLOSE_RESPONSE));
      await provider.getQuote("AAPL");
      const url = mockFetch.mock.calls[0][0] as string;
      expect(url).toContain("test-api-key");
    });

    it("tracks health on success", async () => {
      mockFetch.mockResolvedValue(jsonResponse(PREV_CLOSE_RESPONSE));
      await provider.getQuote("AAPL");
      expect(provider.health().available).toBe(true);
      expect(provider.health().lastSuccessAt).not.toBeNull();
    });

    it("throws and records error on empty results", async () => {
      mockFetch.mockResolvedValue(jsonResponse({ status: "OK", results: [] }));
      await expect(provider.getQuote("AAPL")).rejects.toThrow("No result from Polygon");
      expect(provider.health().lastErrorAt).not.toBeNull();
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
    it("returns candles from Polygon aggs", async () => {
      mockFetch.mockResolvedValue(jsonResponse(AGGS_RESPONSE));
      const candles = await provider.getHistory("AAPL", 30);
      expect(candles).toHaveLength(3);
      expect(candles[0].open).toBe(148.0);
      expect(candles[0].close).toBe(149.0);
      expect(candles[0].volume).toBe(35_000_000);
    });

    it("dates are ISO format YYYY-MM-DD", async () => {
      mockFetch.mockResolvedValue(jsonResponse(AGGS_RESPONSE));
      const candles = await provider.getHistory("AAPL", 30);
      expect(candles[0].date).toMatch(/^\d{4}-\d{2}-\d{2}$/);
    });

    it("throws on empty results", async () => {
      mockFetch.mockResolvedValue(jsonResponse({ status: "OK", results: [] }));
      await expect(provider.getHistory("AAPL", 30)).rejects.toThrow("No history from Polygon");
    });

    it("throws on null results", async () => {
      mockFetch.mockResolvedValue(jsonResponse({ status: "OK" }));
      await expect(provider.getHistory("AAPL", 30)).rejects.toThrow();
    });
  });

  describe("search", () => {
    it("returns search results with correct fields", async () => {
      mockFetch.mockResolvedValue(jsonResponse(TICKERS_RESPONSE));
      const results = await provider.search("AAPL");
      expect(results).toHaveLength(2);
      expect(results[0].symbol).toBe("AAPL");
      expect(results[0].name).toBe("Apple Inc.");
      expect(results[0].exchange).toBe("XNAS");
      expect(results[0].type).toBe("CS");
    });

    it("returns empty array when no results", async () => {
      mockFetch.mockResolvedValue(jsonResponse({ status: "OK" }));
      const results = await provider.search("XYZ");
      expect(results).toHaveLength(0);
    });

    it("includes market=stocks and limit in URL", async () => {
      mockFetch.mockResolvedValue(jsonResponse(TICKERS_RESPONSE));
      await provider.search("AAPL");
      const url = mockFetch.mock.calls[0][0] as string;
      expect(url).toContain("market=stocks");
      expect(url).toContain("limit=10");
    });
  });

  describe("health", () => {
    it("starts healthy", () => {
      const h = provider.health();
      expect(h.name).toBe("polygon");
      expect(h.available).toBe(true);
      expect(h.consecutiveErrors).toBe(0);
    });

    it("recovers after success", async () => {
      mockFetch.mockRejectedValue(new Error("fail"));
      try {
        await provider.getQuote("X");
      } catch {}
      mockFetch.mockResolvedValue(jsonResponse(PREV_CLOSE_RESPONSE));
      await provider.getQuote("AAPL");
      expect(provider.health().consecutiveErrors).toBe(0);
    });
  });
});
