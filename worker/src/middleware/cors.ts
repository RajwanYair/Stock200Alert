const ALLOWED_ORIGINS = [
  "https://rajwanyair.github.io",
  "http://localhost:5173",
  "http://localhost:4173",
];

function getAllowOrigin(request: Request): string {
  const origin = request.headers.get("Origin") ?? "";
  if (ALLOWED_ORIGINS.includes(origin)) return origin;
  // Allow any localhost in development
  if (origin.startsWith("http://localhost")) return origin;
  return ALLOWED_ORIGINS[0];
}

export function applyCors(response: Response, request: Request): Response {
  const allowOrigin = getAllowOrigin(request);
  const headers = new Headers(response.headers);
  headers.set("Access-Control-Allow-Origin", allowOrigin);
  headers.set("Access-Control-Allow-Methods", "GET, OPTIONS");
  headers.set("Access-Control-Allow-Headers", "Content-Type");
  headers.set("Access-Control-Max-Age", "86400");
  headers.set("Vary", "Origin");

  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers,
  });
}
