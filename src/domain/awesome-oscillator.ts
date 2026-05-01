/**
 * Awesome Oscillator (Bill Williams):
 *   AO = SMA(median, fast=5) - SMA(median, slow=34)
 * where median = (H + L) / 2.
 * Bar color: green if rising vs prev AO, red if falling.
 */

import type { Candle } from "./heikin-ashi";

export interface AoPoint {
  readonly time: number;
  readonly value: number;
  readonly color: "green" | "red" | "flat";
}

const sma = (vals: readonly number[], end: number, period: number): number => {
  let sum = 0;
  for (let i = end - period + 1; i <= end; i++) sum += vals[i]!;
  return sum / period;
};

export function computeAwesomeOscillator(
  candles: readonly Candle[],
  fast = 5,
  slow = 34,
): AoPoint[] {
  if (fast <= 0 || slow <= 0 || fast >= slow) return [];
  if (candles.length < slow) return [];
  const median = candles.map((c) => (c.high + c.low) / 2);
  const out: AoPoint[] = [];
  let prev: number | null = null;
  for (let i = slow - 1; i < candles.length; i++) {
    const ao = sma(median, i, fast) - sma(median, i, slow);
    let color: AoPoint["color"] = "flat";
    if (prev !== null) {
      if (ao > prev) color = "green";
      else if (ao < prev) color = "red";
    }
    out.push({ time: candles[i]!.time, value: ao, color });
    prev = ao;
  }
  return out;
}
