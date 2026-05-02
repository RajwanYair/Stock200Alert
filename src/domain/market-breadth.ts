/**
 * Market Breadth domain — pure computation layer (G23).
 *
 * Aggregates signal-level data from across a watchlist to produce
 * breadth indicators: advance/decline ratio, % above key moving averages,
 * and directional signal distribution.  No API calls; works on pre-fetched
 * consensus + quote data.
 */
import type { SignalDirection } from "../types/domain";

// ─────────────────────────── Types ──────────────────────────────────────────

export interface BreadthTicker {
  /** Ticker symbol */
  ticker: string;
  /** Today's closing price */
  price: number;
  /** Day change % (e.g. 1.5 means +1.5%). */
  changePercent: number;
  /** Consensus signal direction */
  consensus: SignalDirection;
  /** Whether price is above 50-day SMA (null = not available) */
  aboveSma50: boolean | null;
  /** Whether price is above 200-day SMA (null = not available) */
  aboveSma200: boolean | null;
}

export interface BreadthResult {
  /** Total number of tickers in the watchlist */
  total: number;
  /** Number with BUY consensus */
  buyCount: number;
  /** Number with SELL consensus */
  sellCount: number;
  /** Number with NEUTRAL consensus */
  neutralCount: number;
  /** Fraction [0,1] with BUY direction; 0 when total=0 */
  buyPct: number;
  /** Fraction [0,1] with SELL direction; 0 when total=0 */
  sellPct: number;
  /** Tickers with price > 50-day SMA as fraction [0,1]; null when no SMA data */
  aboveSma50Pct: number | null;
  /** Tickers with price > 200-day SMA as fraction [0,1]; null when no SMA data */
  aboveSma200Pct: number | null;
  /** Number of advancing tickers (changePercent > threshold) */
  advancers: number;
  /** Number of declining tickers (changePercent < -threshold) */
  decliners: number;
  /** Unchanged tickers (within threshold) */
  unchanged: number;
  /** Advance/Decline ratio; null when decliners=0 */
  adRatio: number | null;
  /** Up to `topN` best-performing tickers sorted by changePercent desc */
  topMovers: readonly BreadthTicker[];
  /** Up to `topN` worst-performing tickers sorted by changePercent asc */
  topLaggards: readonly BreadthTicker[];
}

// ─────────────────────────── Core function ───────────────────────────────────

/**
 * Compute breadth statistics from a watchlist snapshot.
 *
 * @param tickers   Snapshot of each ticker's quote + consensus
 * @param options   Optional overrides
 * @param options.changeThreshold  Min |changePercent| to count as mover (default 0.05)
 * @param options.topN             How many movers/laggards to return (default 3)
 */
export function computeMarketBreadth(
  tickers: readonly BreadthTicker[],
  options: { changeThreshold?: number; topN?: number } = {},
): BreadthResult {
  const { changeThreshold = 0.05, topN = 3 } = options;

  const total = tickers.length;
  let buyCount = 0;
  let sellCount = 0;
  let neutralCount = 0;
  let advancers = 0;
  let decliners = 0;
  let unchanged = 0;
  let sma50Eligible = 0;
  let sma50Above = 0;
  let sma200Eligible = 0;
  let sma200Above = 0;

  for (const t of tickers) {
    if (t.consensus === "BUY") buyCount++;
    else if (t.consensus === "SELL") sellCount++;
    else neutralCount++;

    if (t.changePercent > changeThreshold) advancers++;
    else if (t.changePercent < -changeThreshold) decliners++;
    else unchanged++;

    if (t.aboveSma50 !== null) {
      sma50Eligible++;
      if (t.aboveSma50) sma50Above++;
    }
    if (t.aboveSma200 !== null) {
      sma200Eligible++;
      if (t.aboveSma200) sma200Above++;
    }
  }

  const sorted = [...tickers].sort((a, b) => b.changePercent - a.changePercent);

  return {
    total,
    buyCount,
    sellCount,
    neutralCount,
    buyPct: total > 0 ? buyCount / total : 0,
    sellPct: total > 0 ? sellCount / total : 0,
    aboveSma50Pct: sma50Eligible > 0 ? sma50Above / sma50Eligible : null,
    aboveSma200Pct: sma200Eligible > 0 ? sma200Above / sma200Eligible : null,
    advancers,
    decliners,
    unchanged,
    adRatio: decliners > 0 ? advancers / decliners : null,
    topMovers: sorted.slice(0, topN),
    topLaggards: sorted.slice(-topN).reverse(),
  };
}

/**
 * Classify the overall breadth condition based on computed stats.
 *
 * Returns:
 *   "bullish"   — buyPct > 0.6 and aboveSma50Pct > 0.6
 *   "bearish"   — sellPct > 0.6 and aboveSma50Pct < 0.4
 *   "neutral"   — otherwise
 */
export function classifyBreadthCondition(result: BreadthResult): "bullish" | "bearish" | "neutral" {
  const sma50 = result.aboveSma50Pct ?? 0.5;
  if (result.buyPct > 0.6 && sma50 > 0.6) return "bullish";
  if (result.sellPct > 0.6 && sma50 < 0.4) return "bearish";
  return "neutral";
}
