/**
 * Coverage for file-system-access (non-AbortError fallback),
 * circuit-breaker (initial snapshot, closed-state success),
 * and webauthn (missing getPublicKey, isConditionalMediationAvailable absent).
 */
import { describe, it, expect, vi, afterEach } from "vitest";
import { saveStrategyToDisk, type StrategyFilePayload } from "../../../src/core/file-system-access";
import { createCircuitBreaker } from "../../../src/core/circuit-breaker";
import { checkWebAuthnSupport, registerCredential } from "../../../src/core/webauthn";

const SAMPLE: StrategyFilePayload = {
  expression: "rsi(14) < 30",
  varsJson: "{}",
  savedAt: "2026-05-01T00:00:00Z",
  version: 1,
};

describe("file-system-access — non-AbortError falls through to download", () => {
  afterEach(() => {
    vi.restoreAllMocks();
    delete (window as Record<string, unknown>).showSaveFilePicker;
  });

  it("falls back to <a> download when showSaveFilePicker throws non-AbortError", async () => {
    (window as Record<string, unknown>).showSaveFilePicker = vi.fn(async () => {
      throw new TypeError("SecurityError: blocked by policy");
    });

    vi.spyOn(URL, "createObjectURL").mockReturnValue("blob:fallback");
    vi.spyOn(URL, "revokeObjectURL").mockReturnValue(undefined);
    const clickSpy = vi.spyOn(HTMLAnchorElement.prototype, "click").mockImplementation(() => {});

    const result = await saveStrategyToDisk(SAMPLE);
    expect(result).toBe(true);
    expect(clickSpy).toHaveBeenCalled();
  });
});

describe("circuit-breaker — initial snapshot and closed success reset", () => {
  it("creates from initial snapshot in open state", () => {
    const cb = createCircuitBreaker(
      { cooldownMs: 1000 },
      {
        state: "open",
        failures: 5,
        successes: 0,
        openedAt: 1000,
      },
    );
    expect(cb.snapshot().state).toBe("open");
    // Before cooldown — still open
    expect(cb.allow(1500)).toBe(false);
    // After cooldown — transitions to half-open
    expect(cb.allow(2100)).toBe(true);
    expect(cb.snapshot().state).toBe("half-open");
  });

  it("creates from initial snapshot in half-open state", () => {
    const cb = createCircuitBreaker(
      { halfOpenSuccesses: 1 },
      {
        state: "half-open",
        failures: 0,
        successes: 0,
        openedAt: 0,
      },
    );
    expect(cb.allow()).toBe(true);
    cb.recordSuccess();
    // 1 success meets threshold → close
    expect(cb.snapshot().state).toBe("closed");
  });

  it("recordSuccess in closed state resets failure count", () => {
    const cb = createCircuitBreaker({ failureThreshold: 3 });
    cb.recordFailure();
    cb.recordFailure();
    expect(cb.snapshot().failures).toBe(2);
    cb.recordSuccess();
    expect(cb.snapshot().failures).toBe(0);
  });

  it("recordFailure in half-open transitions back to open", () => {
    const cb = createCircuitBreaker(
      { cooldownMs: 100 },
      {
        state: "open",
        failures: 5,
        successes: 0,
        openedAt: 0,
      },
    );
    // Transition to half-open
    cb.allow(200);
    expect(cb.snapshot().state).toBe("half-open");
    // Fail in half-open → back to open
    cb.recordFailure(200);
    expect(cb.snapshot().state).toBe("open");
  });
});

describe("webauthn — conditional mediation absent and getPublicKey undefined", () => {
  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("returns conditionalMediation=false when function doesn't exist", async () => {
    Object.defineProperty(globalThis, "PublicKeyCredential", {
      value: class {
        static isUserVerifyingPlatformAuthenticatorAvailable = vi.fn().mockResolvedValue(true);
        // No isConditionalMediationAvailable
      },
      writable: true,
      configurable: true,
    });
    Object.defineProperty(navigator, "credentials", {
      value: { create: vi.fn(), get: vi.fn() },
      writable: true,
      configurable: true,
    });

    const support = await checkWebAuthnSupport();
    expect(support.available).toBe(true);
    expect(support.conditionalMediation).toBe(false);
  });

  it("returns empty ArrayBuffer when getPublicKey is undefined", async () => {
    Object.defineProperty(globalThis, "PublicKeyCredential", {
      value: class {
        static isUserVerifyingPlatformAuthenticatorAvailable = vi.fn().mockResolvedValue(true);
      },
      writable: true,
      configurable: true,
    });
    const mockCredential = {
      rawId: new Uint8Array([1, 2, 3]).buffer,
      response: {
        // getPublicKey is undefined (e.g. old browser)
      },
    };
    Object.defineProperty(navigator, "credentials", {
      value: {
        create: vi.fn().mockResolvedValue(mockCredential),
        get: vi.fn(),
      },
      writable: true,
      configurable: true,
    });

    const result = await registerCredential({
      userName: "user@test.com",
      displayName: "User",
    });
    expect(result).not.toBeNull();
    expect(result!.publicKey.byteLength).toBe(0);
  });
});
