/**
 * Shared test helper — builds DailyCandle arrays from close prices.
 */
import type { DailyCandle } from "../../src/types/domain";

/**
 * Create an array of DailyCandle objects from an array of close prices.
 * Open defaults to close, high to close+1, low to close-1, volume to 1000.
 */
export function makeCandles(closes: number[]): DailyCandle[] {
  return closes.map((close, i) => ({
    date: `2024-01-${String(i + 1).padStart(2, "0")}`,
    open: close,
    high: close + 1,
    low: close - 1,
    close,
    volume: 1000,
  }));
}
