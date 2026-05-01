/**
 * Tests for the Cloudflare Worker API routes.
 *
 * Uses the default export's fetch handler directly so tests don't need
 * a Miniflare / Cloudflare runtime. All routes are pure HTTP logic.
 */
import { describe, it, expect } from "vitest";
import worker from "../../../worker/index";
import { checkRateLimit } from "../../../worker/rate-limit";
import { getAllowedOrigin } from "../../../worker/cors";

// Minimal Env object for tests
const ENV = { ENVIRONMENT: "test", API_VERSION: "1" };

function makeRequest(
  method: string,
  path: string,
  opts: { body?: string; origin?: string } = {},
): Request {
  const url = `https://api.crosstide.dev${path}`;
  return new Request(url, {
    method,
    headers: {
      ...(opts.origin ? { Origin: opts.origin } : {}),
      ...(opts.body ? { "Content-Type": "application/json" } : {}),
      "CF-Connecting-IP": "1.2.3.4",
    },
    body: opts.body,
  });
}

// ── /api/health ─────────────────────────────────────────────────────────────

describe("GET /api/health", () => {
  it("returns status ok", async () => {
    const res = await worker.fetch(makeRequest("GET", "/api/health"), ENV);
    expect(res.status).toBe(200);
    const body = await res.json() as { status: string; version: string };
    expect(body.status).toBe("ok");
    expect(body.version).toBe("1");
  });

  it("returns 405 for POST", async () => {
    const res = await worker.fetch(makeRequest("POST", "/api/health", { body: "{}" }), ENV);
    expect(res.status).toBe(405);
  });
});

// ── /api/chart ───────────────────────────────────────────────────────────────

describe("GET /api/chart", () => {
  it("returns candles for AAPL", async () => {
    const res = await worker.fetch(makeRequest("GET", "/api/chart?ticker=AAPL&range=1mo"), ENV);
    expect(res.status).toBe(200);
    const body = await res.json() as { ticker: string; candles: unknown[] };
    expect(body.ticker).toBe("AAPL");
    expect(body.candles.length).toBeGreaterThan(0);
  });

  it("returns 400 for missing ticker", async () => {
    const res = await worker.fetch(makeRequest("GET", "/api/chart"), ENV);
    expect(res.status).toBe(400);
  });

  it("returns 400 for invalid ticker", async () => {
    const res = await worker.fetch(
      makeRequest("GET", "/api/chart?ticker=" + encodeURIComponent("<script>")),
      ENV,
    );
    expect(res.status).toBe(400);
  });

  it("returns 400 for invalid range", async () => {
    const res = await worker.fetch(makeRequest("GET", "/api/chart?ticker=MSFT&range=99y"), ENV);
    expect(res.status).toBe(400);
  });

  it("returns deterministic candles (same seed = same result)", async () => {
    const r1 = await worker.fetch(makeRequest("GET", "/api/chart?ticker=TSLA&range=1mo"), ENV);
    const r2 = await worker.fetch(makeRequest("GET", "/api/chart?ticker=TSLA&range=1mo"), ENV);
    const b1 = await r1.json() as { candles: Array<{ close: number }> };
    const b2 = await r2.json() as { candles: Array<{ close: number }> };
    expect(b1.candles[0]?.close).toBe(b2.candles[0]?.close);
  });

  it("OHLCV shape is correct", async () => {
    const res = await worker.fetch(makeRequest("GET", "/api/chart?ticker=GOOGL&range=5d"), ENV);
    const body = await res.json() as { candles: Array<Record<string, unknown>> };
    const candle = body.candles[0];
    expect(candle).toHaveProperty("date");
    expect(candle).toHaveProperty("open");
    expect(candle).toHaveProperty("high");
    expect(candle).toHaveProperty("low");
    expect(candle).toHaveProperty("close");
    expect(candle).toHaveProperty("volume");
    // OHLCV integrity: high >= max(open, close) and low <= min(open, close)
    const o = candle["open"] as number;
    const h = candle["high"] as number;
    const l = candle["low"] as number;
    const c = candle["close"] as number;
    expect(h).toBeGreaterThanOrEqual(Math.max(o, c));
    expect(l).toBeLessThanOrEqual(Math.min(o, c));
  });
});

// ── /api/search ──────────────────────────────────────────────────────────────

describe("GET /api/search", () => {
  it("finds AAPL", async () => {
    const res = await worker.fetch(makeRequest("GET", "/api/search?q=aapl"), ENV);
    expect(res.status).toBe(200);
    const body = await res.json() as { results: Array<{ ticker: string }> };
    expect(body.results[0]?.ticker).toBe("AAPL");
  });

  it("finds SPY by partial name", async () => {
    const res = await worker.fetch(makeRequest("GET", "/api/search?q=spy"), ENV);
    expect(res.status).toBe(200);
    const body = await res.json() as { results: Array<{ ticker: string }> };
    expect(body.results.some((r) => r.ticker === "SPY")).toBe(true);
  });

  it("respects limit param", async () => {
    const res = await worker.fetch(makeRequest("GET", "/api/search?q=a&limit=3"), ENV);
    const body = await res.json() as { results: unknown[] };
    expect(body.results.length).toBeLessThanOrEqual(3);
  });

  it("returns 400 for empty query", async () => {
    const res = await worker.fetch(makeRequest("GET", "/api/search?q="), ENV);
    expect(res.status).toBe(400);
  });

  it("returns 400 for query > 50 chars", async () => {
    const q = "x".repeat(51);
    const res = await worker.fetch(makeRequest("GET", `/api/search?q=${q}`), ENV);
    expect(res.status).toBe(400);
  });
});

// ── /api/screener ─────────────────────────────────────────────────────────────

describe("POST /api/screener", () => {
  it("filters tickers and returns rows", async () => {
    const body = JSON.stringify({ tickers: ["AAPL", "MSFT", "TSLA"] });
    const res = await worker.fetch(makeRequest("POST", "/api/screener", { body }), ENV);
    expect(res.status).toBe(200);
    const data = await res.json() as { rows: Array<{ ticker: string; rsi: number }> };
    expect(data.rows.length).toBeGreaterThan(0);
    expect(data.rows[0]).toHaveProperty("ticker");
    expect(data.rows[0]).toHaveProperty("rsi");
    expect(data.rows[0]).toHaveProperty("adx");
    expect(data.rows[0]).toHaveProperty("consensus");
  });

  it("filters by minRsi", async () => {
    const body = JSON.stringify({ tickers: ["AAPL", "MSFT", "NVDA", "TSLA", "AMZN"], minRsi: 70 });
    const res = await worker.fetch(makeRequest("POST", "/api/screener", { body }), ENV);
    const data = await res.json() as { rows: Array<{ rsi: number }> };
    for (const row of data.rows) {
      expect(row.rsi).toBeGreaterThanOrEqual(70);
    }
  });

  it("returns 400 for missing tickers", async () => {
    const res = await worker.fetch(
      makeRequest("POST", "/api/screener", { body: JSON.stringify({ minRsi: 50 }) }),
      ENV,
    );
    expect(res.status).toBe(400);
  });

  it("returns 400 for empty tickers array", async () => {
    const res = await worker.fetch(
      makeRequest("POST", "/api/screener", { body: JSON.stringify({ tickers: [] }) }),
      ENV,
    );
    expect(res.status).toBe(400);
  });

  it("returns 400 for > 50 tickers", async () => {
    const tickers = Array.from({ length: 51 }, (_, i) => `T${i}`);
    const res = await worker.fetch(
      makeRequest("POST", "/api/screener", { body: JSON.stringify({ tickers }) }),
      ENV,
    );
    expect(res.status).toBe(400);
  });

  it("returns 400 for invalid JSON", async () => {
    const res = await worker.fetch(
      makeRequest("POST", "/api/screener", { body: "not json" }),
      ENV,
    );
    expect(res.status).toBe(400);
  });
});

// ── /api/og/:symbol ──────────────────────────────────────────────────────────

describe("GET /api/og/:symbol", () => {
  it("returns SVG for AAPL", async () => {
    const res = await worker.fetch(makeRequest("GET", "/api/og/AAPL"), ENV);
    expect(res.status).toBe(200);
    expect(res.headers.get("Content-Type")).toContain("image/svg+xml");
    const svg = await res.text();
    expect(svg).toContain("AAPL");
    expect(svg).toContain("<svg");
  });

  it("returns SVG for crypto ticker BTC-USD", async () => {
    const res = await worker.fetch(makeRequest("GET", "/api/og/BTC-USD"), ENV);
    expect(res.status).toBe(200);
    const svg = await res.text();
    expect(svg).toContain("BTC-USD");
  });

  it("returns 400 for invalid symbol", async () => {
    const res = await worker.fetch(makeRequest("GET", "/api/og/" + encodeURIComponent("<bad>")), ENV);
    expect(res.status).toBe(400);
  });

  it("includes direction badge when provided", async () => {
    const res = await worker.fetch(
      makeRequest("GET", "/api/og/NVDA?direction=BUY&price=500&change=2.5"),
      ENV,
    );
    const svg = await res.text();
    expect(svg).toContain("BUY");
  });
});

// ── CORS headers ─────────────────────────────────────────────────────────────

describe("CORS", () => {
  it("allows crosstide.pages.dev origin", () => {
    expect(getAllowedOrigin("https://crosstide.pages.dev")).toBe("https://crosstide.pages.dev");
  });

  it("allows localhost:5173 for development", () => {
    expect(getAllowedOrigin("http://localhost:5173")).toBe("http://localhost:5173");
  });

  it("falls back to production origin for unknown callers", () => {
    expect(getAllowedOrigin("https://evil.example.com")).toBe("https://crosstide.pages.dev");
  });

  it("returns CORS headers in response", async () => {
    // NOTE: happy-dom strips 'Origin' as a forbidden header in Request construction,
    // so the worker receives origin=null and returns the production fallback origin.
    // The important thing is that the ACAO header IS present.
    const res = await worker.fetch(
      makeRequest("GET", "/api/health", { origin: "http://localhost:5173" }),
      ENV,
    );
    const acao = res.headers.get("Access-Control-Allow-Origin");
    expect(acao).toBeTruthy();
    // Direct CORS util test (not filtered by Fetch forbidden-header rules):
    expect(getAllowedOrigin("http://localhost:5173")).toBe("http://localhost:5173");
    expect(getAllowedOrigin(null)).toBe("https://crosstide.pages.dev");
  });

  it("handles preflight OPTIONS correctly", async () => {
    const req = new Request("https://api.crosstide.dev/api/chart", {
      method: "OPTIONS",
      headers: { Origin: "http://localhost:5173" },
    });
    const res = await worker.fetch(req, ENV);
    expect(res.status).toBe(204);
    expect(res.headers.get("Access-Control-Allow-Methods")).toContain("GET");
  });
});

// ── Rate limiting ─────────────────────────────────────────────────────────────

describe("rate limiting", () => {
  it("allows up to 60 requests", () => {
    const key = `test-rl-${Math.random()}`;
    let allowed = 0;
    for (let i = 0; i < 60; i++) {
      if (checkRateLimit(key)) allowed++;
    }
    expect(allowed).toBe(60);
  });

  it("blocks the 61st request", () => {
    const key = `test-rl-block-${Math.random()}`;
    for (let i = 0; i < 60; i++) checkRateLimit(key);
    expect(checkRateLimit(key)).toBe(false);
  });

  it("refills after the window elapses", () => {
    const key = `test-rl-refill-${Math.random()}`;
    const start = Date.now();
    for (let i = 0; i < 60; i++) checkRateLimit(key, start);
    expect(checkRateLimit(key, start)).toBe(false);
    // Advance clock by >60s
    expect(checkRateLimit(key, start + 61_000)).toBe(true);
  });
});

// ── 404 + error paths ─────────────────────────────────────────────────────────

describe("routing", () => {
  it("returns 404 for unknown routes", async () => {
    const res = await worker.fetch(makeRequest("GET", "/api/unknown"), ENV);
    expect(res.status).toBe(404);
  });

  it("returns 404 for root path", async () => {
    const res = await worker.fetch(makeRequest("GET", "/"), ENV);
    expect(res.status).toBe(404);
  });

  it("ignores trailing slash", async () => {
    const res = await worker.fetch(makeRequest("GET", "/api/health/"), ENV);
    expect(res.status).toBe(200);
  });
});
