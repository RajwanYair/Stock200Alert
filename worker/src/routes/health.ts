import type { Env } from "../index";

const START_TIME = Date.now();

export async function handleHealth(env: Env): Promise<Response> {
  const uptime = Math.floor((Date.now() - START_TIME) / 1000);
  const providers: Record<string, string> = {
    yahoo: "available",
    coingecko: "available",
    "twelve-data": env.TWELVE_DATA_API_KEY ? "configured" : "not-configured",
    polygon: env.POLYGON_API_KEY ? "configured" : "not-configured",
  };

  const body = {
    status: "ok",
    uptime,
    version: "1.0.0",
    providers,
    timestamp: new Date().toISOString(),
  };

  return new Response(JSON.stringify(body), {
    status: 200,
    headers: {
      "Content-Type": "application/json",
      "Cache-Control": "no-store",
    },
  });
}
