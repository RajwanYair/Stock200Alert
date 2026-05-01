/**
 * POST /api/screener
 *
 * Filters a list of tickers by technical criteria and returns consensus scores.
 *
 * Request body (JSON):
 *  {
 *    tickers: string[],      // required, 1–50 tickers
 *    minRsi?: number,        // 0–100, default 0
 *    maxRsi?: number,        // 0–100, default 100
 *    minAdx?: number,        // 0–100, default 0
 *    consensus?: "BUY" | "SELL" | "NEUTRAL"
 *  }
 *
 * Response:
 *  { rows: ScreenerRow[] }
 *
 * Values are deterministically seeded per ticker so the API is stable across
 * deployments without external data. In production, replace with real indicators
 * computed from live or cached candle data.
 */

export interface ScreenerParams {
  tickers: string[];
  minRsi?: number;
  maxRsi?: number;
  minAdx?: number;
  consensus?: "BUY" | "SELL" | "NEUTRAL";
}

export interface ScreenerRow {
  ticker: string;
  consensus: string;
  rsi: number;
  adx: number;
  score: number;
}

export interface ScreenerResponse {
  rows: ScreenerRow[];
}

const CONSENSUS_OPTIONS = ["BUY", "HOLD", "SELL", "NEUTRAL"] as const;

/** Deterministic hash to a float 0–1. */
function pseudoRand(seed: string, salt: number): number {
  let h = 0xdeadbeef ^ salt;
  for (let i = 0; i < seed.length; i++) {
    h = Math.imul(h ^ seed.charCodeAt(i), 0x9e3779b9);
    h ^= h >>> 16;
  }
  return (h >>> 0) / 0xffffffff;
}

function syntheticRow(ticker: string): ScreenerRow {
  const rsi = Math.round(pseudoRand(ticker, 1) * 80 + 10); // 10–90
  const adx = Math.round(pseudoRand(ticker, 2) * 60 + 10); // 10–70
  const score = Math.round(pseudoRand(ticker, 3) * 100);
  const cIdx = Math.floor(pseudoRand(ticker, 4) * CONSENSUS_OPTIONS.length);
  const consensus = CONSENSUS_OPTIONS[cIdx] ?? "NEUTRAL";
  return { ticker, consensus, rsi, adx, score };
}

export async function handleScreener(request: Request): Promise<Response> {
  let body: unknown;
  try {
    body = await request.json();
  } catch {
    return new Response(JSON.stringify({ error: "Invalid JSON body" }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }

  if (typeof body !== "object" || body === null || !("tickers" in body)) {
    return new Response(JSON.stringify({ error: "Missing required field: tickers" }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }

  const params = body as ScreenerParams;

  if (!Array.isArray(params.tickers) || params.tickers.length === 0) {
    return new Response(JSON.stringify({ error: "tickers must be a non-empty array" }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }

  if (params.tickers.length > 50) {
    return new Response(JSON.stringify({ error: "Maximum 50 tickers per request" }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }

  const minRsi = params.minRsi ?? 0;
  const maxRsi = params.maxRsi ?? 100;
  const minAdx = params.minAdx ?? 0;

  const rows = params.tickers
    .map((t) => syntheticRow(String(t).toUpperCase().slice(0, 12)))
    .filter((row) => {
      if (row.rsi < minRsi || row.rsi > maxRsi) return false;
      if (row.adx < minAdx) return false;
      if (params.consensus && row.consensus !== params.consensus) return false;
      return true;
    });

  const responseBody: ScreenerResponse = { rows };
  return new Response(JSON.stringify(responseBody), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
}
