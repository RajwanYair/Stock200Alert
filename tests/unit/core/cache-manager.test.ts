/**
 * Unit tests for unified cache manager (R16).
 */
import { describe, it, expect, beforeEach } from "vitest";
import { createCacheManager } from "../../../src/core/cache-manager";
import type { CacheManager, CacheTier } from "../../../src/core/cache-manager";

// ── Shared behavior tests (run for each tier) ────────────────────────────

const TIERS: CacheTier[] = ["memory", "lru", "tiered"];

for (const tier of TIERS) {
  describe(`CacheManager (${tier})`, () => {
    let mgr: CacheManager;

    beforeEach(() => {
      mgr = createCacheManager({ tier, defaultTtlMs: 5_000, maxEntries: 10 });
    });

    it("reports correct tier", () => {
      expect(mgr.tier).toBe(tier);
    });

    it("get returns null for missing key", () => {
      expect(mgr.get("nope")).toBeNull();
    });

    it("set + get round-trips a value", () => {
      mgr.set("key", { hello: "world" });
      expect(mgr.get<{ hello: string }>("key")).toEqual({ hello: "world" });
    });

    it("set overwrites existing value", () => {
      mgr.set("k", 1);
      mgr.set("k", 2);
      expect(mgr.get<number>("k")).toBe(2);
    });

    it("delete removes entry", () => {
      mgr.set("k", 42);
      mgr.delete("k");
      expect(mgr.get("k")).toBeNull();
    });

    it("clear removes all entries", () => {
      mgr.set("a", 1);
      mgr.set("b", 2);
      mgr.clear();
      expect(mgr.size).toBe(0);
      expect(mgr.get("a")).toBeNull();
    });

    it("size tracks entry count", () => {
      expect(mgr.size).toBe(0);
      mgr.set("a", 1);
      mgr.set("b", 2);
      expect(mgr.size).toBe(2);
    });

    it("stats tracks hits and misses", () => {
      mgr.set("hit", 1);
      mgr.get("hit"); // hit
      mgr.get("miss"); // miss
      const s = mgr.stats();
      expect(s.hits).toBe(1);
      expect(s.misses).toBe(1);
      expect(s.hitRate).toBeCloseTo(0.5);
    });

    it("stats hitRate is 0 when no accesses", () => {
      expect(mgr.stats().hitRate).toBe(0);
    });

    it("clear resets hit/miss counters", () => {
      mgr.set("k", 1);
      mgr.get("k");
      mgr.clear();
      const s = mgr.stats();
      expect(s.hits).toBe(0);
      expect(s.misses).toBe(0);
    });
  });
}

// ── Memory-specific ──────────────────────────────────────────────────────

describe("CacheManager (memory) — specifics", () => {
  it("evict returns 0 (memory has no eviction)", () => {
    const mgr = createCacheManager({ tier: "memory" });
    mgr.set("a", 1);
    expect(mgr.evict(1)).toBe(0);
  });

  it("respects custom TTL override", () => {
    const mgr = createCacheManager({ tier: "memory", defaultTtlMs: 60_000 });
    // Set with -1ms TTL → already expired
    mgr.set("k", "val", -1);
    expect(mgr.get("k")).toBeNull();
  });
});

// ── LRU-specific ─────────────────────────────────────────────────────────

describe("CacheManager (lru) — specifics", () => {
  it("evicts oldest entries on capacity overflow", () => {
    const mgr = createCacheManager({ tier: "lru", maxEntries: 3 });
    mgr.set("a", 1);
    mgr.set("b", 2);
    mgr.set("c", 3);
    mgr.set("d", 4); // should evict "a"
    expect(mgr.get("a")).toBeNull();
    expect(mgr.get("d")).not.toBeNull();
  });

  it("evict() removes oldest N entries", () => {
    const mgr = createCacheManager({ tier: "lru", maxEntries: 10 });
    mgr.set("a", 1);
    mgr.set("b", 2);
    mgr.set("c", 3);
    const evicted = mgr.evict(2);
    expect(evicted).toBe(2);
    expect(mgr.size).toBe(1);
  });
});

// ── Tiered-specific ──────────────────────────────────────────────────────

describe("CacheManager (tiered) — specifics", () => {
  it("evict() delegates to TieredCache.evictOldest", () => {
    const mgr = createCacheManager({ tier: "tiered", defaultTtlMs: 60_000 });
    mgr.set("a", 1);
    mgr.set("b", 2);
    mgr.set("c", 3);
    const evicted = mgr.evict(2);
    expect(evicted).toBe(2);
    expect(mgr.size).toBe(1);
  });

  it("supports custom TTL per set call", () => {
    const mgr = createCacheManager({ tier: "tiered", defaultTtlMs: 60_000 });
    mgr.set("k", "val", -1); // already expired
    expect(mgr.get("k")).toBeNull();
  });
});
