/**
 * Unit tests for public REST API helpers (I5).
 */
import { describe, it, expect } from "vitest";
import {
  API_VERSION,
  MAX_PAGE_SIZE,
  DEFAULT_PAGE_SIZE,
  extractApiKey,
  validateApiKey,
  successEnvelope,
  errorEnvelope,
  rateLimitHeaders,
  corsHeaders,
  parsePagination,
  paginate,
  parseFields,
  pickFields,
  isValidTicker,
  isValidDateParam,
} from "../../../src/core/public-api";

// ── helpers ──────────────────────────────────────────────────────────────

function makeHeaders(entries: Record<string, string>): { get(n: string): string | null } {
  const map = new Map(Object.entries(entries));
  return { get: (n: string) => map.get(n) ?? null };
}

function makeParams(entries: Record<string, string>): { get(n: string): string | null } {
  const map = new Map(Object.entries(entries));
  return { get: (n: string) => map.get(n) ?? null };
}

// ── extractApiKey ────────────────────────────────────────────────────────

describe("extractApiKey", () => {
  it("extracts from X-API-Key header", () => {
    expect(extractApiKey(makeHeaders({ "X-API-Key": "abc123" }))).toBe("abc123");
  });

  it("trims whitespace from X-API-Key", () => {
    expect(extractApiKey(makeHeaders({ "X-API-Key": "  key  " }))).toBe("key");
  });

  it("extracts from Authorization: Bearer", () => {
    expect(extractApiKey(makeHeaders({ Authorization: "Bearer tok456" }))).toBe("tok456");
  });

  it("prefers X-API-Key over Authorization", () => {
    expect(extractApiKey(makeHeaders({ "X-API-Key": "key1", Authorization: "Bearer key2" }))).toBe(
      "key1",
    );
  });

  it("returns null when no key present", () => {
    expect(extractApiKey(makeHeaders({}))).toBeNull();
  });

  it("returns null for malformed Authorization", () => {
    expect(extractApiKey(makeHeaders({ Authorization: "Basic dXNlcjpwYXNz" }))).toBeNull();
  });
});

// ── validateApiKey ───────────────────────────────────────────────────────

describe("validateApiKey", () => {
  const allowed = new Set(["valid-key-1", "valid-key-2"]);

  it("returns true for valid key", () => {
    expect(validateApiKey("valid-key-1", allowed)).toBe(true);
  });

  it("returns false for unknown key", () => {
    expect(validateApiKey("unknown", allowed)).toBe(false);
  });

  it("returns false for null key", () => {
    expect(validateApiKey(null, allowed)).toBe(false);
  });

  it("returns false for empty string", () => {
    expect(validateApiKey("", allowed)).toBe(false);
  });
});

// ── successEnvelope / errorEnvelope ──────────────────────────────────────

describe("successEnvelope", () => {
  it("wraps data with ok: true", () => {
    const env = successEnvelope({ price: 150 });
    expect(env.ok).toBe(true);
    expect(env.data).toEqual({ price: 150 });
    expect(env.error).toBeNull();
    expect(env.meta.version).toBe(API_VERSION);
    expect(env.meta.timestamp).toBeGreaterThan(0);
  });

  it("includes rateLimit when provided", () => {
    const rl = { limit: 60, remaining: 42, reset: 1700000000 };
    const env = successEnvelope("ok", rl);
    expect(env.meta.rateLimit).toEqual(rl);
  });

  it("omits rateLimit when not provided", () => {
    const env = successEnvelope(null);
    expect(env.meta.rateLimit).toBeUndefined();
  });
});

describe("errorEnvelope", () => {
  it("wraps error with ok: false", () => {
    const env = errorEnvelope("Not Found");
    expect(env.ok).toBe(false);
    expect(env.data).toBeNull();
    expect(env.error).toBe("Not Found");
    expect(env.meta.version).toBe(API_VERSION);
  });
});

// ── rateLimitHeaders ─────────────────────────────────────────────────────

describe("rateLimitHeaders", () => {
  it("builds correct header map", () => {
    const h = rateLimitHeaders({ limit: 100, remaining: 5, reset: 1700000000 });
    expect(h["X-RateLimit-Limit"]).toBe("100");
    expect(h["X-RateLimit-Remaining"]).toBe("5");
    expect(h["X-RateLimit-Reset"]).toBe("1700000000");
  });
});

// ── corsHeaders ──────────────────────────────────────────────────────────

describe("corsHeaders", () => {
  it("returns CORS defaults", () => {
    const h = corsHeaders();
    expect(h["Access-Control-Allow-Origin"]).toBe("*");
    expect(h["Access-Control-Allow-Methods"]).toContain("GET");
  });

  it("merges extra headers", () => {
    const h = corsHeaders({ "X-Custom": "value" });
    expect(h["X-Custom"]).toBe("value");
    expect(h["Access-Control-Allow-Origin"]).toBe("*");
  });
});

// ── parsePagination ──────────────────────────────────────────────────────

describe("parsePagination", () => {
  it("defaults to page 1, pageSize 20", () => {
    const p = parsePagination(makeParams({}));
    expect(p.page).toBe(1);
    expect(p.pageSize).toBe(DEFAULT_PAGE_SIZE);
  });

  it("parses explicit values", () => {
    const p = parsePagination(makeParams({ page: "3", pageSize: "50" }));
    expect(p.page).toBe(3);
    expect(p.pageSize).toBe(50);
  });

  it("clamps page to minimum 1", () => {
    const p = parsePagination(makeParams({ page: "-5" }));
    expect(p.page).toBe(1);
  });

  it("clamps pageSize to MAX_PAGE_SIZE", () => {
    const p = parsePagination(makeParams({ pageSize: "9999" }));
    expect(p.pageSize).toBe(MAX_PAGE_SIZE);
  });

  it("supports page_size alias", () => {
    const p = parsePagination(makeParams({ page_size: "10" }));
    expect(p.pageSize).toBe(10);
  });

  it("handles NaN gracefully", () => {
    const p = parsePagination(makeParams({ page: "abc", pageSize: "xyz" }));
    expect(p.page).toBe(1);
    expect(p.pageSize).toBe(DEFAULT_PAGE_SIZE);
  });
});

// ── paginate ─────────────────────────────────────────────────────────────

describe("paginate", () => {
  const data = Array.from({ length: 55 }, (_, i) => i);

  it("returns first page", () => {
    const result = paginate(data, { page: 1, pageSize: 20 });
    expect(result.items).toHaveLength(20);
    expect(result.items[0]).toBe(0);
    expect(result.totalItems).toBe(55);
    expect(result.totalPages).toBe(3);
  });

  it("returns last partial page", () => {
    const result = paginate(data, { page: 3, pageSize: 20 });
    expect(result.items).toHaveLength(15);
    expect(result.items[0]).toBe(40);
  });

  it("returns empty for out-of-range page", () => {
    const result = paginate(data, { page: 99, pageSize: 20 });
    expect(result.items).toHaveLength(0);
  });

  it("handles empty array", () => {
    const result = paginate([], { page: 1, pageSize: 20 });
    expect(result.items).toHaveLength(0);
    expect(result.totalPages).toBe(1);
  });
});

// ── parseFields / pickFields ─────────────────────────────────────────────

describe("parseFields", () => {
  it("parses comma-separated fields", () => {
    expect(parseFields(makeParams({ fields: "open,high,close" }))).toEqual([
      "open",
      "high",
      "close",
    ]);
  });

  it("trims whitespace", () => {
    expect(parseFields(makeParams({ fields: " open , close " }))).toEqual(["open", "close"]);
  });

  it("returns null when absent", () => {
    expect(parseFields(makeParams({}))).toBeNull();
  });

  it("filters empty strings", () => {
    expect(parseFields(makeParams({ fields: "open,,close" }))).toEqual(["open", "close"]);
  });
});

describe("pickFields", () => {
  const obj = { open: 100, high: 110, low: 95, close: 105, volume: 1000 };

  it("picks specified fields", () => {
    expect(pickFields(obj, ["open", "close"])).toEqual({ open: 100, close: 105 });
  });

  it("returns full object when fields is null", () => {
    expect(pickFields(obj, null)).toEqual(obj);
  });

  it("ignores unknown fields", () => {
    expect(pickFields(obj, ["open", "nonexistent"])).toEqual({ open: 100 });
  });
});

// ── isValidTicker ────────────────────────────────────────────────────────

describe("isValidTicker", () => {
  it("accepts simple tickers", () => {
    expect(isValidTicker("AAPL")).toBe(true);
    expect(isValidTicker("MSFT")).toBe(true);
    expect(isValidTicker("A")).toBe(true);
  });

  it("accepts exchange-suffixed tickers", () => {
    expect(isValidTicker("RDSA.AS")).toBe(true);
  });

  it("rejects lowercase", () => {
    expect(isValidTicker("aapl")).toBe(false);
  });

  it("rejects too long", () => {
    expect(isValidTicker("ABCDEF")).toBe(false);
  });

  it("rejects numbers", () => {
    expect(isValidTicker("AA1")).toBe(false);
  });

  it("rejects empty", () => {
    expect(isValidTicker("")).toBe(false);
  });
});

// ── isValidDateParam ─────────────────────────────────────────────────────

describe("isValidDateParam", () => {
  it("accepts valid ISO dates", () => {
    expect(isValidDateParam("2024-01-15")).toBe(true);
    expect(isValidDateParam("2023-12-31")).toBe(true);
  });

  it("rejects invalid formats", () => {
    expect(isValidDateParam("01-15-2024")).toBe(false);
    expect(isValidDateParam("2024/01/15")).toBe(false);
    expect(isValidDateParam("not-a-date")).toBe(false);
  });

  it("rejects invalid dates", () => {
    expect(isValidDateParam("2024-13-01")).toBe(false);
  });
});
