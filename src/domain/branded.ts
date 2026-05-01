/**
 * Branded primitive types and runtime guards for domain values.
 * Branded types prevent mixing arbitrary strings/numbers where a Ticker
 * or ISODate is expected. Guards perform light validation at boundaries
 * (provider responses, URL params, config import).
 */

declare const TICKER_BRAND: unique symbol;
declare const ISO_DATE_BRAND: unique symbol;
declare const PRICE_BRAND: unique symbol;
declare const PERCENT_BRAND: unique symbol;

export type Ticker = string & { readonly [TICKER_BRAND]: true };
export type ISODate = string & { readonly [ISO_DATE_BRAND]: true };
export type Price = number & { readonly [PRICE_BRAND]: true };
export type Percent = number & { readonly [PERCENT_BRAND]: true };

const TICKER_RE = /^[A-Z][A-Z0-9.-]{0,9}$/;
const ISO_DATE_RE = /^\d{4}-\d{2}-\d{2}(T\d{2}:\d{2}(:\d{2}(\.\d+)?)?(Z|[+-]\d{2}:?\d{2})?)?$/;

export function isTicker(v: unknown): v is Ticker {
  return typeof v === "string" && TICKER_RE.test(v);
}

export function asTicker(v: unknown): Ticker {
  const upper = typeof v === "string" ? v.trim().toUpperCase() : v;
  if (!isTicker(upper)) {
    throw new TypeError(`Invalid ticker: ${String(v)}`);
  }
  return upper;
}

export function isISODate(v: unknown): v is ISODate {
  if (typeof v !== "string" || !ISO_DATE_RE.test(v)) return false;
  const t = Date.parse(v);
  return Number.isFinite(t);
}

export function asISODate(v: unknown): ISODate {
  if (!isISODate(v)) throw new TypeError(`Invalid ISO date: ${String(v)}`);
  return v;
}

export function isPrice(v: unknown): v is Price {
  return typeof v === "number" && Number.isFinite(v) && v >= 0;
}

export function asPrice(v: unknown): Price {
  if (!isPrice(v)) throw new TypeError(`Invalid price: ${String(v)}`);
  return v;
}

export function isPercent(v: unknown): v is Percent {
  return typeof v === "number" && Number.isFinite(v);
}

export function asPercent(v: unknown): Percent {
  if (!isPercent(v)) throw new TypeError(`Invalid percent: ${String(v)}`);
  return v;
}

/** Try-cast: returns the branded value or null. */
export function tryTicker(v: unknown): Ticker | null {
  try {
    return asTicker(v);
  } catch {
    return null;
  }
}
