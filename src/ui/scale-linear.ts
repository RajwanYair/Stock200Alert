/**
 * d3-style linear scale: maps a numeric `domain` to a numeric `range`,
 * with `invert`, `clamp`, and `ticks` helpers.
 */

export interface LinearScale {
  (value: number): number;
  invert(value: number): number;
  domain(): readonly [number, number];
  range(): readonly [number, number];
  ticks(count?: number): number[];
}

export interface LinearScaleOptions {
  readonly clamp?: boolean;
}

export function createLinearScale(
  domain: readonly [number, number],
  range: readonly [number, number],
  options: LinearScaleOptions = {},
): LinearScale {
  const [d0, d1] = domain;
  const [r0, r1] = range;
  const dSpan = d1 - d0;
  const rSpan = r1 - r0;
  const clamp = options.clamp ?? false;

  const scale = ((value: number): number => {
    if (dSpan === 0) return r0;
    let t = (value - d0) / dSpan;
    if (clamp) t = Math.max(0, Math.min(1, t));
    return r0 + t * rSpan;
  }) as LinearScale;

  scale.invert = (value: number): number => {
    if (rSpan === 0) return d0;
    let t = (value - r0) / rSpan;
    if (clamp) t = Math.max(0, Math.min(1, t));
    return d0 + t * dSpan;
  };
  scale.domain = (): readonly [number, number] => [d0, d1] as const;
  scale.range = (): readonly [number, number] => [r0, r1] as const;
  scale.ticks = (count = 10): number[] => niceTicks(d0, d1, count);

  return scale;
}

/**
 * Produce ~`count` "nice" ticks covering [start, stop] using the
 * d3 algorithm (1, 2, 5, 10 step bases).
 */
export function niceTicks(start: number, stop: number, count = 10): number[] {
  if (count <= 0) return [];
  if (start === stop) return [start];
  const reverse = stop < start;
  const lo = reverse ? stop : start;
  const hi = reverse ? start : stop;
  const step = tickStep(lo, hi, count);
  if (!Number.isFinite(step) || step <= 0) return [];
  const i0 = Math.ceil(lo / step);
  const i1 = Math.floor(hi / step);
  const ticks: number[] = [];
  for (let i = i0; i <= i1; i++) ticks.push(i * step);
  return reverse ? ticks.reverse() : ticks;
}

function tickStep(start: number, stop: number, count: number): number {
  const step0 = Math.abs(stop - start) / Math.max(0, count);
  const step1 = Math.pow(10, Math.floor(Math.log10(step0)));
  const error = step0 / step1;
  if (error >= 7.07) return step1 * 10;
  if (error >= 3.16) return step1 * 5;
  if (error >= 1.41) return step1 * 2;
  return step1;
}
