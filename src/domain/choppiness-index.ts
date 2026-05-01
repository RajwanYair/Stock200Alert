/**
 * Choppiness Index. E.W. Dreiss's measure of whether the market is
 * trending (low values) or choppy/ranging (high values). Scaled 0–100;
 * values > ~61.8 typically indicate consolidation, < ~38.2 indicate trend.
 *
 *   TRn   = sum of true range over n bars
 *   range = max(high, n) - min(low, n)
 *   CI    = 100 * log10(TRn / range) / log10(n)
 */

import type { Candle } from "./heikin-ashi";

export function computeChoppinessIndex(
  candles: readonly Candle[],
  period = 14,
): Array<number | null> {
  const n = candles.length;
  const out: Array<number | null> = new Array(n).fill(null);
  if (n === 0 || period < 1) return out;

  const tr: number[] = new Array(n).fill(0);
  for (let i = 0; i < n; i++) {
    const c = candles[i]!;
    if (i === 0) {
      tr[i] = c.high - c.low;
    } else {
      const prev = candles[i - 1]!.close;
      tr[i] = Math.max(c.high - c.low, Math.abs(c.high - prev), Math.abs(c.low - prev));
    }
  }

  const denom = Math.log10(period);
  for (let i = period - 1; i < n; i++) {
    let trSum = 0;
    let hi = -Infinity;
    let lo = Infinity;
    for (let k = i - period + 1; k <= i; k++) {
      trSum += tr[k]!;
      const c = candles[k]!;
      if (c.high > hi) hi = c.high;
      if (c.low < lo) lo = c.low;
    }
    const range = hi - lo;
    if (range <= 0 || trSum <= 0) {
      out[i] = null;
      continue;
    }
    out[i] = (100 * Math.log10(trSum / range)) / denom;
  }
  return out;
}
