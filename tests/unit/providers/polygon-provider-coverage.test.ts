/**
 * Coverage tests for src/providers/polygon-provider.ts
 * Targets uncovered lines:
 *  - 98-99: search safeParse failure → recordError() + return []
 *  - 106-112: partial search result mapping (only exchange / only type / neither) + catch block
 */
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

describe("polygon-provider — search coverage (lines 98-99, 106-112)", () => {
  let provider: MarketDataProvider;

  beforeEach(() => {
    mockFetch.mockReset();
    provider = createPolygonProvider("test-key", "https://mock.polygon");
  });

  // Lines 98-99: schema parse failure → recordError(), return []
  it("returns empty array when search response fails schema validation", async () => {
    // PolygonTickerItemSchema requires ticker:string and name:string.
    // Sending results without required 'ticker' field causes safeParse failure.
    mockFetch.mockResolvedValue(jsonResponse({ status: "OK", results: [{ name: "bad item" }] }));
    const results = await provider.search("bad");
    expect(results).toEqual([]);
    // Health should record an error
    expect(provider.health().consecutiveErrors).toBeGreaterThan(0);
  });

  // Lines 106-107: result with only primary_exchange (no type)
  it("maps result with only primary_exchange", async () => {
    mockFetch.mockResolvedValue(
      jsonResponse({
        status: "OK",
        results: [{ ticker: "SYM", name: "Symbol Co.", primary_exchange: "XNAS" }],
      }),
    );
    const results = await provider.search("SYM");
    expect(results).toHaveLength(1);
    expect(results[0]!.symbol).toBe("SYM");
    expect(results[0]!.exchange).toBe("XNAS");
    expect(results[0]!.type).toBeUndefined();
  });

  // Lines 107-108: result with only type (no primary_exchange)
  it("maps result with only type (no exchange)", async () => {
    mockFetch.mockResolvedValue(
      jsonResponse({
        status: "OK",
        results: [{ ticker: "SYM2", name: "Symbol 2", type: "CS" }],
      }),
    );
    const results = await provider.search("SYM2");
    expect(results).toHaveLength(1);
    expect(results[0]!.type).toBe("CS");
    expect(results[0]!.exchange).toBeUndefined();
  });

  // Line 108-109: result with neither exchange nor type
  it("maps result with neither exchange nor type to base", async () => {
    mockFetch.mockResolvedValue(
      jsonResponse({
        status: "OK",
        results: [{ ticker: "SYM3", name: "Symbol 3" }],
      }),
    );
    const results = await provider.search("SYM3");
    expect(results).toHaveLength(1);
    expect(results[0]!.symbol).toBe("SYM3");
    expect(results[0]!.exchange).toBeUndefined();
    expect(results[0]!.type).toBeUndefined();
  });

  // Lines 111-112: catch block — search fetch throws
  it("re-throws and records error when search fetch fails", async () => {
    mockFetch.mockRejectedValue(new Error("network error"));
    await expect(provider.search("fail")).rejects.toThrow("network error");
    expect(provider.health().consecutiveErrors).toBeGreaterThan(0);
  });
});
