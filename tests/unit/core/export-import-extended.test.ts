/**
 * Extended export-import tests — CSV, JSON, error paths.
 */
import { describe, it, expect } from "vitest";
import {
  exportConfigJSON,
  importConfigJSON,
  exportWatchlistCSV,
  importWatchlistCSV,
} from "../../../src/core/export-import";
import type { AppConfig } from "../../../src/types/domain";

describe("export-import extended", () => {
  const config: AppConfig = {
    theme: "dark",
    watchlist: [
      { ticker: "AAPL", addedAt: "2025-01-01T00:00:00.000Z" },
      { ticker: "GOOG", addedAt: "2025-01-02T00:00:00.000Z" },
    ],
  };

  describe("JSON roundtrip", () => {
    it("exportConfigJSON produces valid JSON", () => {
      const json = exportConfigJSON(config, "6.0.0");
      const parsed = JSON.parse(json);
      expect(parsed.version).toBe("6.0.0");
      expect(parsed.config.theme).toBe("dark");
    });

    it("importConfigJSON roundtrips with exportConfigJSON", () => {
      const json = exportConfigJSON(config, "6.0.0");
      const imported = importConfigJSON(json);
      expect(imported.theme).toBe("dark");
      expect(imported.watchlist).toHaveLength(2);
      expect(imported.watchlist[0]?.ticker).toBe("AAPL");
    });

    it("importConfigJSON rejects missing config", () => {
      expect(() => importConfigJSON(JSON.stringify({ version: "1" }))).toThrow("Missing config");
    });

    it("importConfigJSON rejects invalid theme", () => {
      expect(() =>
        importConfigJSON(JSON.stringify({ config: { theme: "neon", watchlist: [] } })),
      ).toThrow("Invalid theme");
    });

    it("importConfigJSON rejects non-array watchlist", () => {
      expect(() =>
        importConfigJSON(JSON.stringify({ config: { theme: "dark", watchlist: "not-array" } })),
      ).toThrow("Invalid watchlist");
    });

    it("importConfigJSON rejects invalid JSON", () => {
      expect(() => importConfigJSON("{broken")).toThrow();
    });
  });

  describe("CSV roundtrip", () => {
    it("exportWatchlistCSV produces header + rows", () => {
      const csv = exportWatchlistCSV(config.watchlist);
      const lines = csv.split("\n");
      expect(lines[0]).toBe("ticker,addedAt");
      expect(lines).toHaveLength(3);
    });

    it("importWatchlistCSV parses CSV back to entries", () => {
      const csv = exportWatchlistCSV(config.watchlist);
      const entries = importWatchlistCSV(csv);
      expect(entries).toHaveLength(2);
      expect(entries[0]?.ticker).toBe("AAPL");
    });

    it("importWatchlistCSV normalizes ticker to uppercase", () => {
      const csv = "ticker,addedAt\naapl,2025-01-01";
      const entries = importWatchlistCSV(csv);
      expect(entries[0]?.ticker).toBe("AAPL");
    });

    it("importWatchlistCSV returns empty for header-only CSV", () => {
      expect(importWatchlistCSV("ticker,addedAt")).toEqual([]);
    });

    it("exportWatchlistCSV handles empty watchlist", () => {
      const csv = exportWatchlistCSV([]);
      expect(csv).toBe("ticker,addedAt");
    });
  });
});
