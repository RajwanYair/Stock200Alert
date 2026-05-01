/**
 * Array partitioning utilities.
 *  - chunk: split into consecutive non-overlapping subarrays of `size`.
 *           Final chunk may be shorter unless `padWith` is provided.
 *  - window: sliding window of `size` (overlapping). Step defaults to 1.
 *  - zip: combine N arrays element-wise; result length = min(...lengths).
 */

export function chunk<T>(arr: readonly T[], size: number, padWith?: T): T[][] {
  if (size <= 0) return [];
  const out: T[][] = [];
  for (let i = 0; i < arr.length; i += size) {
    const slice = arr.slice(i, i + size);
    if (slice.length < size && padWith !== undefined) {
      while (slice.length < size) slice.push(padWith);
    }
    out.push(slice);
  }
  return out;
}

export function window<T>(arr: readonly T[], size: number, step = 1): T[][] {
  if (size <= 0 || step <= 0 || arr.length < size) return [];
  const out: T[][] = [];
  for (let i = 0; i + size <= arr.length; i += step) {
    out.push(arr.slice(i, i + size));
  }
  return out;
}

export function zip<T>(...arrays: readonly (readonly T[])[]): T[][] {
  if (arrays.length === 0) return [];
  let minLen = Infinity;
  for (const a of arrays) if (a.length < minLen) minLen = a.length;
  if (!Number.isFinite(minLen)) return [];
  const out: T[][] = [];
  for (let i = 0; i < minLen; i++) {
    const tuple: T[] = [];
    for (const a of arrays) tuple.push(a[i]!);
    out.push(tuple);
  }
  return out;
}
