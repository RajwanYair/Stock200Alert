/**
 * SVG sparkline — inline mini chart for watchlist rows.
 *
 * Pure function: takes closes, returns an SVG string.
 * Memoized by data content hash to avoid redundant SVG rebuilds (K13).
 */

export interface SparklineOptions {
  readonly width?: number;
  readonly height?: number;
  readonly strokeColor?: string;
  readonly strokeWidth?: number;
  readonly fillColor?: string;
}

const DEFAULTS = {
  width: 80,
  height: 24,
  strokeColor: "currentColor",
  strokeWidth: 1.5,
  fillColor: "none",
};

// ── Memoization cache (K13) ──────────────────────────────────────────────────
const CACHE_MAX = 128;
const cache = new Map<string, string>();

/** Build a cache key from closes array + options. */
function cacheKey(closes: readonly number[], opts: SparklineOptions): string {
  // Use a compact serialization: length + first/last/sum to detect changes cheaply
  // then fallback to full JSON when ambiguous. For small arrays (typically ≤60 data points)
  // the join is fast enough and collision-free.
  return `${closes.length}:${closes.join(",")}|${opts.width ?? ""}:${opts.height ?? ""}:${opts.strokeColor ?? ""}`;
}

/**
 * Render a sparkline SVG string from an array of close prices.
 * Returns empty string for fewer than 2 data points.
 * Results are memoized (LRU, max 128 entries).
 */
export function renderSparkline(closes: readonly number[], opts: SparklineOptions = {}): string {
  if (closes.length < 2) return "";

  const key = cacheKey(closes, opts);
  const cached = cache.get(key);
  if (cached !== undefined) {
    // Move to end for LRU behavior
    cache.delete(key);
    cache.set(key, cached);
    return cached;
  }

  const svg = buildSparklineSvg(closes, opts);

  // Evict oldest entry if at capacity
  if (cache.size >= CACHE_MAX) {
    const oldest = cache.keys().next().value;
    if (oldest !== undefined) cache.delete(oldest);
  }
  cache.set(key, svg);
  return svg;
}

/** Clear the sparkline memoization cache (for testing). */
export function clearSparklineCache(): void {
  cache.clear();
}

/** @internal Build the SVG string (pure computation, no cache). */
function buildSparklineSvg(closes: readonly number[], opts: SparklineOptions): string {
  const w = opts.width ?? DEFAULTS.width;
  const h = opts.height ?? DEFAULTS.height;
  const stroke = opts.strokeColor ?? DEFAULTS.strokeColor;
  const sw = opts.strokeWidth ?? DEFAULTS.strokeWidth;
  const fill = opts.fillColor ?? DEFAULTS.fillColor;

  const min = Math.min(...closes);
  const max = Math.max(...closes);
  const range = max - min || 1; // avoid division by zero for flat data
  const pad = sw; // padding for stroke width

  const points = closes
    .map((v, i) => {
      const x = (i / (closes.length - 1)) * (w - 2 * pad) + pad;
      const y = h - pad - ((v - min) / range) * (h - 2 * pad);
      return `${x.toFixed(1)},${y.toFixed(1)}`;
    })
    .join(" ");

  return `<svg width="${w}" height="${h}" viewBox="0 0 ${w} ${h}" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Price sparkline"><polyline points="${points}" fill="${fill}" stroke="${stroke}" stroke-width="${sw}" stroke-linecap="round" stroke-linejoin="round"/></svg>`;
}
