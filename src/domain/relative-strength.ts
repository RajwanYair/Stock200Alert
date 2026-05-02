/**
 * Relative Strength Comparison domain helpers (H21).
 *
 * Computes per-ticker % return series normalized to a common base date so that
 * multiple tickers can be plotted on a single chart anchored at 0 %.
 * A benchmark ticker (e.g. SPY) is rendered as a reference line.
 *
 * Algorithm:
 *   normalized[i] = (close[i] / close[base] - 1) × 100
 *
 * The "base" index is the first candle whose date >= windowStart.
 */
import type { DailyCandle } from "../types/domain";

/** One normalised data point for a single ticker in the comparison chart. */
export interface RSPoint {
  /** ISO date string (YYYY-MM-DD). */
  readonly date: string;
  /** % return relative to the base date, e.g. 12.5 means +12.5 %. */
  readonly pct: number;
}

/** Normalised return series for one ticker over the chosen window. */
export interface RSeries {
  readonly ticker: string;
  readonly points: RSPoint[];
  /** % return from base to the last available date. */
  readonly totalReturn: number;
  /** True if this is the benchmark (reference) series. */
  readonly isBenchmark: boolean;
}

/** Full result returned by `computeRelativeStrengths`. */
export interface RSComparisonResult {
  readonly series: RSeries[];
  /** ISO date of the common anchor (first shared date on/after windowStart). */
  readonly baseDate: string;
  /** Tickers ranked from highest to lowest total return. */
  readonly ranked: readonly string[];
}

/**
 * Normalise a single candle array to % return vs the base date.
 * Returns an empty array when candles contain no date >= baseDate.
 */
export function normalizeSeries(
  candles: readonly DailyCandle[],
  baseDate: string,
  ticker: string,
  isBenchmark = false,
): RSeries {
  const sorted = [...candles].sort((a, b) => a.date.localeCompare(b.date));
  const baseIdx = sorted.findIndex((c) => c.date >= baseDate);
  if (baseIdx === -1 || !sorted[baseIdx]) {
    return { ticker, points: [], totalReturn: 0, isBenchmark };
  }
  const baseClose = sorted[baseIdx].close;
  if (baseClose === 0) {
    return { ticker, points: [], totalReturn: 0, isBenchmark };
  }
  const points: RSPoint[] = sorted
    .slice(baseIdx)
    .map((c) => ({ date: c.date, pct: ((c.close - baseClose) / baseClose) * 100 }));

  const last = points[points.length - 1];
  const totalReturn = last?.pct ?? 0;
  return { ticker, points, totalReturn, isBenchmark };
}

/**
 * Compute a common window start date from a lookback string.
 *
 * Supported values: "1W", "1M", "3M", "6M", "1Y", "YTD".
 * All arithmetic is calendar-day arithmetic; trading-day alignment
 * is handled by `normalizeSeries` choosing the first candle on/after the date.
 *
 * @param window  Lookback window identifier.
 * @param now     Reference date (defaults to today).
 */
export function windowStartDate(window: string, now = new Date()): string {
  const d = new Date(now);
  switch (window.toUpperCase()) {
    case "1W":
      d.setDate(d.getDate() - 7);
      break;
    case "1M":
      d.setMonth(d.getMonth() - 1);
      break;
    case "3M":
      d.setMonth(d.getMonth() - 3);
      break;
    case "6M":
      d.setMonth(d.getMonth() - 6);
      break;
    case "1Y":
      d.setFullYear(d.getFullYear() - 1);
      break;
    case "YTD":
      d.setMonth(0, 1);
      break;
    default:
      d.setMonth(d.getMonth() - 1); // fallback 1M
  }
  return d.toISOString().slice(0, 10);
}

export interface RSInput {
  ticker: string;
  candles: readonly DailyCandle[];
  isBenchmark?: boolean;
}

/**
 * Compute relative strength comparison for multiple tickers.
 *
 * @param inputs    Ticker series + benchmark flag.
 * @param baseDate  ISO date to anchor all series at 0 %.
 */
export function computeRelativeStrengths(
  inputs: readonly RSInput[],
  baseDate: string,
): RSComparisonResult {
  if (inputs.length === 0) {
    return { series: [], baseDate, ranked: [] };
  }

  const series = inputs.map((inp) =>
    normalizeSeries(inp.candles, baseDate, inp.ticker, inp.isBenchmark ?? false),
  );

  const ranked = [...series]
    .filter((s) => !s.isBenchmark)
    .sort((a, b) => b.totalReturn - a.totalReturn)
    .map((s) => s.ticker);

  return { series, baseDate, ranked };
}

/**
 * Return the ticker with the highest total return (excludes benchmark).
 * Returns `null` when no non-benchmark series have data.
 */
export function findOutperformer(result: RSComparisonResult): string | null {
  return result.ranked[0] ?? null;
}

/**
 * Return the ticker with the lowest total return (excludes benchmark).
 */
export function findUnderperformer(result: RSComparisonResult): string | null {
  return result.ranked[result.ranked.length - 1] ?? null;
}

/**
 * Extract only the most recent `pct` per ticker as a flat summary map.
 * Useful for sorting the legend by current return.
 */
export function summariseReturns(result: RSComparisonResult): Record<string, number> {
  const out: Record<string, number> = {};
  for (const s of result.series) {
    out[s.ticker] = s.totalReturn;
  }
  return out;
}
