/**
 * Exponential backoff with optional jitter (full or equal). Pure
 * computation: `nextDelay(attempt)` returns the wait in ms; `retry`
 * is a runner that awaits an async fn with the policy applied.
 *
 * delay(n) = min(maxMs, baseMs * factor^n)
 *   full jitter: random in [0, delay]
 *   equal jitter: delay/2 + random in [0, delay/2]
 */

export type Jitter = "none" | "full" | "equal";

export interface BackoffPolicy {
  readonly baseMs?: number;
  readonly maxMs?: number;
  readonly factor?: number;
  readonly jitter?: Jitter;
  readonly maxAttempts?: number;
  readonly random?: () => number;
}

export function nextDelay(attempt: number, policy: BackoffPolicy = {}): number {
  const base = policy.baseMs ?? 200;
  const max = policy.maxMs ?? 30_000;
  const factor = policy.factor ?? 2;
  const jitter = policy.jitter ?? "full";
  const rng = policy.random ?? Math.random;
  const raw = Math.min(max, base * Math.pow(factor, Math.max(0, attempt)));
  if (jitter === "none") return Math.round(raw);
  if (jitter === "equal") return Math.round(raw / 2 + rng() * (raw / 2));
  return Math.round(rng() * raw);
}

export interface RetryOptions extends BackoffPolicy {
  readonly shouldRetry?: (error: unknown, attempt: number) => boolean;
  readonly sleep?: (ms: number) => Promise<void>;
}

const defaultSleep = (ms: number): Promise<void> =>
  new Promise<void>((resolve) => {
    setTimeout(resolve, ms);
  });

export async function retry<T>(
  fn: (attempt: number) => Promise<T>,
  options: RetryOptions = {},
): Promise<T> {
  const max = options.maxAttempts ?? 5;
  const sleep = options.sleep ?? defaultSleep;
  const shouldRetry = options.shouldRetry ?? ((): boolean => true);
  let lastError: unknown;
  for (let attempt = 0; attempt < max; attempt++) {
    try {
      return await fn(attempt);
    } catch (err) {
      lastError = err;
      if (attempt === max - 1 || !shouldRetry(err, attempt)) throw err;
      await sleep(nextDelay(attempt, options));
    }
  }
  throw lastError;
}
