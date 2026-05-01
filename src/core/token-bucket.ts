/**
 * Token-bucket rate limiter. Tokens refill continuously at `ratePerSec`
 * up to `capacity`. Each request consumes one (or `cost`) tokens.
 * Pure: no timers; caller passes `now` for testability.
 */

export interface TokenBucketConfig {
  readonly capacity: number;
  readonly ratePerSec: number;
  readonly initialTokens?: number;
}

export interface TokenBucket {
  readonly tryConsume: (cost?: number, now?: number) => boolean;
  /** Ms until `cost` tokens become available. 0 if available now. */
  readonly waitMs: (cost?: number, now?: number) => number;
  readonly tokens: (now?: number) => number;
  readonly snapshot: () => { tokens: number; lastRefill: number };
}

export function createTokenBucket(config: TokenBucketConfig): TokenBucket {
  if (config.capacity <= 0) throw new Error("capacity must be > 0");
  if (config.ratePerSec <= 0) throw new Error("ratePerSec must be > 0");
  let tokens = Math.min(config.initialTokens ?? config.capacity, config.capacity);
  let lastRefill = -1;

  const refill = (now: number): void => {
    if (lastRefill < 0) {
      lastRefill = now;
      return;
    }
    const elapsedSec = (now - lastRefill) / 1000;
    if (elapsedSec <= 0) return;
    tokens = Math.min(config.capacity, tokens + elapsedSec * config.ratePerSec);
    lastRefill = now;
  };

  return {
    tryConsume: (cost = 1, now = Date.now()): boolean => {
      refill(now);
      if (tokens >= cost) {
        tokens -= cost;
        return true;
      }
      return false;
    },
    waitMs: (cost = 1, now = Date.now()): number => {
      refill(now);
      if (tokens >= cost) return 0;
      return Math.ceil(((cost - tokens) / config.ratePerSec) * 1000);
    },
    tokens: (now = Date.now()): number => {
      refill(now);
      return tokens;
    },
    snapshot: (): { tokens: number; lastRefill: number } => ({
      tokens,
      lastRefill,
    }),
  };
}
