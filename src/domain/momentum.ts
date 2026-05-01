/**
 * Momentum oscillator. Simple price difference over `period` bars:
 *   momentum[i] = close[i] - close[i - period]
 * Returns nulls until enough history exists. Output length matches input.
 */

export function computeMomentum(values: readonly number[], period = 10): (number | null)[] {
  const out: (number | null)[] = new Array(values.length).fill(null);
  if (period <= 0) return out;
  for (let i = period; i < values.length; i++) {
    out[i] = values[i]! - values[i - period]!;
  }
  return out;
}
