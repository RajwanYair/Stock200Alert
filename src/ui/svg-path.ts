/**
 * SVG path builders. Pure: input numeric points, output `d` attribute strings.
 * No DOM dependency. Coordinates rounded to `precision` decimals (default 2)
 * to keep paths small.
 */

export interface Point {
  readonly x: number;
  readonly y: number;
}

export interface SvgPathOptions {
  readonly precision?: number;
}

const fmt = (n: number, p: number): string => {
  if (!Number.isFinite(n)) return "0";
  const s = n.toFixed(p);
  // strip trailing zeros and decimal point
  return s.includes(".") ? s.replace(/\.?0+$/, "") : s;
};

/** Polyline path: `M x0 y0 L x1 y1 L ...`. Returns "" for <2 points. */
export function buildLinePath(points: readonly Point[], opts: SvgPathOptions = {}): string {
  const p = opts.precision ?? 2;
  if (points.length < 2) return "";
  const parts: string[] = [];
  for (let i = 0; i < points.length; i++) {
    const pt = points[i]!;
    parts.push(`${i === 0 ? "M" : "L"}${fmt(pt.x, p)} ${fmt(pt.y, p)}`);
  }
  return parts.join(" ");
}

/** Filled area path between line and a baseline y. */
export function buildAreaPath(
  points: readonly Point[],
  baselineY: number,
  opts: SvgPathOptions = {},
): string {
  const p = opts.precision ?? 2;
  if (points.length < 2) return "";
  const parts: string[] = [`M${fmt(points[0]!.x, p)} ${fmt(baselineY, p)}`];
  for (const pt of points) parts.push(`L${fmt(pt.x, p)} ${fmt(pt.y, p)}`);
  parts.push(`L${fmt(points[points.length - 1]!.x, p)} ${fmt(baselineY, p)}`);
  parts.push("Z");
  return parts.join(" ");
}

/** Catmull-Rom -> cubic Bézier smoothed line. `tension` ∈ [0, 1], default 0.5. */
export function buildSmoothLinePath(
  points: readonly Point[],
  opts: SvgPathOptions & { readonly tension?: number } = {},
): string {
  const p = opts.precision ?? 2;
  const t = Math.max(0, Math.min(1, opts.tension ?? 0.5));
  if (points.length < 2) return "";
  if (points.length === 2) return buildLinePath(points, opts);

  const parts: string[] = [`M${fmt(points[0]!.x, p)} ${fmt(points[0]!.y, p)}`];
  for (let i = 0; i < points.length - 1; i++) {
    const p0 = points[i - 1] ?? points[i]!;
    const p1 = points[i]!;
    const p2 = points[i + 1]!;
    const p3 = points[i + 2] ?? p2;
    const c1x = p1.x + ((p2.x - p0.x) / 6) * t * 2;
    const c1y = p1.y + ((p2.y - p0.y) / 6) * t * 2;
    const c2x = p2.x - ((p3.x - p1.x) / 6) * t * 2;
    const c2y = p2.y - ((p3.y - p1.y) / 6) * t * 2;
    parts.push(
      `C${fmt(c1x, p)} ${fmt(c1y, p)} ${fmt(c2x, p)} ${fmt(c2y, p)} ${fmt(p2.x, p)} ${fmt(p2.y, p)}`,
    );
  }
  return parts.join(" ");
}
