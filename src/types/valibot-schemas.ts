/**
 * Valibot runtime schemas for external API boundary validation.
 *
 * These schemas validate and type-narrow raw JSON from data providers
 * (Yahoo Finance, Finnhub) before it is mapped into domain types.
 * Using Valibot (~3 KB gz) instead of Zod keeps the bundle small.
 *
 * Usage:
 *   import { safeParse } from 'valibot';
 *   import { YahooChartSchema } from './valibot-schemas';
 *   const result = safeParse(YahooChartSchema, raw);
 *   if (!result.success) throw new Error('Bad response shape');
 *   const data = result.output;
 */
import {
  object,
  string,
  number,
  array,
  nullable,
  optional,
  union,
  literal,
  pipe,
  minLength,
  minValue,
  transform,
  check,
} from "valibot";

// ---------------------------------------------------------------------------
// Domain-level schemas
// ---------------------------------------------------------------------------

/** ISO-8601 date string (YYYY-MM-DD). */
export const IsoDateSchema = pipe(
  string(),
  minLength(10),
  check((s: string) => /^\d{4}-\d{2}-\d{2}/.test(s), "Not an ISO-8601 date"),
  transform((s: string) => s.slice(0, 10)),
);

/** Non-negative finite number (price, volume, etc.). */
export const NonNegativeNumberSchema = pipe(number(), minValue(0));

/** Ticker symbol — non-empty string. */
export const TickerStringSchema = pipe(string(), minLength(1));

// ---------------------------------------------------------------------------
// DailyCandle schema
// ---------------------------------------------------------------------------

export const DailyCandleSchema = object({
  date: IsoDateSchema,
  open: NonNegativeNumberSchema,
  high: NonNegativeNumberSchema,
  low: NonNegativeNumberSchema,
  close: NonNegativeNumberSchema,
  volume: NonNegativeNumberSchema,
});

// ---------------------------------------------------------------------------
// Yahoo Finance v8 chart API schemas
// ---------------------------------------------------------------------------

const YahooOhlcvSchema = object({
  open: optional(array(nullable(number()))),
  high: optional(array(nullable(number()))),
  low: optional(array(nullable(number()))),
  close: optional(array(nullable(number()))),
  volume: optional(array(nullable(number()))),
});

const YahooMetaSchema = object({
  regularMarketPrice: optional(number()),
  previousClose: optional(number()),
  symbol: optional(string()),
  instrumentType: optional(string()),
  sector: optional(string()),
});

const YahooResultSchema = object({
  meta: optional(YahooMetaSchema),
  timestamp: optional(array(number())),
  indicators: optional(
    object({
      quote: optional(array(YahooOhlcvSchema)),
    }),
  ),
});

export const YahooChartSchema = object({
  chart: optional(
    object({
      result: optional(array(YahooResultSchema)),
      error: optional(
        nullable(object({ code: optional(string()), description: optional(string()) })),
      ),
    }),
  ),
});

// ---------------------------------------------------------------------------
// Yahoo Finance symbol search API schema
// ---------------------------------------------------------------------------

const YahooSearchItemSchema = object({
  symbol: optional(string()),
  shortname: optional(string()),
  longname: optional(string()),
  exchDisp: optional(string()),
  quoteType: optional(string()),
});

export const YahooSearchSchema = object({
  quotes: optional(array(YahooSearchItemSchema)),
});

// ---------------------------------------------------------------------------
// Finnhub quote schema
// ---------------------------------------------------------------------------

export const FinnhubQuoteSchema = object({
  c: number(), // current price
  o: number(), // open
  h: number(), // high
  l: number(), // low
  pc: number(), // previous close
  t: optional(number()), // unix timestamp
});

// ---------------------------------------------------------------------------
// Finnhub candle schema
// ---------------------------------------------------------------------------

export const FinnhubCandleSchema = object({
  s: union([literal("ok"), literal("no_data")]),
  t: optional(array(number())),
  o: optional(array(number())),
  h: optional(array(number())),
  l: optional(array(number())),
  c: optional(array(number())),
  v: optional(array(number())),
});

// ---------------------------------------------------------------------------
// Finnhub search schema
// ---------------------------------------------------------------------------

const FinnhubSearchItemSchema = object({
  description: string(),
  displaySymbol: string(),
  symbol: string(),
  type: string(),
});

export const FinnhubSearchSchema = object({
  result: optional(array(FinnhubSearchItemSchema)),
});

// ---------------------------------------------------------------------------
// CoinGecko quote schema (for crypto providers)
// ---------------------------------------------------------------------------

export const CoinGeckoMarketDataSchema = object({
  id: string(),
  symbol: string(),
  name: string(),
  current_price: optional(number()),
  high_24h: optional(number()),
  low_24h: optional(number()),
  price_change_24h: optional(number()),
  total_volume: optional(number()),
  market_cap: optional(number()),
  last_updated: optional(string()),
  ath: optional(number()),
  atl: optional(number()),
  sparkline_in_7d: optional(
    object({
      price: optional(array(number())),
    }),
  ),
});

export const CoinGeckoMarketsSchema = array(CoinGeckoMarketDataSchema);

// ---------------------------------------------------------------------------
// Re-export inferred output types for use in providers
// ---------------------------------------------------------------------------
export type { InferOutput } from "valibot";

// Convenience re-export so providers only need one import
export { safeParse, parse, ValiError } from "valibot";
