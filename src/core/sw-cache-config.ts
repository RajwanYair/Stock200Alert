/**
 * Service Worker cache configuration — shared constants and helpers.
 *
 * Kept outside sw.ts so it can be imported by tests running in a normal
 * browser environment (no ServiceWorkerGlobalScope required).
 */

export const CACHE_VERSION = "v1" as const;

export const CACHE_NAMES = {
  precache: `crosstide-precache-${CACHE_VERSION}`,
  api: `crosstide-api-${CACHE_VERSION}`,
  static: `crosstide-static-${CACHE_VERSION}`,
  images: `crosstide-images-${CACHE_VERSION}`,
} as const satisfies Record<string, string>;

export type CacheType = keyof typeof CACHE_NAMES;

export interface ExpirationConfig {
  readonly maxEntries: number;
  /** Maximum age in seconds before an entry is evicted. */
  readonly maxAgeSeconds: number;
}

export const EXPIRATION_CONFIGS = {
  api: { maxEntries: 50, maxAgeSeconds: 5 * 60 } satisfies ExpirationConfig,
  static: { maxEntries: 60, maxAgeSeconds: 7 * 24 * 60 * 60 } satisfies ExpirationConfig,
  images: { maxEntries: 30, maxAgeSeconds: 30 * 24 * 60 * 60 } satisfies ExpirationConfig,
} as const;

/** Network timeout before falling back to cache in NetworkFirst strategy. */
export const NETWORK_TIMEOUT_SECONDS = 10 as const;

/** Background sync queue name — must match BackgroundSyncPlugin queue name. */
export const BG_SYNC_QUEUE_NAME = "crosstide-sync-queue" as const;

/** Max retention time (minutes) for background sync queue entries. */
export const BG_SYNC_MAX_RETENTION_MINUTES = 1440; // 24 hours × 60 minutes

/**
 * Returns true when the given pathname should use NetworkFirst caching
 * (i.e. it is an API route that benefits from fresh data).
 */
export function shouldUseNetworkFirst(pathname: string): boolean {
  return pathname.startsWith("/api/");
}

/**
 * Returns true when the request destination should use StaleWhileRevalidate
 * (JS modules, CSS, workers — fast load with background refresh).
 */
export function shouldUseStaleWhileRevalidate(destination: string): boolean {
  return (
    destination === "style" ||
    destination === "script" ||
    destination === "worker" ||
    destination === "manifest"
  );
}

/**
 * Returns true when the request destination should use CacheFirst
 * (images, fonts — long-lived assets that rarely change).
 */
export function shouldUseCacheFirst(destination: string): boolean {
  return destination === "image" || destination === "font";
}

/**
 * Returns the expiration configuration for a given cache type.
 * Precache entries are managed by workbox-precaching directly.
 */
export function getExpirationConfig(type: Exclude<CacheType, "precache">): ExpirationConfig {
  return EXPIRATION_CONFIGS[type];
}
