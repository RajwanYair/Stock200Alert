/**
 * Coverage for tiered-cache.ts — localStorage errors, L2 expiry cleanup,
 * and evictOldest edge cases.
 */
import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";
import { TieredCache } from "../../../src/core/tiered-cache";

describe("TieredCache coverage — error/edge branches", () => {
  let cache: TieredCache;

  beforeEach(() => {
    cache = new TieredCache();
  });

  afterEach(() => {
    vi.unstubAllGlobals();
  });

  it("set() survives when localStorage.setItem throws (quota exceeded)", () => {
    const store = new Map<string, string>();
    vi.stubGlobal("localStorage", {
      get length() {
        return store.size;
      },
      key(i: number) {
        return [...store.keys()][i] ?? null;
      },
      getItem(k: string) {
        return store.get(k) ?? null;
      },
      setItem() {
        throw new DOMException("QuotaExceededError");
      },
      removeItem(k: string) {
        store.delete(k);
      },
      clear() {
        store.clear();
      },
    });

    // Should not throw — L1 still works
    cache.set("k", "value", 60_000);
    expect(cache.get("k")).toBe("value");
  });

  it("get() returns null when localStorage has corrupt JSON", () => {
    const store = new Map<string, string>();
    store.set("ct_cache_corrupt", "not-valid-json{{{");
    vi.stubGlobal("localStorage", {
      get length() {
        return store.size;
      },
      key(i: number) {
        return [...store.keys()][i] ?? null;
      },
      getItem(k: string) {
        return store.get(k) ?? null;
      },
      setItem(k: string, v: string) {
        store.set(k, v);
      },
      removeItem(k: string) {
        store.delete(k);
      },
      clear() {
        store.clear();
      },
    });

    // Should not throw — just returns null
    expect(cache.get("corrupt")).toBeNull();
  });

  it("get() removes expired L2 entry from localStorage", () => {
    const store = new Map<string, string>();
    // Expired entry (expiresAt in the past)
    store.set("ct_cache_old", JSON.stringify({ value: "stale", expiresAt: 0 }));
    const removeSpy = vi.fn((k: string) => {
      store.delete(k);
    });
    vi.stubGlobal("localStorage", {
      get length() {
        return store.size;
      },
      key(i: number) {
        return [...store.keys()][i] ?? null;
      },
      getItem(k: string) {
        return store.get(k) ?? null;
      },
      setItem(k: string, v: string) {
        store.set(k, v);
      },
      removeItem: removeSpy,
      clear() {
        store.clear();
      },
    });

    const result = cache.get("old");
    expect(result).toBeNull();
    expect(removeSpy).toHaveBeenCalledWith("ct_cache_old");
  });

  it("clear() survives when localStorage throws", () => {
    vi.stubGlobal("localStorage", {
      get length() {
        throw new Error("SecurityError");
      },
      key() {
        throw new Error("SecurityError");
      },
      getItem() {
        throw new Error("SecurityError");
      },
      setItem() {
        throw new Error("SecurityError");
      },
      removeItem() {
        throw new Error("SecurityError");
      },
      clear() {
        throw new Error("SecurityError");
      },
    });

    cache.set("k", "v", 60_000);
    // Should not throw
    cache.clear();
    expect(cache.size).toBe(0);
  });

  it("delete() survives when localStorage.removeItem throws", () => {
    vi.stubGlobal("localStorage", {
      get length() {
        return 0;
      },
      key() {
        return null;
      },
      getItem() {
        return null;
      },
      setItem() {
        /* noop */
      },
      removeItem() {
        throw new Error("SecurityError");
      },
      clear() {
        /* noop */
      },
    });

    cache.set("k", "v", 60_000);
    // Should not throw
    cache.delete("k");
    expect(cache.size).toBe(0);
  });

  it("evictOldest(0) evicts nothing", () => {
    vi.stubGlobal("localStorage", {
      get length() {
        return 0;
      },
      key() {
        return null;
      },
      getItem() {
        return null;
      },
      setItem() {
        /* noop */
      },
      removeItem() {
        /* noop */
      },
      clear() {
        /* noop */
      },
    });

    cache.set("a", 1, 60_000);
    const evicted = cache.evictOldest(0);
    expect(evicted).toBe(0);
    expect(cache.size).toBe(1);
  });

  it("evictOldest(N) where N > size evicts all entries", () => {
    vi.stubGlobal("localStorage", {
      get length() {
        return 0;
      },
      key() {
        return null;
      },
      getItem() {
        return null;
      },
      setItem() {
        /* noop */
      },
      removeItem() {
        /* noop */
      },
      clear() {
        /* noop */
      },
    });

    cache.set("x", 1, 1_000);
    cache.set("y", 2, 2_000);
    const evicted = cache.evictOldest(10);
    expect(evicted).toBe(2);
    expect(cache.size).toBe(0);
  });
});
