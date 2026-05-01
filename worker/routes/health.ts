/**
 * GET /api/health
 *
 * Returns the worker status, API version, and current timestamp.
 * Used by the client's `WorkerApiClient.health()` method and uptime monitors.
 */

import type { Env } from "../index.js";

export interface HealthResponse {
  status: "ok";
  version: string;
  timestamp: string;
  environment: string;
}

export function handleHealth(env: Env): Response {
  const body: HealthResponse = {
    status: "ok",
    version: env.API_VERSION ?? "1",
    timestamp: new Date().toISOString(),
    environment: env.ENVIRONMENT ?? "production",
  };
  return new Response(JSON.stringify(body), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
}
