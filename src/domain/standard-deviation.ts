/**
 * Rolling standard deviation over a window of `period` samples.
 * Defaults to population std-dev (divisor = period). Set
 * `sample: true` for sample std-dev (divisor = period - 1).
 * Uses an O(period) per-step formula (sum and sum-of-squares).
 */

export interface StdDevOptions {
  readonly sample?: boolean;
}

export function computeStdDev(
  values: readonly number[],
  period: number,
  options: StdDevOptions = {},
): (number | null)[] {
  const out: (number | null)[] = new Array(values.length).fill(null);
  if (period <= 0 || values.length < period) return out;
  const sample = options.sample === true;
  const divisor = sample ? period - 1 : period;
  if (divisor <= 0) return out;
  for (let i = period - 1; i < values.length; i++) {
    let sum = 0;
    for (let j = i - period + 1; j <= i; j++) sum += values[j]!;
    const mean = sum / period;
    let sq = 0;
    for (let j = i - period + 1; j <= i; j++) {
      const d = values[j]! - mean;
      sq += d * d;
    }
    out[i] = Math.sqrt(sq / divisor);
  }
  return out;
}
