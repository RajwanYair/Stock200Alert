/**
 * Fetch utilities — timeout, retry, error handling.
 */

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
      parentListener = () => controller.abort();
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
