/**
 * Simple in-memory rate limiter for Cloudflare Worker.
 * Limits: 60 requests per minute per IP.
 * Resets every 60 seconds.
 */
interface RateLimitEntry {
  count: number;
  resetAt: number;
}

const store = new Map<string, RateLimitEntry>();
const LIMIT = 60;
const WINDOW_MS = 60_000;

export function checkRateLimit(ip: string): Response | null {
  const now = Date.now();
  const entry = store.get(ip);

  if (!entry || now >= entry.resetAt) {
    store.set(ip, { count: 1, resetAt: now + WINDOW_MS });
    return null;
  }

  if (entry.count >= LIMIT) {
    return new Response(
      JSON.stringify({
        error: "Rate limit exceeded",
        retryAfter: Math.ceil((entry.resetAt - now) / 1000),
      }),
      {
        status: 429,
        headers: {
          "Content-Type": "application/json",
          "Retry-After": String(Math.ceil((entry.resetAt - now) / 1000)),
          "X-RateLimit-Limit": String(LIMIT),
          "X-RateLimit-Remaining": "0",
          "X-RateLimit-Reset": String(Math.ceil(entry.resetAt / 1000)),
        },
      },
    );
  }

  entry.count++;
  return null;
}

/** For testing: reset the rate limit store. */
export function resetRateLimitStore(): void {
  store.clear();
}
