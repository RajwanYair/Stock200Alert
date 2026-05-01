import { describe, it, expect } from "vitest";
import {
  CACHE_VERSION,
  CACHE_NAMES,
  EXPIRATION_CONFIGS,
  NETWORK_TIMEOUT_SECONDS,
  BG_SYNC_QUEUE_NAME,
  BG_SYNC_MAX_RETENTION_MINUTES,
  shouldUseNetworkFirst,
  shouldUseStaleWhileRevalidate,
  shouldUseCacheFirst,
  getExpirationConfig,
} from "../../../src/core/sw-cache-config";

describe("sw-cache-config", () => {
  describe("CACHE_NAMES", () => {
    it("all cache names include the cache version", () => {
      for (const name of Object.values(CACHE_NAMES)) {
        expect(name).toContain(CACHE_VERSION);
      }
    });

    it("all cache names start with 'crosstide-'", () => {
      for (const name of Object.values(CACHE_NAMES)) {
        expect(name).toMatch(/^crosstide-/);
      }
    });

    it("has precache, api, static, images keys", () => {
      expect(CACHE_NAMES).toHaveProperty("precache");
      expect(CACHE_NAMES).toHaveProperty("api");
      expect(CACHE_NAMES).toHaveProperty("static");
      expect(CACHE_NAMES).toHaveProperty("images");
    });

    it("all names are unique", () => {
      const names = Object.values(CACHE_NAMES);
      expect(new Set(names).size).toBe(names.length);
    });
  });

  describe("NETWORK_TIMEOUT_SECONDS", () => {
    it("is a positive integer", () => {
      expect(NETWORK_TIMEOUT_SECONDS).toBeGreaterThan(0);
      expect(Number.isInteger(NETWORK_TIMEOUT_SECONDS)).toBe(true);
    });
  });

  describe("BG_SYNC constants", () => {
    it("BG_SYNC_QUEUE_NAME is a non-empty string", () => {
      expect(typeof BG_SYNC_QUEUE_NAME).toBe("string");
      expect(BG_SYNC_QUEUE_NAME.length).toBeGreaterThan(0);
    });

    it("BG_SYNC_MAX_RETENTION_MINUTES is at least 60 minutes", () => {
      expect(BG_SYNC_MAX_RETENTION_MINUTES).toBeGreaterThanOrEqual(60);
    });
  });

  describe("shouldUseNetworkFirst", () => {
    it("returns true for /api/ paths", () => {
      expect(shouldUseNetworkFirst("/api/quote/AAPL")).toBe(true);
      expect(shouldUseNetworkFirst("/api/history/AAPL")).toBe(true);
      expect(shouldUseNetworkFirst("/api/")).toBe(true);
    });

    it("returns false for non-API paths", () => {
      expect(shouldUseNetworkFirst("/")).toBe(false);
      expect(shouldUseNetworkFirst("/index.html")).toBe(false);
      expect(shouldUseNetworkFirst("/assets/main.js")).toBe(false);
    });
  });

  describe("shouldUseStaleWhileRevalidate", () => {
    it("returns true for style, script, worker, manifest", () => {
      expect(shouldUseStaleWhileRevalidate("style")).toBe(true);
      expect(shouldUseStaleWhileRevalidate("script")).toBe(true);
      expect(shouldUseStaleWhileRevalidate("worker")).toBe(true);
      expect(shouldUseStaleWhileRevalidate("manifest")).toBe(true);
    });

    it("returns false for image, font, document", () => {
      expect(shouldUseStaleWhileRevalidate("image")).toBe(false);
      expect(shouldUseStaleWhileRevalidate("font")).toBe(false);
    });
  });

  describe("shouldUseCacheFirst", () => {
    it("returns true for image and font", () => {
      expect(shouldUseCacheFirst("image")).toBe(true);
      expect(shouldUseCacheFirst("font")).toBe(true);
    });

    it("returns false for script, style, document", () => {
      expect(shouldUseCacheFirst("script")).toBe(false);
      expect(shouldUseCacheFirst("style")).toBe(false);
      expect(shouldUseCacheFirst("document")).toBe(false);
    });
  });

  describe("getExpirationConfig", () => {
    it("returns api config with short maxAgeSeconds", () => {
      const cfg = getExpirationConfig("api");
      expect(cfg.maxEntries).toBeGreaterThan(0);
      expect(cfg.maxAgeSeconds).toBe(5 * 60);
    });

    it("returns static config with 7-day maxAgeSeconds", () => {
      const cfg = getExpirationConfig("static");
      expect(cfg.maxAgeSeconds).toBe(7 * 24 * 60 * 60);
    });

    it("returns images config with 30-day maxAgeSeconds", () => {
      const cfg = getExpirationConfig("images");
      expect(cfg.maxAgeSeconds).toBe(30 * 24 * 60 * 60);
    });

    it("all configs have positive maxEntries and maxAgeSeconds", () => {
      for (const cfg of Object.values(EXPIRATION_CONFIGS)) {
        expect(cfg.maxEntries).toBeGreaterThan(0);
        expect(cfg.maxAgeSeconds).toBeGreaterThan(0);
      }
    });
  });
});
