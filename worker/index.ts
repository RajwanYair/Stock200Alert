/**
 * CrossTide API Worker — Cloudflare Workers ES modules entry point.
 *
 * Routes:
 *  GET  /api/health             Worker status + version
 *  GET  /api/chart              OHLCV candles (ticker, range, interval params)
 *  GET  /api/search             Ticker fuzzy search (q, limit params)
 *  POST /api/screener           Technical screener with consensus filter
 *  GET  /api/og/:symbol         Social preview SVG image
 *
 * All routes:
 *  - Rate-limited to 60 req/min per IP (in-memory per isolate)
 *  - CORS headers for crosstide.pages.dev and localhost
 *  - JSON error responses with { error: string } shape
 *
 * @see worker/wrangler.toml for deployment configuration.
 * @see src/core/worker-api-client.ts for the typed browser client.
 */

import { corsHeaders, handlePreflight, withCors } from "./cors.js";
import { checkRateLimit, rateLimitKey, tooManyRequests } from "./rate-limit.js";
import { handleHealth } from "./routes/health.js";
import { handleChart } from "./routes/chart.js";
import { handleSearch } from "./routes/search.js";
import { handleScreener } from "./routes/screener.js";
import { handleOgImage } from "./routes/og.js";

export interface Env {
  ENVIRONMENT?: string;
  API_VERSION?: string;
  // Optional KV + R2 bindings (declared in wrangler.toml)
  // QUOTE_CACHE?: KVNamespace;
  // OHLCV_STORE?: R2Bucket;
}

function notFound(origin: string | null): Response {
  return withCors(
    new Response(JSON.stringify({ error: "Not found" }), {
      status: 404,
      headers: { "Content-Type": "application/json" },
    }),
    origin,
  );
}

function methodNotAllowed(origin: string | null): Response {
  return withCors(
    new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { "Content-Type": "application/json" },
    }),
    origin,
  );
}

async function route(request: Request, env: Env): Promise<Response> {
  const url = new URL(request.url);
  const { pathname, method } = { pathname: url.pathname, method: request.method };
  const origin = request.headers.get("Origin");

  // CORS preflight
  if (method === "OPTIONS") {
    return handlePreflight(request);
  }

  // Strip trailing slash for matching
  const path = pathname.endsWith("/") && pathname.length > 1 ? pathname.slice(0, -1) : pathname;

  // ── GET /api/health ────────────────────────────────────────────────────────
  if (path === "/api/health" || path === "/health") {
    if (method !== "GET") return methodNotAllowed(origin);
    return withCors(handleHealth(env), origin);
  }

  // ── GET /api/chart ─────────────────────────────────────────────────────────
  if (path === "/api/chart") {
    if (method !== "GET") return methodNotAllowed(origin);
    return withCors(handleChart(url), origin);
  }

  // ── GET /api/search ────────────────────────────────────────────────────────
  if (path === "/api/search") {
    if (method !== "GET") return methodNotAllowed(origin);
    return withCors(handleSearch(url), origin);
  }

  // ── POST /api/screener ─────────────────────────────────────────────────────
  if (path === "/api/screener") {
    if (method !== "POST") return methodNotAllowed(origin);
    return withCors(await handleScreener(request), origin);
  }

  // ── GET /api/og/:symbol ────────────────────────────────────────────────────
  if (path.startsWith("/api/og/") || path.startsWith("/api/og")) {
    if (method !== "GET") return methodNotAllowed(origin);
    return withCors(handleOgImage(url), origin);
  }

  // ── Favicon (no-op) ────────────────────────────────────────────────────────
  if (path === "/favicon.ico") {
    return new Response(null, { status: 204 });
  }

  return notFound(origin);
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    // Skip rate limiting for preflight requests
    if (request.method !== "OPTIONS") {
      const key = rateLimitKey(request);
      const origin = request.headers.get("Origin");
      if (!checkRateLimit(key)) {
        return tooManyRequests(corsHeaders(origin));
      }
    }

    try {
      return await route(request, env);
    } catch (err) {
      const origin = request.headers.get("Origin");
      return withCors(
        new Response(JSON.stringify({ error: "Internal server error" }), {
          status: 500,
          headers: { "Content-Type": "application/json" },
        }),
        origin,
      );
    }
  },
};
