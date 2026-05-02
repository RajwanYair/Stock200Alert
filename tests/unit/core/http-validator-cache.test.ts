import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";
import {
  getValidators,
  setValidators,
  buildConditionalHeaders,
  clearValidators,
} from "../../../src/core/http-validator-cache";

// ── helpers ──────────────────────────────────────────────────────────────────

function storageMock(): Storage {
  const store: Record<string, string> = {};
  return {
    getItem: (k: string) => store[k] ?? null,
    setItem: (k: string, v: string) => {
      store[k] = v;
    },
    removeItem: (k: string) => {
      delete store[k];
    },
    clear: () => {
      Object.keys(store).forEach((k) => {
        delete store[k];
      });
    },
    key: (i: number) => Object.keys(store)[i] ?? null,
    get length() {
      return Object.keys(store).length;
    },
  };
}

function makeResponse(headers: Record<string, string>): Response {
  return new Response(null, { status: 200, headers });
}

// ── tests ─────────────────────────────────────────────────────────────────────

describe("http-validator-cache (G14)", () => {
  const URL = "https://example.com/api/data";

  beforeEach(() => {
    vi.stubGlobal("localStorage", storageMock());
  });

  afterEach(() => {
    vi.unstubAllGlobals();
  });

  describe("getValidators", () => {
    it("returns empty object when nothing stored", () => {
      expect(getValidators(URL)).toEqual({});
    });
  });

  describe("setValidators", () => {
    it("stores ETag from response", () => {
      setValidators(URL, makeResponse({ ETag: '"abc123"' }));
      expect(getValidators(URL)).toEqual({ etag: '"abc123"' });
    });

    it("stores Last-Modified from response", () => {
      setValidators(URL, makeResponse({ "Last-Modified": "Wed, 01 Jan 2025 00:00:00 GMT" }));
      expect(getValidators(URL)).toEqual({
        lastModified: "Wed, 01 Jan 2025 00:00:00 GMT",
      });
    });

    it("stores both ETag and Last-Modified", () => {
      setValidators(
        URL,
        makeResponse({
          ETag: '"v2"',
          "Last-Modified": "Thu, 02 Jan 2025 00:00:00 GMT",
        }),
      );
      const v = getValidators(URL);
      expect(v.etag).toBe('"v2"');
      expect(v.lastModified).toBe("Thu, 02 Jan 2025 00:00:00 GMT");
    });

    it("does nothing if neither header is present", () => {
      setValidators(URL, makeResponse({}));
      expect(getValidators(URL)).toEqual({});
    });

    it("overwrites previous validators with new values", () => {
      setValidators(URL, makeResponse({ ETag: '"old"' }));
      setValidators(URL, makeResponse({ ETag: '"new"' }));
      expect(getValidators(URL).etag).toBe('"new"');
    });
  });

  describe("buildConditionalHeaders", () => {
    it("returns empty object when no validators stored", () => {
      expect(buildConditionalHeaders(URL)).toEqual({});
    });

    it("builds If-None-Match from ETag", () => {
      setValidators(URL, makeResponse({ ETag: '"abc"' }));
      expect(buildConditionalHeaders(URL)).toEqual({ "If-None-Match": '"abc"' });
    });

    it("builds If-Modified-Since from Last-Modified", () => {
      setValidators(URL, makeResponse({ "Last-Modified": "Fri, 01 Nov 2024 00:00:00 GMT" }));
      expect(buildConditionalHeaders(URL)).toEqual({
        "If-Modified-Since": "Fri, 01 Nov 2024 00:00:00 GMT",
      });
    });

    it("builds both conditional headers when both validators stored", () => {
      setValidators(
        URL,
        makeResponse({ ETag: '"x"', "Last-Modified": "Sat, 01 Jan 2000 00:00:00 GMT" }),
      );
      const h = buildConditionalHeaders(URL);
      expect(h["If-None-Match"]).toBe('"x"');
      expect(h["If-Modified-Since"]).toBe("Sat, 01 Jan 2000 00:00:00 GMT");
    });
  });

  describe("clearValidators", () => {
    it("removes stored validators", () => {
      setValidators(URL, makeResponse({ ETag: '"abc"' }));
      clearValidators(URL);
      expect(getValidators(URL)).toEqual({});
    });

    it("is a no-op when nothing stored", () => {
      expect(() => clearValidators(URL)).not.toThrow();
    });
  });

  describe("isolation between URLs", () => {
    it("validators for different URLs do not interfere", () => {
      const url2 = "https://example.com/api/other";
      setValidators(URL, makeResponse({ ETag: '"url1"' }));
      setValidators(url2, makeResponse({ ETag: '"url2"' }));
      expect(getValidators(URL).etag).toBe('"url1"');
      expect(getValidators(url2).etag).toBe('"url2"');
    });
  });

  describe("localStorage unavailable", () => {
    it("getValidators returns empty object if localStorage throws", () => {
      vi.stubGlobal("localStorage", {
        getItem: () => {
          throw new Error("unavailable");
        },
        setItem: () => {
          /* no-op */
        },
        removeItem: () => {
          /* no-op */
        },
        clear: () => {
          /* no-op */
        },
        key: () => null,
        length: 0,
      });
      expect(getValidators(URL)).toEqual({});
    });

    it("setValidators does not throw if localStorage throws", () => {
      vi.stubGlobal("localStorage", {
        getItem: () => null,
        setItem: () => {
          throw new Error("QuotaExceededError");
        },
        removeItem: () => {
          /* no-op */
        },
        clear: () => {
          /* no-op */
        },
        key: () => null,
        length: 0,
      });
      expect(() => setValidators(URL, makeResponse({ ETag: '"abc"' }))).not.toThrow();
    });
  });
});
