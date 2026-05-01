/**
 * i18n foundation — thin wrappers around Intl APIs for locale-aware formatting.
 *
 * All formatters respect the locale returned by `getLocale()` by default.
 * Pass an explicit locale string to override for a single call.
 *
 * Usage:
 *   import { formatNumber, formatCurrency, formatPercent, formatDate, formatRelativeTime } from "./i18n";
 *   formatNumber(1234567.89);            // "1,234,567.89"  (en-US)
 *   formatCurrency(49.99, "USD");        // "$49.99"
 *   formatPercent(0.0512);              // "5.12%"
 *   formatDate(new Date(), "short");    // "6/15/2025"
 *   formatRelativeTime(-2, "day");      // "2 days ago"
 */

/** Returns the active locale (browser navigator.language → fallback "en"). */
export function getLocale(): string {
  return (
    (typeof navigator !== "undefined" && navigator.language) ||
    "en"
  );
}

// ── Number ────────────────────────────────────────────────────────────────────

export interface NumberFormatOptions {
  locale?: string;
  minimumFractionDigits?: number;
  maximumFractionDigits?: number;
  notation?: "standard" | "compact" | "scientific" | "engineering";
}

/**
 * Format a number with locale-appropriate grouping and fraction digits.
 * Defaults: 0 – 2 fraction digits; "standard" notation.
 */
export function formatNumber(
  value: number,
  opts: NumberFormatOptions = {},
): string {
  const locale = opts.locale ?? getLocale();
  return new Intl.NumberFormat(locale, {
    notation: opts.notation ?? "standard",
    minimumFractionDigits: opts.minimumFractionDigits ?? 0,
    maximumFractionDigits: opts.maximumFractionDigits ?? 2,
  }).format(value);
}

/**
 * Format a compact number (e.g. 1.2M, 3.4B).
 */
export function formatCompact(value: number, locale?: string): string {
  return formatNumber(value, {
    ...(locale !== undefined && { locale }),
    notation: "compact",
    maximumFractionDigits: 1,
  });
}

// ── Currency ──────────────────────────────────────────────────────────────────

export interface CurrencyFormatOptions {
  locale?: string;
  /** "symbol" (default) | "narrowSymbol" | "code" | "name" */
  display?: "symbol" | "narrowSymbol" | "code" | "name";
  minimumFractionDigits?: number;
  maximumFractionDigits?: number;
}

/**
 * Format a monetary amount with currency symbol.
 * @param value   The numeric amount.
 * @param currency ISO 4217 code, e.g. "USD", "EUR", "JPY".
 */
export function formatCurrency(
  value: number,
  currency: string,
  opts: CurrencyFormatOptions = {},
): string {
  const locale = opts.locale ?? getLocale();
  return new Intl.NumberFormat(locale, {
    style: "currency",
    currency,
    currencyDisplay: opts.display ?? "symbol",
    minimumFractionDigits: opts.minimumFractionDigits,
    maximumFractionDigits: opts.maximumFractionDigits,
  }).format(value);
}

// ── Percent ───────────────────────────────────────────────────────────────────

export interface PercentFormatOptions {
  locale?: string;
  /** Number of fraction digits. Default 2. */
  fractionDigits?: number;
  /** Whether value is already in percent (e.g. 5.12 → "5.12%") vs ratio (0.0512). Default false. */
  alreadyPercent?: boolean;
}

/**
 * Format a fraction as a percentage.
 * @param value  Ratio (0.0512) or percent value if alreadyPercent is true.
 */
export function formatPercent(
  value: number,
  opts: PercentFormatOptions = {},
): string {
  const locale = opts.locale ?? getLocale();
  const ratio = opts.alreadyPercent ? value / 100 : value;
  return new Intl.NumberFormat(locale, {
    style: "percent",
    minimumFractionDigits: opts.fractionDigits ?? 2,
    maximumFractionDigits: opts.fractionDigits ?? 2,
  }).format(ratio);
}

// ── Date ──────────────────────────────────────────────────────────────────────

export type DateStyle = "full" | "long" | "medium" | "short";
export type TimeStyle = "full" | "long" | "medium" | "short";

export interface DateFormatOptions {
  locale?: string;
  dateStyle?: DateStyle;
  timeStyle?: TimeStyle;
}

/**
 * Format a Date (or timestamp ms) as a locale-aware date string.
 * @param value     Date object or Unix ms timestamp.
 * @param dateStyle Intl dateStyle preset. Default "medium".
 */
export function formatDate(
  value: Date | number,
  dateStyle: DateStyle = "medium",
  opts: DateFormatOptions = {},
): string {
  const locale = opts.locale ?? getLocale();
  const date = typeof value === "number" ? new Date(value) : value;
  return new Intl.DateTimeFormat(locale, {
    dateStyle,
    timeStyle: opts.timeStyle,
  }).format(date);
}

/**
 * Format a Date as both date and time.
 */
export function formatDateTime(
  value: Date | number,
  dateStyle: DateStyle = "medium",
  timeStyle: TimeStyle = "short",
  locale?: string,
): string {
  return formatDate(value, dateStyle, {
    timeStyle,
    ...(locale !== undefined && { locale }),
  });
}

// ── Relative time ─────────────────────────────────────────────────────────────

export type RelativeTimeUnit =
  | "year"
  | "quarter"
  | "month"
  | "week"
  | "day"
  | "hour"
  | "minute"
  | "second";

export interface RelativeTimeOptions {
  locale?: string;
  numeric?: "always" | "auto";
}

/**
 * Format a relative time value (e.g. -2, "day" → "2 days ago").
 * Positive = future ("in 3 days"), negative = past ("3 days ago").
 */
export function formatRelativeTime(
  value: number,
  unit: RelativeTimeUnit,
  opts: RelativeTimeOptions = {},
): string {
  const locale = opts.locale ?? getLocale();
  return new Intl.RelativeTimeFormat(locale, {
    numeric: opts.numeric ?? "auto",
  }).format(value, unit);
}

/**
 * Format a timestamp as "time ago" by computing the best unit automatically.
 * Returns e.g. "3 minutes ago", "yesterday", "2 hours ago".
 */
export function formatTimeAgo(
  value: Date | number,
  opts: RelativeTimeOptions = {},
): string {
  const then = typeof value === "number" ? value : value.getTime();
  const diffMs = then - Date.now();
  const diffSecs = diffMs / 1000;
  const diffMins = diffSecs / 60;
  const diffHours = diffMins / 60;
  const diffDays = diffHours / 24;

  if (Math.abs(diffSecs) < 60) return formatRelativeTime(Math.round(diffSecs), "second", opts);
  if (Math.abs(diffMins) < 60) return formatRelativeTime(Math.round(diffMins), "minute", opts);
  if (Math.abs(diffHours) < 24) return formatRelativeTime(Math.round(diffHours), "hour", opts);
  if (Math.abs(diffDays) < 30) return formatRelativeTime(Math.round(diffDays), "day", opts);
  if (Math.abs(diffDays) < 365) return formatRelativeTime(Math.round(diffDays / 30), "month", opts);
  return formatRelativeTime(Math.round(diffDays / 365), "year", opts);
}
