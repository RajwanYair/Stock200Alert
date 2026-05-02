/**
 * Sector Rotation domain — relative strength ranking (H20).
 *
 * Pure computation layer for sector ETF relative performance analysis.
 * No API calls; operates on pre-fetched candle arrays.
 */

// ─────────────────────────── Catalogue ───────────────────────────────────────

/**
 * The 11 standard SPDR sector ETFs (GICS level 1).
 * Used as the default universe for relative-strength calculations.
 */
export const SECTOR_ETFS = [
  "XLC", // Communication Services
  "XLY", // Consumer Discretionary
  "XLP", // Consumer Staples
  "XLE", // Energy
  "XLF", // Financials
  "XLV", // Health Care
  "XLI", // Industrials
  "XLB", // Materials
  "XLRE", // Real Estate
  "XLK", // Technology
  "XLU", // Utilities
] as const;

export type SectorEtf = (typeof SECTOR_ETFS)[number];

export interface SectorReturnInput {
  /** Sector ETF ticker */
  ticker: string;
  /**
   * Percentage return over the look-back window (decimal, e.g. 0.05 = +5%).
   * Use the output of `computeReturn()` or equivalent.
   */
  periodReturn: number;
}

export interface SectorRankEntry extends SectorReturnInput {
  /** Relative return vs. the benchmark (sectorReturn - benchmarkReturn) */
  relativeReturn: number;
  /** 1-based rank from best (1) to worst */
  rank: number;
  /** Performance classification */
  performance: "outperform" | "underperform" | "flat";
}

// ─────────────────────────── Core functions ──────────────────────────────────

/**
 * Compute the simple price return over the last `days` candles.
 * Returns 0 when insufficient data or start price is zero/non-finite.
 *
 * @param closes  Array of closing prices (oldest first)
 * @param days    Look-back window in trading days
 */
export function computeReturn(closes: readonly number[], days: number): number {
  if (closes.length < days + 1) return 0;
  const end = closes[closes.length - 1]!;
  const start = closes[closes.length - 1 - days]!;
  if (!Number.isFinite(start) || start === 0) return 0;
  return (end - start) / start;
}

/**
 * Compute relative return of a sector vs. a benchmark.
 * `rs = sectorReturn - benchmarkReturn`
 */
export function computeRelativeReturn(sectorReturn: number, benchmarkReturn: number): number {
  return sectorReturn - benchmarkReturn;
}

/**
 * Classify sector performance relative to benchmark.
 *
 * @param relativeReturn  Output of `computeRelativeReturn`
 * @param threshold       Minimum |relative return| to break out of "flat" (default 0.25%)
 */
export function classifySectorPerformance(
  relativeReturn: number,
  threshold = 0.0025,
): "outperform" | "underperform" | "flat" {
  if (relativeReturn > threshold) return "outperform";
  if (relativeReturn < -threshold) return "underperform";
  return "flat";
}

/**
 * Rank a list of sectors by their relative return vs. a benchmark (e.g. SPY).
 *
 * @param sectors         Array of {ticker, periodReturn}
 * @param benchmarkReturn Benchmark period return (default 0 = no benchmark)
 * @param threshold       Flat-zone threshold passed to `classifySectorPerformance`
 * @returns Sorted array of `SectorRankEntry` from best to worst
 */
export function rankSectors(
  sectors: readonly SectorReturnInput[],
  benchmarkReturn = 0,
  threshold = 0.0025,
): SectorRankEntry[] {
  const withRelative = sectors.map((s) => ({
    ...s,
    relativeReturn: computeRelativeReturn(s.periodReturn, benchmarkReturn),
  }));

  const sorted = [...withRelative].sort((a, b) => b.relativeReturn - a.relativeReturn);

  return sorted.map((s, i) => ({
    ...s,
    rank: i + 1,
    performance: classifySectorPerformance(s.relativeReturn, threshold),
  }));
}
