/**
 * Service Worker — Workbox-powered precache + runtime caching.
 *
 * Strategies:
 *  - App shell:   precacheAndRoute() — hash-versioned via workbox-inject post-build
 *  - /api/*:      NetworkFirst (10 s timeout, 5-min IDB expiry)
 *  - JS/CSS/SW:   StaleWhileRevalidate (7-day expiry)
 *  - Images:      CacheFirst (30-day expiry)
 *
 * Background sync (offline mutations) is handled by core/sync-queue.ts
 * at the application layer, not in the SW layer.
 */
import { precacheAndRoute, cleanupOutdatedCaches } from "workbox-precaching";
import type { PrecacheEntry } from "workbox-precaching";
import { registerRoute } from "workbox-routing";
import { NetworkFirst, StaleWhileRevalidate, CacheFirst } from "workbox-strategies";
import { ExpirationPlugin } from "workbox-expiration";
import { enable as enableNavigationPreload } from "workbox-navigation-preload";
import {
  CACHE_NAMES,
  NETWORK_TIMEOUT_SECONDS,
  getExpirationConfig,
} from "./core/sw-cache-config";

declare const self: ServiceWorkerGlobalScope;

// Navigation Preload speeds up navigations when SW is active
enableNavigationPreload();

// Remove caches left by previous SW versions
cleanupOutdatedCaches();

// Precache app shell with hash-versioned entries (injected by workbox-inject.mjs).
// Falls back to a minimal set when the manifest hasn't been injected yet (dev).
precacheAndRoute(
  (self as unknown as { __WB_MANIFEST?: PrecacheEntry[] }).__WB_MANIFEST ?? [
    { url: "./", revision: null },
    { url: "./index.html", revision: null },
  ],
);

// ─── Runtime caching ──────────────────────────────────────────────────────────

// /api/* — NetworkFirst: fresh data preferred, stale on timeout/offline
registerRoute(
  ({ url }: { url: URL }) => url.pathname.startsWith("/api/"),
  new NetworkFirst({
    cacheName: CACHE_NAMES.api,
    networkTimeoutSeconds: NETWORK_TIMEOUT_SECONDS,
    // Workbox types predate exactOptionalPropertyTypes — safe cast
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    plugins: [new ExpirationPlugin(getExpirationConfig("api")) as any],
  }),
);

// JS/CSS/Worker scripts — StaleWhileRevalidate: fast load, refresh in background
registerRoute(
  ({ request }: { request: Request }) =>
    request.destination === "style" ||
    request.destination === "script" ||
    request.destination === "worker",
  new StaleWhileRevalidate({
    cacheName: CACHE_NAMES.static,
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    plugins: [new ExpirationPlugin(getExpirationConfig("static")) as any],
  }),
);

// Images — CacheFirst: long-lived assets
registerRoute(
  ({ request }: { request: Request }) => request.destination === "image",
  new CacheFirst({
    cacheName: CACHE_NAMES.images,
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    plugins: [new ExpirationPlugin(getExpirationConfig("images")) as any],
  }),
);
