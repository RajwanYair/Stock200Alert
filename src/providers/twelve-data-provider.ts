/**
 * Twelve Data provider — fetches quotes and history via Twelve Data REST API.
 * Free tier: 800 requests/day. API key stored in Cloudflare Worker env var.
 */
import type { DailyCandle } from "../types/domain";
import type { MarketDataProvider, Quote, SearchResult, ProviderHealth } from "./types";
import { fetchWithRetry, FetchError } from "../core/fetch";

const DEFAULT_BASE_URL = "https://api.twelvedata.com";

interface TwelveQuoteResponse {
  price?: string;
  open?: string;
  high?: string;
  low?: string;
  previous_close?: string;
  volume?: string;
  symbol?: string;
  timestamp?: number;
  code?: number;
  message?: string;
}

interface TwelveTimeSeriesResponse {
  status?: string;
  values?: Array<{
    datetime: string;
    open: string;
    high: string;
    low: string;
    close: string;
    volume: string;
  }>;
  code?: number;
  message?: string;
}

interface TwelveSearchResponse {
  data?: Array<{
    symbol: string;
    instrument_name: string;
    exchange: string;
    instrument_type: string;
  }>;
}

export function createTwelveDataProvider(
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
    const params = new URLSearchParams({ symbol: ticker, apikey: apiKey });
    const url = `${baseUrl}/quote?${params.toString()}`;
    try {
      const res = await fetchWithRetry(url, {}, 2, 500);
      const data = (await res.json()) as TwelveQuoteResponse;

      if (data.code !== undefined && data.code >= 400) {
        throw new FetchError(data.message ?? `Twelve Data error: ${String(data.code)}`);
      }
      if (!data.price) throw new FetchError("No price in Twelve Data response for " + ticker);

      recordSuccess();
      return {
        ticker: data.symbol ?? ticker,
        price: parseFloat(data.price),
        open: parseFloat(data.open ?? data.price),
        high: parseFloat(data.high ?? data.price),
        low: parseFloat(data.low ?? data.price),
        previousClose: parseFloat(data.previous_close ?? data.price),
        volume: parseInt(data.volume ?? "0", 10),
        timestamp: data.timestamp !== undefined ? data.timestamp * 1000 : Date.now(),
      };
    } catch (err) {
      recordError();
      throw err;
    }
  }

  async function getHistory(ticker: string, days: number): Promise<readonly DailyCandle[]> {
    const params = new URLSearchParams({
      symbol: ticker,
      interval: "1day",
      outputsize: String(days),
      apikey: apiKey,
    });
    const url = `${baseUrl}/time_series?${params.toString()}`;
    try {
      const res = await fetchWithRetry(url, {}, 2, 500);
      const data = (await res.json()) as TwelveTimeSeriesResponse;

      if (data.code !== undefined && data.code >= 400) {
        throw new FetchError(data.message ?? `Twelve Data error: ${String(data.code)}`);
      }
      if (!data.values || data.values.length === 0) {
        throw new FetchError("No time series data for " + ticker);
      }

      recordSuccess();
      // Twelve Data returns newest-first; reverse to oldest-first
      return data.values
        .slice()
        .reverse()
        .map((v) => ({
          date: v.datetime.slice(0, 10),
          open: parseFloat(v.open),
          high: parseFloat(v.high),
          low: parseFloat(v.low),
          close: parseFloat(v.close),
          volume: parseInt(v.volume, 10),
        }));
    } catch (err) {
      recordError();
      throw err;
    }
  }

  async function search(query: string): Promise<readonly SearchResult[]> {
    const params = new URLSearchParams({ symbol: query, apikey: apiKey });
    const url = `${baseUrl}/symbol_search?${params.toString()}`;
    try {
      const res = await fetchWithRetry(url, {}, 1, 500);
      const data = (await res.json()) as TwelveSearchResponse;
      recordSuccess();
      return (data.data ?? []).map((d) => ({
        symbol: d.symbol,
        name: d.instrument_name,
        exchange: d.exchange,
        type: d.instrument_type,
      }));
    } catch (err) {
      recordError();
      throw err;
    }
  }

  function health(): ProviderHealth {
    return {
      name: "twelve-data",
      available: consecutiveErrors < 3,
      lastSuccessAt,
      lastErrorAt,
      consecutiveErrors,
    };
  }

  return { name: "twelve-data", getQuote, getHistory, search, health };
}
