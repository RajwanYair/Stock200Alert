/**
 * Unified cache manager (R16) — single-entry facade over the three cache
 * implementations: Cache (L1 TTL), LruCache (bounded LRU), TieredCache (L1+L2).
 *
 * Instead of consumers choosing which cache implementation to instantiate,
 * `createCacheManager` returns a unified API that internally delegates to
 * the appropriate tier based on the configured `CacheTier` strategy.
 *
 * Usage:
 *   const mgr = createCacheManager({ tier: "tiered", maxEntries: 500, defaultTtlMs: 60_000 });
 *   mgr.set("key", value);
 *   const hit = mgr.get<MyType>("key");
 */

import { Cache } from "./cache";
import { LruCache } from "./lru-cache";
import { TieredCache } from "./tiered-cache";

// ── Types ────────────────────────────────────────────────────────────────

/** Strategy for cache storage. */
export type CacheTier = "memory" | "lru" | "tiered";

export interface CacheManagerOptions {
  /** Which cache implementation to use. */
  readonly tier: CacheTier;
  /** Default TTL in milliseconds (used by memory and tiered tiers). */
  readonly defaultTtlMs?: number;
  /** Max entries for LRU tier. Defaults to 500. */
  readonly maxEntries?: number;
}

export interface CacheManager {
  /** Get a cached value, or null if missing/expired. */
  get<T>(key: string): T | null;
  /** Store a value. Optional ttlMs overrides the default. */
  set<T>(key: string, value: T, ttlMs?: number): void;
  /** Delete a single key. */
  delete(key: string): void;
  /** Clear all entries. */
  clear(): void;
  /** Current number of entries (L1 count for tiered). */
  readonly size: number;
  /** The active tier strategy. */
  readonly tier: CacheTier;
  /** Evict N oldest entries (tiered/lru). Returns count evicted. */
  evict(count: number): number;
  /** Stats snapshot. */
  stats(): CacheStats;
}

export interface CacheStats {
  readonly tier: CacheTier;
  readonly size: number;
  readonly hits: number;
  readonly misses: number;
  readonly hitRate: number;
}

// ── Factory ──────────────────────────────────────────────────────────────

export function createCacheManager(options: CacheManagerOptions): CacheManager {
  const { tier, defaultTtlMs = 60_000, maxEntries = 500 } = options;
  let hits = 0;
  let misses = 0;

  if (tier === "memory") {
    const cache = new Cache();
    return {
      get<T>(key: string): T | null {
        const v = cache.get<T>(key);
        if (v !== null) {
          hits++;
        } else {
          misses++;
        }
        return v;
      },
      set<T>(key: string, value: T, ttlMs?: number): void {
        cache.set(key, value, ttlMs ?? defaultTtlMs);
      },
      delete: (k: string): void => cache.delete(k),
      clear: (): void => {
        cache.clear();
        hits = 0;
        misses = 0;
      },
      get size(): number {
        return cache.size;
      },
      tier,
      evict: (): number => 0, // memory cache has no eviction strategy
      stats: (): CacheStats => ({
        tier,
        size: cache.size,
        hits,
        misses,
        hitRate: hits + misses > 0 ? hits / (hits + misses) : 0,
      }),
    };
  }

  if (tier === "lru") {
    const cache = new LruCache<string, unknown>({ max: maxEntries });
    return {
      get<T>(key: string): T | null {
        const v = cache.get(key);
        if (v !== undefined) {
          hits++;
          return v as T;
        }
        misses++;
        return null;
      },
      set<T>(key: string, value: T): void {
        cache.set(key, value);
      },
      delete: (k: string): void => {
        cache.delete(k);
      },
      clear: (): void => {
        cache.clear();
        hits = 0;
        misses = 0;
      },
      get size(): number {
        return cache.size;
      },
      tier,
      evict(count: number): number {
        let evicted = 0;
        const keys = [...cache.keys()];
        for (const key of keys) {
          if (evicted >= count) break;
          cache.delete(key);
          evicted++;
        }
        return evicted;
      },
      stats: (): CacheStats => ({
        tier,
        size: cache.size,
        hits,
        misses,
        hitRate: hits + misses > 0 ? hits / (hits + misses) : 0,
      }),
    };
  }

  // tier === "tiered"
  const cache = new TieredCache();
  return {
    get<T>(key: string): T | null {
      const v = cache.get<T>(key);
      if (v !== null) {
        hits++;
      } else {
        misses++;
      }
      return v;
    },
    set<T>(key: string, value: T, ttlMs?: number): void {
      cache.set(key, value, ttlMs ?? defaultTtlMs);
    },
    delete: (k: string): void => cache.delete(k),
    clear: (): void => {
      cache.clear();
      hits = 0;
      misses = 0;
    },
    get size(): number {
      return cache.size;
    },
    tier,
    evict: (count: number): number => cache.evictOldest(count),
    stats: (): CacheStats => ({
      tier,
      size: cache.size,
      hits,
      misses,
      hitRate: hits + misses > 0 ? hits / (hits + misses) : 0,
    }),
  };
}
