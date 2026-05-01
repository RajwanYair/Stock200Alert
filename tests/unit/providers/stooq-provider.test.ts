import { describe, it, expect, vi, beforeEach } from "vitest";
import { createStooqProvider } from "../../../src/providers/stooq-provider";
import type { MarketDataProvider } from "../../../src/providers/types";

const mockFetch = vi.fn();
vi.stubGlobal("fetch", mockFetch);

const SAMPLE_CSV = `Date,Open,High,Low,Close,Volume
2025-05-02,194.5,197.0,193.2,196.0,52000000
2025-05-01,192.0,195.1,191.5,194.5,48000000
2025-04-30,190.0,193.0,189.5,192.0,47000000
`;

function textResponse(body: string, status = 200): Response {
  return {
    ok: status >= 200 && status < 300,
    status,
    statusText: status === 200 ? "OK" : "Error",
    json: async () => JSON.parse(body),
    text: async () => body,
    headers: new Headers(),
    redirected: false,
    type: "basic",
    url: "",
    body: null,
    bodyUsed: false,
    clone: () => textResponse(body, status),
    arrayBuffer: async () => new ArrayBuffer(0),
    blob: async () => new Blob(),
    formData: async () => new FormData(),
    bytes: async () => new Uint8Array(),
  } as Response;
}

describe("stooq-provider", () => {
  let provider: MarketDataProvider;

  beforeEach(() => {
    mockFetch.mockReset();
    provider = createStooqProvider("https://mock.stooq");
  });

  describe("getHistory", () => {
    it("parses CSV and returns candles oldest-first", async () => {
      mockFetch.mockResolvedValueOnce(textResponse(SAMPLE_CSV));
      const candles = await provider.getHistory("AAPL", 365);
      // Stooq CSV has 3 data rows; returned oldest-first
      expect(candles).toHaveLength(3);
      expect(candles[0]!.date).toBe("2025-04-30");
      expect(candles[2]!.date).toBe("2025-05-02");
    });

    it("maps OHLCV fields correctly", async () => {
      mockFetch.mockResolvedValueOnce(textResponse(SAMPLE_CSV));
      const candles = await provider.getHistory("AAPL", 365);
      const last = candles[candles.length - 1]!;
      expect(last.open).toBe(194.5);
      expect(last.high).toBe(197.0);
      expect(last.low).toBe(193.2);
      expect(last.close).toBe(196.0);
      expect(last.volume).toBe(52000000);
    });

    it("trims to requested window", async () => {
      mockFetch.mockResolvedValueOnce(textResponse(SAMPLE_CSV));
      const candles = await provider.getHistory("AAPL", 2);
      expect(candles).toHaveLength(2);
    });

    it("converts ticker to stooq .us suffix", async () => {
      mockFetch.mockResolvedValueOnce(textResponse(SAMPLE_CSV));
      await provider.getHistory("AAPL", 365);
      const calledUrl = mockFetch.mock.calls[0]?.[0] as string;
      expect(calledUrl).toContain("aapl.us");
    });

    it("uses .v suffix for known crypto tickers", async () => {
      mockFetch.mockResolvedValueOnce(textResponse(SAMPLE_CSV));
      await provider.getHistory("BTC", 365);
      const calledUrl = mockFetch.mock.calls[0]?.[0] as string;
      expect(calledUrl).toContain("btc.v");
    });

    it("records error and marks health unavailable after 3 failures", async () => {
      mockFetch.mockResolvedValue(textResponse("Date,Open,High,Low,Close\n", 200));
      for (let i = 0; i < 3; i++) {
        await expect(provider.getHistory("AAPL", 365)).rejects.toThrow();
      }
      expect(provider.health().available).toBe(false);
    });

    it("records success and resets error counter", async () => {
      mockFetch.mockResolvedValueOnce(textResponse(SAMPLE_CSV));
      await provider.getHistory("AAPL", 365);
      expect(provider.health().consecutiveErrors).toBe(0);
      expect(provider.health().available).toBe(true);
    });
  });

  describe("getQuote", () => {
    it("throws FetchError (not supported)", async () => {
      await expect(provider.getQuote("AAPL")).rejects.toThrow("not supported");
    });
  });

  describe("search", () => {
    it("throws FetchError (not supported)", async () => {
      await expect(provider.search("Apple")).rejects.toThrow("not supported");
    });
  });

  describe("health", () => {
    it("reports name as stooq", () => {
      expect(provider.health().name).toBe("stooq");
    });

    it("starts healthy (no errors)", () => {
      expect(provider.health().available).toBe(true);
      expect(provider.health().consecutiveErrors).toBe(0);
    });
  });
});
