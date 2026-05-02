/**
 * Fetch utilities — timeout, retry, error handling.
 */

import { buildConditionalHeaders, setValidators } from "./http-validator-cache";

export class FetchError extends Error {
  constructor(
    message: string,
    public readonly status?: number,
  ) {
    super(message);
    this.name = "FetchError";
  }
}

/**
 * Fetch with timeout. Rejects if the request takes longer than `timeoutMs`.
 * Optionally accepts a parent `signal` (e.g. a navigation signal) — the request
 * is aborted if either the timeout or the parent signal fires first.
 */
export async function fetchWithTimeout(
  url: string,
  options: RequestInit = {},
  timeoutMs = 10000,
  parentSignal?: AbortSignal,
): Promise<Response> {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);

  // Forward parent abort (e.g. navigation) to our controller.
  let parentListener: (() => void) | undefined;
  if (parentSignal) {
    if (parentSignal.aborted) {
      clearTimeout(timer);
      controller.abort();
    } else {
      parentListener = (): void => {
        controller.abort();
      };
      parentSignal.addEventListener("abort", parentListener, { once: true });
    }
  }

  try {
    const response = await fetch(url, {
      ...options,
      signal: controller.signal,
    });
    if (!response.ok) {
      throw new FetchError(`HTTP ${response.status}: ${response.statusText}`, response.status);
    }
    return response;
  } finally {
    clearTimeout(timer);
    if (parentSignal && parentListener) {
      parentSignal.removeEventListener("abort", parentListener);
    }
  }
}

/**
 * Fetch with exponential backoff retry.
 */
export async function fetchWithRetry(
  url: string,
  options: RequestInit = {},
  maxRetries = 3,
  baseDelayMs = 1000,
  parentSignal?: AbortSignal,
): Promise<Response> {
  let lastError: Error | null = null;

  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      return await fetchWithTimeout(url, options, 10000, parentSignal);
    } catch (err) {
      lastError = err instanceof Error ? err : new Error(String(err));
      // Don't retry on abort — the caller cancelled the request.
      if (lastError.name === "AbortError") throw lastError;
      if (attempt < maxRetries) {
        const delay = baseDelayMs * 2 ** attempt;
        await new Promise((resolve) => setTimeout(resolve, delay));
      }
    }
  }

  throw lastError ?? new FetchError("Fetch failed after retries");
}

/**
 * Conditional GET with ETag / Last-Modified caching (G14).
 *
 * On the first request (no stored validators) this behaves identically to
 * `fetchWithTimeout` and stores any `ETag` / `Last-Modified` headers for
 * subsequent calls.
 *
 * On repeat requests the stored validators are sent as `If-None-Match` /
 * `If-Modified-Since` headers.  A 304 Not Modified response means the
 * payload has not changed — the caller should reuse its cached data.
 *
 * Returns:
 *   { notModified: true }              — server returned 304; use cached value.
 *   { notModified: false; response }   — server returned 2xx; consume response.
 *
 * Throws `FetchError` on 4xx/5xx or network errors.
 * Throws `AbortError` if the `parentSignal` or the timeout fires.
 */
export async function fetchConditional(
  url: string,
  options: RequestInit = {},
  timeoutMs = 10000,
  parentSignal?: AbortSignal,
): Promise<{ notModified: true } | { notModified: false; response: Response }> {
  const conditionalHeaders = buildConditionalHeaders(url);
  const mergedHeaders: Record<string, string> = {
    ...conditionalHeaders,
    ...((options.headers as Record<string, string> | undefined) ?? {}),
  };

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);

  let parentListener: (() => void) | undefined;
  if (parentSignal) {
    if (parentSignal.aborted) {
      clearTimeout(timer);
      controller.abort();
    } else {
      parentListener = (): void => {
        controller.abort();
      };
      parentSignal.addEventListener("abort", parentListener, { once: true });
    }
  }

  try {
    const response = await fetch(url, {
      ...options,
      headers: mergedHeaders,
      signal: controller.signal,
    });

    if (response.status === 304) {
      // Not Modified — caller should use its cached data.
      return { notModified: true };
    }

    if (!response.ok) {
      throw new FetchError(`HTTP ${response.status}: ${response.statusText}`, response.status);
    }

    // Store validators for the next request (may be no-op if server didn't send them).
    setValidators(url, response);
    return { notModified: false, response };
  } finally {
    clearTimeout(timer);
    if (parentSignal && parentListener) {
      parentSignal.removeEventListener("abort", parentListener);
    }
  }
}
