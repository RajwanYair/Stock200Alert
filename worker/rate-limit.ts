/**
 * Simple in-memory rate limiter for the CrossTide API Worker.
 *
 * Uses a sliding-window token bucket per IP (or CF-Connecting-IP header).
 * The worker's per-isolate memory is ephemeral, so this limits bursts within
 * a single isolate lifetime — not across all edge nodes. For a global limit,
 * bind a KV namespace and persist tokens there.
 *
 * Default: 60 requests per minute per IP.
 */

interface Bucket {
  tokens: number;
  lastRefill: number; // ms
}

const DEFAULT_CAPACITY = 60;
const DEFAULT_REFILL_MS = 60_000; // 1 minute

const buckets = new Map<string, Bucket>();

/** Clean stale buckets to prevent unbounded growth in long-lived isolates. */
function evictStale(nowMs: number): void {
  for (const [key, bucket] of buckets) {
    if (nowMs - bucket.lastRefill > DEFAULT_REFILL_MS * 2) {
      buckets.delete(key);
    }
  }
}

/**
 * Check if the caller identified by `key` has remaining capacity.
 * Returns `true` if the request should be allowed, `false` to rate-limit.
 */
export function checkRateLimit(key: string, nowMs = Date.now()): boolean {
  // Evict every ~1000 checks to bound memory usage
  if (buckets.size > 5_000) evictStale(nowMs);

  let bucket = buckets.get(key);
  if (!bucket) {
    bucket = { tokens: DEFAULT_CAPACITY - 1, lastRefill: nowMs };
    buckets.set(key, bucket);
    return true;
  }

  const elapsed = nowMs - bucket.lastRefill;
  if (elapsed >= DEFAULT_REFILL_MS) {
    // Full refill after a complete window
    bucket.tokens = DEFAULT_CAPACITY - 1;
    bucket.lastRefill = nowMs;
    return true;
  }

  if (bucket.tokens > 0) {
    bucket.tokens -= 1;
    return true;
  }

  return false;
}

/** Extract a stable key from a request (CF-Connecting-IP → X-Forwarded-For → "unknown"). */
export function rateLimitKey(request: Request): string {
  return (
    request.headers.get("CF-Connecting-IP") ??
    request.headers.get("X-Forwarded-For")?.split(",")[0]?.trim() ??
    "unknown"
  );
}

/** HTTP 429 response with a Retry-After header. */
export function tooManyRequests(corsHdrs: HeadersInit): Response {
  return new Response(JSON.stringify({ error: "Too many requests" }), {
    status: 429,
    headers: {
      ...corsHdrs,
      "Content-Type": "application/json",
      "Retry-After": "60",
    },
  });
}
