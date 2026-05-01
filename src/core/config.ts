/**
 * Configuration management — load/save/defaults.
 */
import type { AppConfig, WatchlistEntry } from "../types/domain";
import { AppConfigSchema, safeParse } from "../types/valibot-schemas";

const STORAGE_KEY = "crosstide-config";
const CONFIG_VERSION = 1;

interface StoredConfig {
  version: number;
  config: unknown;
}

const DEFAULT_CONFIG: AppConfig = {
  theme: "dark",
  watchlist: [],
};

export function loadConfig(): AppConfig {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return DEFAULT_CONFIG;
    const parsed: unknown = JSON.parse(raw);
    if (!isStoredEnvelope(parsed) || parsed.version !== CONFIG_VERSION) {
      return DEFAULT_CONFIG;
    }
    const result = safeParse(AppConfigSchema, parsed.config);
    if (!result.success) return DEFAULT_CONFIG;
    return result.output;
  } catch {
    return DEFAULT_CONFIG;
  }
}

export function saveConfig(config: AppConfig): void {
  const stored: StoredConfig = { version: CONFIG_VERSION, config };
  localStorage.setItem(STORAGE_KEY, JSON.stringify(stored));
}

export function addTicker(config: AppConfig, ticker: string): AppConfig {
  const normalized = ticker.toUpperCase().trim();
  if (!normalized || config.watchlist.some((w) => w.ticker === normalized)) {
    return config;
  }
  const entry: WatchlistEntry = {
    ticker: normalized,
    addedAt: new Date().toISOString(),
  };
  return { ...config, watchlist: [...config.watchlist, entry] };
}

export function removeTicker(config: AppConfig, ticker: string): AppConfig {
  return {
    ...config,
    watchlist: config.watchlist.filter((w) => w.ticker !== ticker),
  };
}

/** Move a watchlist entry from one index to another (for drag-reorder). */
export function reorderWatchlist(config: AppConfig, from: number, to: number): AppConfig {
  if (from < 0 || from >= config.watchlist.length) return config;
  const next = [...config.watchlist];
  const [item] = next.splice(from, 1);
  const insertAt = Math.max(0, Math.min(to, next.length));
  next.splice(insertAt, 0, item!);
  return { ...config, watchlist: next };
}

function isStoredEnvelope(val: unknown): val is StoredConfig {
  return (
    typeof val === "object" &&
    val !== null &&
    "version" in val &&
    "config" in val &&
    typeof (val as StoredConfig).version === "number"
  );
}
