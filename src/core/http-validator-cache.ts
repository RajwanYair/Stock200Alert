/**
 * HTTP Validator Cache (G14).
 *
 * Stores `ETag` and `Last-Modified` response headers per URL so subsequent
 * requests can include `If-None-Match` / `If-Modified-Since` for conditional
 * GETs.  A 304 Not Modified response lets the caller reuse cached data
 * without retransferring the full payload.
 *
 * Storage: localStorage, key prefix `ct_httpcache_<url>`.
 * Gracefully degrades to no-op when localStorage is unavailable (private
 * browsing, storage quota exceeded, etc.).
 */

export interface HttpValidators {
  readonly etag?: string;
  readonly lastModified?: string;
}

const STORAGE_PREFIX = "ct_httpcache_";

/**
 * Retrieve stored HTTP validators for a URL.
 * Returns an empty object if none are stored or storage is unavailable.
 */
export function getValidators(url: string): HttpValidators {
  try {
    const raw = localStorage.getItem(STORAGE_PREFIX + url);
    if (raw) return JSON.parse(raw) as HttpValidators;
  } catch {
    // localStorage unavailable or corrupt — degrade gracefully
  }
  return {};
}

/**
 * Persist `ETag` and/or `Last-Modified` headers from a successful response.
 * Does nothing if neither header is present.
 */
export function setValidators(url: string, response: Response): void {
  const etag = response.headers.get("ETag") ?? undefined;
  const lastModified = response.headers.get("Last-Modified") ?? undefined;
  if (!etag && !lastModified) return;
  try {
    const entry: { etag?: string; lastModified?: string } = {};
    if (etag) entry.etag = etag;
    if (lastModified) entry.lastModified = lastModified;
    localStorage.setItem(STORAGE_PREFIX + url, JSON.stringify(entry));
  } catch {
    // Quota exceeded or unavailable — ignore, next request will simply be unconditional
  }
}

/**
 * Build `If-None-Match` / `If-Modified-Since` request headers from stored
 * validators for the given URL.  Returns an empty object if no validators
 * are stored (first-time fetch or storage unavailable).
 */
export function buildConditionalHeaders(url: string): Record<string, string> {
  const { etag, lastModified } = getValidators(url);
  const headers: Record<string, string> = {};
  if (etag) headers["If-None-Match"] = etag;
  if (lastModified) headers["If-Modified-Since"] = lastModified;
  return headers;
}

/**
 * Remove stored validators for a URL (call after a cache purge or error).
 */
export function clearValidators(url: string): void {
  try {
    localStorage.removeItem(STORAGE_PREFIX + url);
  } catch {
    // ignore
  }
}
