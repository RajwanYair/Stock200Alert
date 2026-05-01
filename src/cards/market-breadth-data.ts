/**
 * Market Breadth data bridge — shared state between main.ts and market-breadth-card.ts.
 *
 * G23: Mirrors the screener-data.ts pattern to avoid static card chunk imports.
 */
import type { SignalDirection } from "../types/domain";

export interface BreadthEntry {
  readonly ticker: string;
  readonly price: number;
  readonly changePercent: number;
  readonly consensus: SignalDirection;
  /** Latest close above 50-day SMA? null if insufficient data. */
  readonly aboveSma50: boolean | null;
  /** Latest close above 200-day SMA? null if insufficient data. */
  readonly aboveSma200: boolean | null;
}

let liveEntries: readonly BreadthEntry[] = [];

/** Called by main.ts after every data refresh cycle. */
export function setBreadthData(entries: readonly BreadthEntry[]): void {
  liveEntries = entries;
}

/** Called by market-breadth-card at render time. */
export function getBreadthData(): readonly BreadthEntry[] {
  return liveEntries;
}
