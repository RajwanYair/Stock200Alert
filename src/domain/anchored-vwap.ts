/**
 * Anchored VWAP: cumulative volume-weighted average price starting at
 * a chosen anchor index/time. Optional standard-deviation bands.
 * Uses typical price (H+L+C)/3 weighted by volume.
 */

import type { Candle } from "./heikin-ashi";

export interface AnchoredVwapPoint {
  readonly time: number;
  readonly vwap: number;
  readonly upper1: number;
  readonly lower1: number;
  readonly upper2: number;
  readonly lower2: number;
}

export interface AnchoredVwapOptions {
  readonly anchorIndex?: number;
  readonly anchorTime?: number;
  readonly bandMultipliers?: readonly [number, number];
}

export function anchoredVwap(
  candles: readonly Candle[],
  options: AnchoredVwapOptions = {},
): AnchoredVwapPoint[] {
  if (candles.length === 0) return [];
  const [m1, m2] = options.bandMultipliers ?? [1, 2];

  let anchor = 0;
  if (options.anchorIndex !== undefined) {
    anchor = Math.max(0, Math.min(candles.length - 1, options.anchorIndex));
  } else if (options.anchorTime !== undefined) {
    anchor = candles.findIndex((c) => c.time >= options.anchorTime!);
    if (anchor < 0) anchor = candles.length - 1;
  }

  const out: AnchoredVwapPoint[] = [];
  let cumPV = 0;
  let cumV = 0;
  let cumPPV = 0; // sum(price^2 * volume) for variance

  for (let i = anchor; i < candles.length; i++) {
    const c = candles[i]!;
    const tp = (c.high + c.low + c.close) / 3;
    const v = Math.max(0, c.volume ?? 0);
    cumPV += tp * v;
    cumV += v;
    cumPPV += tp * tp * v;
    const vwap = cumV > 0 ? cumPV / cumV : tp;
    const variance = cumV > 0 ? Math.max(0, cumPPV / cumV - vwap * vwap) : 0;
    const sd = Math.sqrt(variance);
    out.push({
      time: c.time,
      vwap,
      upper1: vwap + m1 * sd,
      lower1: vwap - m1 * sd,
      upper2: vwap + m2 * sd,
      lower2: vwap - m2 * sd,
    });
  }
  return out;
}
