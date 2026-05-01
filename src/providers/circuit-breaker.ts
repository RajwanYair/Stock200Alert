/**
 * CircuitBreaker — closed/open/half-open state machine for failing providers.
 *
 * States:
 *   - closed:    normal operation; failures counted.
 *   - open:      requests rejected immediately for `cooldownMs`.
 *   - half-open: one probe allowed; success → closed, failure → open.
 */

export type CircuitState = "closed" | "open" | "half-open";

export interface CircuitBreakerOptions {
  /** Consecutive failure threshold before tripping open. */
  readonly failureThreshold: number;
  /** Time in ms to remain open before allowing a probe. */
  readonly cooldownMs: number;
  /** Successful probes required (half-open) before closing. */
  readonly successThreshold?: number;
  /** Time source — injectable for tests. */
  readonly now?: () => number;
}

export interface CircuitBreakerSnapshot {
  readonly state: CircuitState;
  readonly failures: number;
  readonly successes: number;
  readonly openedAt: number | null;
}

export class CircuitOpenError extends Error {
  constructor(public readonly provider: string) {
    super(`circuit open for ${provider}`);
    this.name = "CircuitOpenError";
  }
}

export class CircuitBreaker {
  private state: CircuitState = "closed";
  private failures = 0;
  private successes = 0;
  private openedAt: number | null = null;
  private readonly opts: Required<CircuitBreakerOptions>;

  constructor(
    public readonly name: string,
    options: CircuitBreakerOptions,
  ) {
    if (options.failureThreshold < 1) {
      throw new Error("failureThreshold must be >= 1");
    }
    if (options.cooldownMs < 0) throw new Error("cooldownMs must be >= 0");
    this.opts = {
      failureThreshold: options.failureThreshold,
      cooldownMs: options.cooldownMs,
      successThreshold: options.successThreshold ?? 1,
      now: options.now ?? ((): number => Date.now()),
    };
  }

  snapshot(): CircuitBreakerSnapshot {
    return {
      state: this.state,
      failures: this.failures,
      successes: this.successes,
      openedAt: this.openedAt,
    };
  }

  /** Attempt to acquire a slot to run an operation. */
  canRequest(): boolean {
    if (this.state === "closed") return true;
    if (this.state === "half-open") return true;
    // open
    if (this.openedAt === null) return false;
    if (this.opts.now() - this.openedAt >= this.opts.cooldownMs) {
      this.state = "half-open";
      this.successes = 0;
      return true;
    }
    return false;
  }

  /** Record a successful operation. */
  onSuccess(): void {
    if (this.state === "half-open") {
      this.successes++;
      if (this.successes >= this.opts.successThreshold) {
        this.state = "closed";
        this.failures = 0;
        this.successes = 0;
        this.openedAt = null;
      }
      return;
    }
    this.failures = 0;
  }

  /** Record a failed operation. */
  onFailure(): void {
    if (this.state === "half-open") {
      this.trip();
      return;
    }
    this.failures++;
    if (this.failures >= this.opts.failureThreshold) {
      this.trip();
    }
  }

  /** Wrap an async operation; throws CircuitOpenError when open. */
  async run<T>(op: () => Promise<T>): Promise<T> {
    if (!this.canRequest()) throw new CircuitOpenError(this.name);
    try {
      const result = await op();
      this.onSuccess();
      return result;
    } catch (err) {
      this.onFailure();
      throw err;
    }
  }

  /** Force-reset to closed. */
  reset(): void {
    this.state = "closed";
    this.failures = 0;
    this.successes = 0;
    this.openedAt = null;
  }

  private trip(): void {
    this.state = "open";
    this.openedAt = this.opts.now();
    this.successes = 0;
  }
}
