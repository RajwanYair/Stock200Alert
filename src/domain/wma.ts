/**
 * Weighted Moving Average. Linearly weighted: most recent bar has the
 * largest weight `period`, oldest bar has weight 1. Sum of weights =
 * period*(period+1)/2.
 *   WMA[i] = sum(close[i-period+1..i] * (1..period)) / (period*(period+1)/2)
 */

export function computeWma(values: readonly number[], period: number): (number | null)[] {
  const out: (number | null)[] = new Array(values.length).fill(null);
  if (period <= 0 || values.length < period) return out;
  const denom = (period * (period + 1)) / 2;
  for (let i = period - 1; i < values.length; i++) {
    let sum = 0;
    for (let k = 0; k < period; k++) {
      // Oldest at offset (period-1-k) gets weight 1; newest at offset 0 gets weight `period`.
      const v = values[i - (period - 1 - k)]!;
      sum += v * (k + 1);
    }
    out[i] = sum / denom;
  }
  return out;
}
