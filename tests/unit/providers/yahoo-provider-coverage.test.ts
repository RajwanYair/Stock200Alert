/**
 * Coverage tests for src/providers/yahoo-provider.ts
 * Targets uncovered lines:
 *  - 101-102: getHistory catch block (fetch throws)
 *  - 121-127: search partial result mapping (only exchDisp / only quoteType / neither) + catch
 */
import { describe, it, expect, vi, beforeEach } from "vitest";
import { createYahooProvider } from "../../../src/providers/yahoo-provider";
import type { MarketDataProvider } from "../../../src/providers/types";

const mockFetch = vi.fn();
vi.stubGlobal("fetch", mockFetch);

function jsonResponse(body: unknown): Response {
  return {
    ok: true,
    status: 200,
    statusText: "OK",
    json: async () => body,
    headers: new Headers(),
    redirected: false,
    type: "basic",
    url: "",
    body: null,
    bodyUsed: false,
    clone: () => jsonResponse(body),
    arrayBuffer: async () => new ArrayBuffer(0),
    blob: async () => new Blob(),
    formData: async () => new FormData(),
    text: async () => JSON.stringify(body),
    bytes: async () => new Uint8Array(),
  } as Response;
}

describe("yahoo-provider — coverage (lines 101-102, 121-127)", () => {
  let provider: MarketDataProvider;

  beforeEach(() => {
    mockFetch.mockReset();
    provider = createYahooProvider("https://mock.yahoo");
  });

  // Lines 101-102: getHistory catch block — fetch throws
  it("re-throws and records error when getHistory fetch fails", async () => {
    mockFetch.mockRejectedValue(new Error("history network error"));
    await expect(provider.getHistory("AAPL", 30)).rejects.toThrow("history network error");
    expect(provider.health().consecutiveErrors).toBeGreaterThan(0);
  });

  // Lines 121-122: search result with only exchDisp (no quoteType)
  it("maps search result with only exchDisp (no quoteType)", async () => {
    mockFetch.mockResolvedValue(
      jsonResponse({
        quotes: [{ symbol: "TST", longname: "Test Corp", exchDisp: "NYSE" }],
      }),
    );
    const results = await provider.search("TST");
    expect(results).toHaveLength(1);
    expect(results[0]!.exchange).toBe("NYSE");
    expect(results[0]!.type).toBeUndefined();
  });

  // Lines 122-123: search result with only quoteType (no exchDisp)
  it("maps search result with only quoteType (no exchDisp)", async () => {
    mockFetch.mockResolvedValue(
      jsonResponse({
        quotes: [{ symbol: "TST2", longname: "Test Corp 2", quoteType: "ETF" }],
      }),
    );
    const results = await provider.search("TST2");
    expect(results).toHaveLength(1);
    expect(results[0]!.type).toBe("ETF");
    expect(results[0]!.exchange).toBeUndefined();
  });

  // Lines 123-124: search result with neither exchDisp nor quoteType
  it("maps search result with neither exchDisp nor quoteType to base", async () => {
    mockFetch.mockResolvedValue(
      jsonResponse({
        quotes: [{ symbol: "TST3", shortname: "Test 3" }],
      }),
    );
    const results = await provider.search("TST3");
    expect(results).toHaveLength(1);
    expect(results[0]!.symbol).toBe("TST3");
    expect(results[0]!.exchange).toBeUndefined();
    expect(results[0]!.type).toBeUndefined();
  });

  // Lines 126-127: search catch block — fetch throws
  it("re-throws and records error when search fetch fails", async () => {
    mockFetch.mockRejectedValue(new Error("search error"));
    await expect(provider.search("fail")).rejects.toThrow("search error");
    expect(provider.health().consecutiveErrors).toBeGreaterThan(0);
  });
});
