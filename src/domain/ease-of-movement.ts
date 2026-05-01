/**
 * Richard Arms' Ease of Movement (EOM, EMV). Highlights how easily price
 * moves on a given volume. Positive when price rises with low volume;
 * negative when it falls. Typically smoothed by an SMA.
 *
 *   distance = (high + low)/2 - (prevHigh + prevLow)/2
 *   boxRatio = (volume / scale) / (high - low)
 *   EMV1     = distance / boxRatio
 *   EMV      = SMA(EMV1, period)
 */

import type { VolumeCandle } from "./klinger-oscillator";

export interface EaseOfMovementOptions {
  readonly period?: number;
  readonly scale?: number;
}

export function computeEaseOfMovement(
  candles: readonly VolumeCandle[],
  opts: EaseOfMovementOptions = {},
): Array<number | null> {
  const period = opts.period ?? 14;
  const scale = opts.scale ?? 1_000_000;
  const n = candles.length;
  const out: Array<number | null> = new Array(n).fill(null);
  if (n < 2) return out;

  const raw: Array<number | null> = new Array(n).fill(null);
  for (let i = 1; i < n; i++) {
    const c = candles[i]!;
    const prev = candles[i - 1]!;
    const distance = (c.high + c.low) / 2 - (prev.high + prev.low) / 2;
    const range = c.high - c.low;
    if (range <= 0 || c.volume <= 0) {
      raw[i] = 0;
      continue;
    }
    const boxRatio = c.volume / scale / range;
    raw[i] = distance / boxRatio;
  }

  for (let i = period; i < n; i++) {
    let sum = 0;
    let count = 0;
    for (let k = i - period + 1; k <= i; k++) {
      const v = raw[k] ?? null;
      if (v !== null) {
        sum += v;
        count++;
      }
    }
    if (count === period) out[i] = sum / period;
  }
  return out;
}
