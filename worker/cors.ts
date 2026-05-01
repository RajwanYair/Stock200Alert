/**
 * CORS helper — adds the standard CrossTide CORS headers to a response.
 *
 * Allowed origins:
 *  - localhost (any port) for development
 *  - crosstide.pages.dev (production)
 *  - Any subdomain of crosstide.pages.dev (preview deployments)
 *
 * Credentials are NOT allowed so the wildcard fallback is safe.
 */

const ALLOWED_ORIGINS = new Set([
  "http://localhost:5173",
  "http://localhost:4173",
  "https://crosstide.pages.dev",
]);

function isAllowedOrigin(origin: string): boolean {
  if (ALLOWED_ORIGINS.has(origin)) return true;
  // Allow Cloudflare Pages preview deployments: *.crosstide.pages.dev
  try {
    const url = new URL(origin);
    return url.hostname.endsWith(".crosstide.pages.dev");
  } catch {
    return false;
  }
}

/** Returns the value for the Access-Control-Allow-Origin header. */
export function getAllowedOrigin(requestOrigin: string | null): string {
  if (requestOrigin && isAllowedOrigin(requestOrigin)) return requestOrigin;
  return "https://crosstide.pages.dev";
}

/** Standard CORS headers for JSON API responses. */
export function corsHeaders(requestOrigin: string | null): HeadersInit {
  return {
    "Access-Control-Allow-Origin": getAllowedOrigin(requestOrigin),
    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, X-Request-ID",
    "Access-Control-Max-Age": "86400",
    Vary: "Origin",
  };
}

/** Respond to a CORS preflight request. */
export function handlePreflight(request: Request): Response {
  const origin = request.headers.get("Origin");
  return new Response(null, {
    status: 204,
    headers: corsHeaders(origin),
  });
}

/** Wrap any Response with CORS headers. */
export function withCors(response: Response, requestOrigin: string | null): Response {
  const headers = new Headers(response.headers);
  for (const [k, v] of Object.entries(corsHeaders(requestOrigin))) {
    headers.set(k, v);
  }
  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers,
  });
}
