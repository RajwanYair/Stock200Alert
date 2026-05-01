import { describe, it, expect, vi } from "vitest";
import { nextDelay, retry } from "../../../src/core/retry-backoff";

describe("retry-backoff", () => {
  it("nextDelay no-jitter doubles", () => {
    expect(nextDelay(0, { baseMs: 100, jitter: "none" })).toBe(100);
    expect(nextDelay(1, { baseMs: 100, jitter: "none" })).toBe(200);
    expect(nextDelay(2, { baseMs: 100, jitter: "none" })).toBe(400);
  });

  it("nextDelay capped at maxMs", () => {
    expect(nextDelay(20, { baseMs: 100, maxMs: 1000, jitter: "none" })).toBe(1000);
  });

  it("full jitter is in [0, raw]", () => {
    const d = nextDelay(2, { baseMs: 100, jitter: "full", random: () => 0.5 });
    expect(d).toBe(200); // 0.5 * 400
  });

  it("equal jitter is in [raw/2, raw]", () => {
    const d = nextDelay(2, { baseMs: 100, jitter: "equal", random: () => 0 });
    expect(d).toBe(200); // raw/2 + 0
  });

  it("retry resolves on first success", async () => {
    const fn = vi.fn().mockResolvedValue(42);
    const out = await retry(fn);
    expect(out).toBe(42);
    expect(fn).toHaveBeenCalledTimes(1);
  });

  it("retry retries until success", async () => {
    let calls = 0;
    const out = await retry(
      async () => {
        calls++;
        if (calls < 3) throw new Error("fail");
        return "ok";
      },
      { sleep: async (): Promise<void> => undefined, jitter: "none" },
    );
    expect(out).toBe("ok");
    expect(calls).toBe(3);
  });

  it("retry throws after maxAttempts", async () => {
    await expect(
      retry(async () => Promise.reject(new Error("nope")), {
        maxAttempts: 2,
        sleep: async (): Promise<void> => undefined,
      }),
    ).rejects.toThrow("nope");
  });

  it("retry stops when shouldRetry returns false", async () => {
    const fn = vi.fn().mockRejectedValue(new Error("perm"));
    await expect(
      retry(fn, {
        shouldRetry: (): boolean => false,
        sleep: async (): Promise<void> => undefined,
      }),
    ).rejects.toThrow("perm");
    expect(fn).toHaveBeenCalledTimes(1);
  });

  it("retry passes attempt index to fn", async () => {
    const seen: number[] = [];
    await retry(
      async (n) => {
        seen.push(n);
        if (n < 2) throw new Error("x");
      },
      { sleep: async (): Promise<void> => undefined },
    );
    expect(seen).toEqual([0, 1, 2]);
  });
});
