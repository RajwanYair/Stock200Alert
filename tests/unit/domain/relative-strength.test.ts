/**
 * Tests for H21 — Relative Strength Comparison domain module.
 */
import { describe, it, expect } from "vitest";
import {
  normalizeSeries,
  windowStartDate,
  computeRelativeStrengths,
  findOutperformer,
  findUnderperformer,
  summariseReturns,
} from "../../../src/domain/relative-strength";
import type { DailyCandle } from "../../../src/types/domain";

// ─── fixtures ────────────────────────────────────────────────────────────────

function makeCandles(opens: number[], dates?: string[]): DailyCandle[] {
  return opens.map((close, i) => ({
    date: dates?.[i] ?? `2026-01-${String(i + 1).padStart(2, "0")}`,
    open: close,
    high: close,
    low: close,
    close,
    volume: 1000,
  }));
}

// AAPL: 100 → 110 → 120 (base=100, total return 20%)
const AAPL = makeCandles([100, 110, 120], ["2026-01-01", "2026-01-02", "2026-01-03"]);
// MSFT: 200 → 190 → 180 (base=200, total return −10%)
const MSFT = makeCandles([200, 190, 180], ["2026-01-01", "2026-01-02", "2026-01-03"]);
// SPY: 400 → 405 → 410 (base=400, total return 2.5%) — benchmark
const SPY = makeCandles([400, 405, 410], ["2026-01-01", "2026-01-02", "2026-01-03"]);

// ─── normalizeSeries ─────────────────────────────────────────────────────────

describe("normalizeSeries", () => {
  it("first point is always 0%", () => {
    const s = normalizeSeries(AAPL, "2026-01-01", "AAPL");
    expect(s.points[0]?.pct).toBeCloseTo(0);
  });

  it("last point equals total return", () => {
    const s = normalizeSeries(AAPL, "2026-01-01", "AAPL");
    expect(s.totalReturn).toBeCloseTo(20);
    expect(s.points[s.points.length - 1]?.pct).toBeCloseTo(20);
  });

  it("negative return series works", () => {
    const s = normalizeSeries(MSFT, "2026-01-01", "MSFT");
    expect(s.totalReturn).toBeCloseTo(-10);
  });

  it("base date after first candle aligns to nearest available date", () => {
    // Base = 2026-01-02 → 190 is base; last = 180/190 − 1 ≈ −5.26 %
    const s = normalizeSeries(MSFT, "2026-01-02", "MSFT");
    expect(s.points[0]?.date).toBe("2026-01-02");
    expect(s.totalReturn).toBeCloseTo(-5.26, 1);
  });

  it("returns empty series when baseDate is after all candles", () => {
    const s = normalizeSeries(AAPL, "2030-01-01", "AAPL");
    expect(s.points).toHaveLength(0);
    expect(s.totalReturn).toBe(0);
  });

  it("sets isBenchmark correctly", () => {
    const bench = normalizeSeries(SPY, "2026-01-01", "SPY", true);
    expect(bench.isBenchmark).toBe(true);
    const notBench = normalizeSeries(AAPL, "2026-01-01", "AAPL");
    expect(notBench.isBenchmark).toBe(false);
  });

  it("handles empty candle array gracefully", () => {
    const s = normalizeSeries([], "2026-01-01", "EMPTY");
    expect(s.points).toHaveLength(0);
    expect(s.totalReturn).toBe(0);
  });
});

// ─── windowStartDate ─────────────────────────────────────────────────────────

describe("windowStartDate", () => {
  const REF = new Date("2026-05-15");

  it("1W subtracts 7 days", () => {
    expect(windowStartDate("1W", REF)).toBe("2026-05-08");
  });

  it("1M subtracts 1 month", () => {
    expect(windowStartDate("1M", REF)).toBe("2026-04-15");
  });

  it("3M subtracts 3 months", () => {
    expect(windowStartDate("3M", REF)).toBe("2026-02-15");
  });

  it("6M subtracts 6 months", () => {
    expect(windowStartDate("6M", REF)).toBe("2025-11-15");
  });

  it("1Y subtracts 1 year", () => {
    expect(windowStartDate("1Y", REF)).toBe("2025-05-15");
  });

  it("YTD returns Jan 1 of current year", () => {
    expect(windowStartDate("YTD", REF)).toBe("2026-01-01");
  });

  it("unknown window defaults to 1M", () => {
    expect(windowStartDate("CUSTOM", REF)).toBe("2026-04-15");
  });
});

// ─── computeRelativeStrengths ─────────────────────────────────────────────────

describe("computeRelativeStrengths", () => {
  const inputs = [
    { ticker: "AAPL", candles: AAPL },
    { ticker: "MSFT", candles: MSFT },
    { ticker: "SPY", candles: SPY, isBenchmark: true },
  ];

  it("returns all series", () => {
    const r = computeRelativeStrengths(inputs, "2026-01-01");
    expect(r.series).toHaveLength(3);
  });

  it("baseDate is preserved in result", () => {
    const r = computeRelativeStrengths(inputs, "2026-01-01");
    expect(r.baseDate).toBe("2026-01-01");
  });

  it("ranked excludes benchmark ticker", () => {
    const r = computeRelativeStrengths(inputs, "2026-01-01");
    expect(r.ranked).not.toContain("SPY");
  });

  it("ranked orders by total return descending", () => {
    const r = computeRelativeStrengths(inputs, "2026-01-01");
    // AAPL +20%, MSFT −10%
    expect(r.ranked[0]).toBe("AAPL");
    expect(r.ranked[1]).toBe("MSFT");
  });

  it("empty inputs returns empty result", () => {
    const r = computeRelativeStrengths([], "2026-01-01");
    expect(r.series).toHaveLength(0);
    expect(r.ranked).toHaveLength(0);
  });
});

// ─── findOutperformer / findUnderperformer ────────────────────────────────────

describe("findOutperformer / findUnderperformer", () => {
  const r = computeRelativeStrengths(
    [
      { ticker: "AAPL", candles: AAPL },
      { ticker: "MSFT", candles: MSFT },
    ],
    "2026-01-01",
  );

  it("outperformer is the best-return ticker", () => {
    expect(findOutperformer(r)).toBe("AAPL");
  });

  it("underperformer is the worst-return ticker", () => {
    expect(findUnderperformer(r)).toBe("MSFT");
  });

  it("returns null when result has no series", () => {
    const empty = computeRelativeStrengths([], "2026-01-01");
    expect(findOutperformer(empty)).toBeNull();
    expect(findUnderperformer(empty)).toBeNull();
  });
});

// ─── summariseReturns ────────────────────────────────────────────────────────

describe("summariseReturns", () => {
  it("returns a map of ticker → totalReturn", () => {
    const r = computeRelativeStrengths(
      [
        { ticker: "AAPL", candles: AAPL },
        { ticker: "SPY", candles: SPY, isBenchmark: true },
      ],
      "2026-01-01",
    );
    const summary = summariseReturns(r);
    expect(summary["AAPL"]).toBeCloseTo(20);
    expect(summary["SPY"]).toBeCloseTo(2.5);
  });

  it("empty result returns empty map", () => {
    const r = computeRelativeStrengths([], "2026-01-01");
    expect(summariseReturns(r)).toEqual({});
  });
});
