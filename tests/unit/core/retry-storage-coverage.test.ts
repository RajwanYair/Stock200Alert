/**
 * Coverage for retry-backoff.ts (lines 40-41, 61) and storage-pressure.ts (lines 38-39, 53).
 */
import { describe, it, expect, vi } from "vitest";
import { retry, nextDelay } from "../../../src/core/retry-backoff";
import {
  createStoragePressureMonitor,
  requestPersistentStorage,
} from "../../../src/core/storage-pressure";

describe("retry-backoff coverage", () => {
  it("nextDelay with equal jitter returns value in [delay/2, delay] (line 30)", () => {
    const d = nextDelay(0, { baseMs: 100, jitter: "equal", random: () => 0.5 });
    // equal jitter: base/2 + 0.5 * base/2 = 75
    expect(d).toBe(75);
  });

  it("retry uses default sleep (real setTimeout) when none provided (lines 40-41)", async () => {
    vi.useFakeTimers();
    let attempt = 0;
    const p = retry(
      async (a) => {
        attempt = a;
        if (a === 0) throw new Error("fail");
        return "ok";
      },
      { maxAttempts: 2, baseMs: 10 },
    );

    // Advance timers to let the default sleep resolve
    await vi.advanceTimersByTimeAsync(50);
    const result = await p;
    expect(result).toBe("ok");
    expect(attempt).toBe(1);
    vi.useRealTimers();
  });

  it("retry throws lastError when maxAttempts exhausted (line 61)", async () => {
    // This exercises the final `throw lastError` at line 61
    // by making shouldRetry always true but maxAttempts is reached
    await expect(
      retry(
        async () => {
          throw new Error("always fails");
        },
        {
          maxAttempts: 3,
          sleep: async () => {},
          shouldRetry: () => true,
        },
      ),
    ).rejects.toThrow("always fails");
  });
});

describe("storage-pressure coverage", () => {
  it("defaultEstimate returns null when navigator.storage is unavailable (lines 38-39)", async () => {
    // Remove navigator.storage temporarily
    const origStorage = navigator.storage;
    Object.defineProperty(navigator, "storage", {
      value: undefined,
      configurable: true,
      writable: true,
    });

    // createStoragePressureMonitor without custom `estimate` uses defaultEstimate
    const monitor = createStoragePressureMonitor({});
    const result = await monitor.check();
    expect(result).toBeNull();

    // Restore
    Object.defineProperty(navigator, "storage", {
      value: origStorage,
      configurable: true,
      writable: true,
    });
  });

  it("requestPersistentStorage returns false when navigator.storage.persist unavailable (line 53)", async () => {
    const origStorage = navigator.storage;
    Object.defineProperty(navigator, "storage", {
      value: undefined,
      configurable: true,
      writable: true,
    });

    const result = await requestPersistentStorage();
    expect(result).toBe(false);

    Object.defineProperty(navigator, "storage", {
      value: origStorage,
      configurable: true,
      writable: true,
    });
  });

  it("monitor.check triggers onPressure when ratio >= threshold", async () => {
    const onPressure = vi.fn();
    const monitor = createStoragePressureMonitor({
      threshold: 0.7,
      onPressure,
      estimate: async () => ({ usage: 800, quota: 1000, ratio: 0.8 }),
    });
    await monitor.check();
    expect(onPressure).toHaveBeenCalledWith({ usage: 800, quota: 1000, ratio: 0.8 });
  });
});
