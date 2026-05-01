import { describe, it, expect, vi } from "vitest";
import { combineSignals, withTimeout, isAbortError } from "../../../src/ui/abort-helpers";

describe("combineSignals", () => {
  it("aborts when any input aborts", () => {
    const a = new AbortController();
    const b = new AbortController();
    const sig = combineSignals(a.signal, b.signal);
    expect(sig.aborted).toBe(false);
    b.abort(new Error("from-b"));
    expect(sig.aborted).toBe(true);
  });

  it("returns aborted signal when an input is already aborted", () => {
    const a = new AbortController();
    a.abort(new Error("pre"));
    const sig = combineSignals(a.signal);
    expect(sig.aborted).toBe(true);
  });

  it("ignores null/undefined entries", () => {
    const a = new AbortController();
    const sig = combineSignals(undefined, null, a.signal);
    expect(sig.aborted).toBe(false);
    a.abort();
    expect(sig.aborted).toBe(true);
  });

  it("zero signals -> non-aborting signal", () => {
    const sig = combineSignals();
    expect(sig.aborted).toBe(false);
  });
});

describe("withTimeout", () => {
  it("aborts after timeout", async () => {
    vi.useFakeTimers();
    const sig = withTimeout(100);
    expect(sig.aborted).toBe(false);
    vi.advanceTimersByTime(100);
    expect(sig.aborted).toBe(true);
    vi.useRealTimers();
  });

  it("ms<=0 aborts immediately", () => {
    expect(withTimeout(0).aborted).toBe(true);
    expect(withTimeout(-5).aborted).toBe(true);
  });
});

describe("isAbortError", () => {
  it("identifies AbortError-like errors", () => {
    expect(isAbortError({ name: "AbortError" })).toBe(true);
  });
  it("rejects unrelated errors", () => {
    expect(isAbortError(new Error("nope"))).toBe(false);
    expect(isAbortError(null)).toBe(false);
    expect(isAbortError("AbortError")).toBe(false);
  });
});
