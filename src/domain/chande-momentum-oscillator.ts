/**
 * Chande Momentum Oscillator (Tushar Chande, 1994).
 *   diff[i]   = close[i] - close[i-1]
 *   sumUp     = sum of positive diffs over period
 *   sumDown   = sum of |negative diffs| over period
 *   CMO       = 100 * (sumUp - sumDown) / (sumUp + sumDown), in [-100, 100]
 * Returns null where there isn't enough history.
 */

export function computeCmo(closes: readonly number[], period = 9): (number | null)[] {
  const out: (number | null)[] = new Array(closes.length).fill(null);
  if (period <= 0 || closes.length <= period) return out;

  const diffs: number[] = new Array(closes.length).fill(0);
  for (let i = 1; i < closes.length; i++) diffs[i] = closes[i]! - closes[i - 1]!;

  let up = 0;
  let down = 0;
  // Seed first window: diffs[1..period]
  for (let i = 1; i <= period; i++) {
    const d = diffs[i]!;
    if (d > 0) up += d;
    else down += -d;
  }
  const denom0 = up + down;
  out[period] = denom0 === 0 ? 0 : (100 * (up - down)) / denom0;

  for (let i = period + 1; i < closes.length; i++) {
    const inD = diffs[i]!;
    const outD = diffs[i - period]!;
    if (inD > 0) up += inD;
    else down += -inD;
    if (outD > 0) up -= outD;
    else down -= -outD;
    const denom = up + down;
    out[i] = denom === 0 ? 0 : (100 * (up - down)) / denom;
  }
  return out;
}
