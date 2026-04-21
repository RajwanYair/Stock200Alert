/**
 * Provider chain — tries providers in order, falls back on failure.
 */
import type { DailyCandle } from "../types/domain";
import type { MarketDataProvider, Quote, SearchResult, ProviderHealth } from "./types";

export function createProviderChain(providers: readonly MarketDataProvider[]): MarketDataProvider {
  if (providers.length === 0) throw new Error("Provider chain requires at least one provider");

  async function tryAll<T>(op: (p: MarketDataProvider) => Promise<T>): Promise<T> {
    let lastError: Error | null = null;
    for (const provider of providers) {
      if (!provider.health().available) continue;
      try {
        return await op(provider);
      } catch (err) {
        lastError = err instanceof Error ? err : new Error(String(err));
      }
    }
    // If all healthy providers failed, retry unavailable ones as last resort
    for (const provider of providers) {
      if (provider.health().available) continue;
      try {
        return await op(provider);
      } catch (err) {
        lastError = err instanceof Error ? err : new Error(String(err));
      }
    }
    throw lastError ?? new Error("All providers failed");
  }

  return {
    name: "chain",

    getQuote(ticker: string): Promise<Quote> {
      return tryAll((p) => p.getQuote(ticker));
    },

    getHistory(ticker: string, days: number): Promise<readonly DailyCandle[]> {
      return tryAll((p) => p.getHistory(ticker, days));
    },

    search(query: string): Promise<readonly SearchResult[]> {
      return tryAll((p) => p.search(query));
    },

    health(): ProviderHealth {
      const anyAvailable = providers.some((p) => p.health().available);
      return {
        name: "chain",
        available: anyAvailable,
        lastSuccessAt: null,
        lastErrorAt: null,
        consecutiveErrors: anyAvailable ? 0 : providers.length,
      };
    },
  };
}
