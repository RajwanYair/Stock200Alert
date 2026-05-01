/**
 * Finnhub provider — quote / history / symbol search via Finnhub REST API.
 *
 * Free tier: 60 requests/minute. API key is supplied by the proxy Worker
 * (never sent from the browser).
 * API responses are validated with Valibot before mapping to domain types.
 */
import type { DailyCandle } from "../types/domain";
import type { MarketDataProvider, ProviderHealth, Quote, SearchResult } from "./types";
import { FetchError, fetchWithRetry } from "../core/fetch";
import {
  safeParse,
  FinnhubQuoteSchema,
  FinnhubCandleSchema,
  FinnhubSearchSchema,
} from "../types/valibot-schemas";

const DEFAULT_BASE_URL = "https://finnhub.io/api/v1";

export function createFinnhubProvider(
  apiKey: string,
  baseUrl: string = DEFAULT_BASE_URL,
): MarketDataProvider {
  let lastSuccessAt: number | null = null;
  let lastErrorAt: number | null = null;
  let consecutiveErrors = 0;

  function recordSuccess(): void {
    lastSuccessAt = Date.now();
    consecutiveErrors = 0;
  }

  function recordError(): void {
    lastErrorAt = Date.now();
    consecutiveErrors++;
  }

  async function getQuote(ticker: string): Promise<Quote> {
    const url =
      `${baseUrl}/quote?symbol=${encodeURIComponent(ticker)}` +
      `&token=${encodeURIComponent(apiKey)}`;
    try {
      const res = await fetchWithRetry(url, {}, 2, 500);
      const raw: unknown = await res.json();
      const parsed = safeParse(FinnhubQuoteSchema, raw);
      if (!parsed.success) {
        throw new FetchError(`Finnhub: malformed quote for ${ticker}`);
      }
      const data = parsed.output;
      recordSuccess();
      return {
        ticker,
        price: data.c,
        open: data.o,
        high: data.h,
        low: data.l,
        previousClose: data.pc,
        volume: 0,
        timestamp: (data.t ?? Math.floor(Date.now() / 1000)) * 1000,
      };
    } catch (err) {
      recordError();
      throw err;
    }
  }

  async function getHistory(ticker: string, days: number): Promise<readonly DailyCandle[]> {
    const to = Math.floor(Date.now() / 1000);
    const from = to - days * 24 * 60 * 60;
    const url =
      `${baseUrl}/stock/candle?symbol=${encodeURIComponent(ticker)}` +
      `&resolution=D&from=${from}&to=${to}` +
      `&token=${encodeURIComponent(apiKey)}`;
    try {
      const res = await fetchWithRetry(url, {}, 2, 500);
      const raw: unknown = await res.json();
      const parsed = safeParse(FinnhubCandleSchema, raw);
      if (!parsed.success || parsed.output.s !== "ok") {
        throw new FetchError(`Finnhub: no candles for ${ticker}`);
      }
      const data = parsed.output;
      const t = data.t;
      const o = data.o;
      const h = data.h;
      const l = data.l;
      const c = data.c;
      if (!t || !o || !h || !l || !c) throw new FetchError(`Finnhub: incomplete candle data for ${ticker}`);

      const out: DailyCandle[] = [];
      for (let i = 0; i < t.length; i++) {
        const ts = t[i];
        const ov = o[i];
        const hv = h[i];
        const lv = l[i];
        const cv = c[i];
        const v = data.v?.[i] ?? 0;
        if (ts === undefined || ov === undefined || hv === undefined || lv === undefined || cv === undefined) continue;
        out.push({
          date: new Date(ts * 1000).toISOString().slice(0, 10),
          open: ov,
          high: hv,
          low: lv,
          close: cv,
          volume: v,
        });
      }
      recordSuccess();
      return out;
    } catch (err) {
      recordError();
      throw err;
    }
  }

  async function search(query: string): Promise<readonly SearchResult[]> {
    const url = `${baseUrl}/search?q=${encodeURIComponent(query)}&token=${encodeURIComponent(apiKey)}`;
    try {
      const res = await fetchWithRetry(url, {}, 2, 500);
      const raw: unknown = await res.json();
      const parsed = safeParse(FinnhubSearchSchema, raw);
      if (!parsed.success) throw new FetchError("Finnhub: invalid search response");
      const data = parsed.output;
      recordSuccess();
      return (data.result ?? []).map((r) => ({
        symbol: r.symbol,
        name: r.description,
        type: r.type,
      }));
    } catch (err) {
      recordError();
      throw err;
    }
  }

  function health(): ProviderHealth {
    return {
      name: "finnhub",
      available: consecutiveErrors < 3,
      lastSuccessAt,
      lastErrorAt,
      consecutiveErrors,
    };
  }

  return { name: "finnhub", getQuote, getHistory, search, health };
}
