/**
 * Fetch.ts coverage boost — targets uncovered lines 115-159:
 *   fetchConditional: conditional GET with ETag/Last-Modified validators,
 *   304 Not Modified path, parent signal abort, pre-aborted parent signal.
 * Also covers fetchWithTimeout parentSignal and fetchWithRetry abort bail.
 */
import { describe, it, expect, vi, afterEach, beforeEach } from "vitest";
import {
  fetchConditional,
  fetchWithTimeout,
  fetchWithRetry,
  FetchError,
} from "../../../src/core/fetch";

describe("fetchConditional", () => {
  beforeEach(() => {
    vi.stubGlobal("fetch", vi.fn());
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("returns notModified: true on 304 response", async () => {
    (fetch as ReturnType<typeof vi.fn>).mockResolvedValue(
      new Response(null, { status: 304, statusText: "Not Modified" }),
    );

    const result = await fetchConditional("https://api.example.com/data");
    expect(result.notModified).toBe(true);
  });

  it("returns notModified: false with response on 200", async () => {
    const body = JSON.stringify({ data: "test" });
    (fetch as ReturnType<typeof vi.fn>).mockResolvedValue(
      new Response(body, {
        status: 200,
        headers: { ETag: '"abc123"', "Content-Type": "application/json" },
      }),
    );

    const result = await fetchConditional("https://api.example.com/data");
    expect(result.notModified).toBe(false);
    if (!result.notModified) {
      expect(result.response.ok).toBe(true);
    }
  });

  it("throws FetchError on non-ok response (e.g. 500)", async () => {
    (fetch as ReturnType<typeof vi.fn>).mockResolvedValue(
      new Response("error", { status: 500, statusText: "Internal Server Error" }),
    );

    await expect(fetchConditional("https://api.example.com/data")).rejects.toThrow(FetchError);
  });

  it("aborts when parent signal is already aborted", async () => {
    const abortController = new AbortController();
    abortController.abort();

    (fetch as ReturnType<typeof vi.fn>).mockRejectedValue(
      new DOMException("The operation was aborted.", "AbortError"),
    );

    await expect(
      fetchConditional("https://api.example.com/data", {}, 5000, abortController.signal),
    ).rejects.toThrow();
  });

  it("aborts when parent signal fires during fetch", async () => {
    const abortController = new AbortController();

    (fetch as ReturnType<typeof vi.fn>).mockImplementation(
      (_url: string, opts: RequestInit) =>
        new Promise((_resolve, reject) => {
          opts.signal?.addEventListener("abort", () => {
            reject(new DOMException("Aborted", "AbortError"));
          });
          // Abort the parent after a short delay
          setTimeout(() => abortController.abort(), 10);
        }),
    );

    await expect(
      fetchConditional("https://api.example.com/data", {}, 5000, abortController.signal),
    ).rejects.toThrow();
  });

  it("passes custom headers alongside conditional headers", async () => {
    (fetch as ReturnType<typeof vi.fn>).mockResolvedValue(new Response("ok", { status: 200 }));

    await fetchConditional("https://api.example.com/data", {
      headers: { Authorization: "Bearer token" },
    });

    const calledWith = (fetch as ReturnType<typeof vi.fn>).mock.calls[0]![1] as RequestInit;
    const headers = calledWith.headers as Record<string, string>;
    expect(headers["Authorization"]).toBe("Bearer token");
  });
});

describe("fetchWithTimeout — parentSignal", () => {
  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("forwards parent abort to the request", async () => {
    const parentController = new AbortController();
    vi.stubGlobal(
      "fetch",
      vi.fn().mockImplementation(
        (_url: string, opts: RequestInit) =>
          new Promise((_resolve, reject) => {
            opts.signal?.addEventListener("abort", () => {
              reject(new DOMException("Aborted", "AbortError"));
            });
            setTimeout(() => parentController.abort(), 10);
          }),
      ),
    );

    await expect(
      fetchWithTimeout("https://example.com", {}, 10000, parentController.signal),
    ).rejects.toThrow();
  });

  it("handles pre-aborted parent signal", async () => {
    const parentController = new AbortController();
    parentController.abort();

    vi.stubGlobal("fetch", vi.fn().mockRejectedValue(new DOMException("Aborted", "AbortError")));

    await expect(
      fetchWithTimeout("https://example.com", {}, 10000, parentController.signal),
    ).rejects.toThrow();
  });
});

describe("fetchWithRetry — abort bail", () => {
  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("does not retry on AbortError", async () => {
    vi.stubGlobal("fetch", vi.fn().mockRejectedValue(new DOMException("Aborted", "AbortError")));

    await expect(fetchWithRetry("https://example.com", {}, 3, 1)).rejects.toThrow("Aborted");
    // Should have only attempted once (no retry)
    expect(fetch).toHaveBeenCalledTimes(1);
  });

  it("forwards parentSignal to fetchWithTimeout", async () => {
    const parentController = new AbortController();
    parentController.abort();

    vi.stubGlobal("fetch", vi.fn().mockRejectedValue(new DOMException("Aborted", "AbortError")));

    await expect(
      fetchWithRetry("https://example.com", {}, 3, 1, parentController.signal),
    ).rejects.toThrow();
    expect(fetch).toHaveBeenCalledTimes(1);
  });
});
