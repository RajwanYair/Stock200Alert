/**
 * Coverage for pattern-recognition.ts (lines 289, 304, 308, 321) and
 * scale-linear.ts (line 75 — tickStep base case).
 */
import { describe, it, expect } from "vitest";
import {
  detectAllPatterns,
  isBearishEngulfing,
  isEveningStar,
  isThreeBlackCrows,
  type PatternCandle,
} from "../../../src/domain/pattern-recognition";
import { niceTicks } from "../../../src/ui/scale-linear";

describe("pattern-recognition coverage — uncovered patterns (lines 289, 304, 308, 321)", () => {
  it("detects Bearish Engulfing (line 289)", () => {
    // Previous candle: small bullish, current: large bearish engulfing it
    const candles: PatternCandle[] = [
      { open: 100, high: 103, low: 99, close: 102 }, // bullish
      { open: 104, high: 105, low: 97, close: 98 }, // bearish engulfing
    ];
    const patterns = detectAllPatterns(candles);
    const bearEng = patterns.find((p) => p.name === "Bearish Engulfing");
    expect(bearEng).toBeDefined();
    expect(bearEng!.type).toBe("bearish");
  });

  it("detects Evening Star (line 304)", () => {
    // Three candles: bullish, small-body (star), bearish closing below midpoint
    const candles: PatternCandle[] = [
      { open: 100, high: 110, low: 99, close: 109 }, // large bullish
      { open: 110, high: 111, low: 109, close: 110.5 }, // small body (star)
      { open: 109, high: 110, low: 95, close: 96 }, // bearish, close < midpoint(100+109)/2
    ];
    const patterns = detectAllPatterns(candles);
    const evening = patterns.find((p) => p.name === "Evening Star");
    expect(evening).toBeDefined();
    expect(evening!.type).toBe("bearish");
  });

  it("detects Three Black Crows (line 321)", () => {
    // Three consecutive bearish candles, each closing lower, minimal lower shadow
    const candles: PatternCandle[] = [
      { open: 110, high: 111, low: 100, close: 101 }, // bearish
      { open: 100, high: 101, low: 90, close: 91 }, // bearish, lower close
      { open: 90, high: 91, low: 80, close: 81 }, // bearish, even lower
    ];
    const patterns = detectAllPatterns(candles);
    const crows = patterns.find((p) => p.name === "Three Black Crows");
    expect(crows).toBeDefined();
    expect(crows!.type).toBe("bearish");
  });

  it("isBearishEngulfing returns confidence for valid pattern", () => {
    const prev: PatternCandle = { open: 100, high: 103, low: 99, close: 102 };
    const curr: PatternCandle = { open: 104, high: 105, low: 97, close: 98 };
    const conf = isBearishEngulfing(prev, curr);
    expect(conf).toBeGreaterThan(0);
  });

  it("isEveningStar returns confidence for valid pattern", () => {
    const first: PatternCandle = { open: 100, high: 110, low: 99, close: 109 };
    const second: PatternCandle = { open: 110, high: 111, low: 109, close: 110.5 };
    const third: PatternCandle = { open: 109, high: 110, low: 95, close: 96 };
    const conf = isEveningStar(first, second, third);
    expect(conf).toBeGreaterThan(0);
  });

  it("isThreeBlackCrows returns confidence for valid pattern", () => {
    const a: PatternCandle = { open: 110, high: 111, low: 100, close: 101 };
    const b: PatternCandle = { open: 100, high: 101, low: 90, close: 91 };
    const c: PatternCandle = { open: 90, high: 91, low: 80, close: 81 };
    const conf = isThreeBlackCrows(a, b, c);
    expect(conf).toBeGreaterThan(0);
  });
});

describe("scale-linear coverage — tickStep base case (line 75)", () => {
  it("niceTicks returns step1 when error < 1.41 (line 75)", () => {
    // Need a range where step0/step1 < 1.41
    // e.g., range [0, 100], count = 100 → step0 = 1, step1 = 1, error = 1 < 1.41
    const ticks = niceTicks(0, 100, 100);
    // step = 1 (step1 * 1), so ticks should be 0,1,2,...,100
    expect(ticks).toHaveLength(101);
    expect(ticks[0]).toBe(0);
    expect(ticks[100]).toBe(100);
  });

  it("niceTicks with small error returns fine-grained ticks", () => {
    // range [0, 10], count = 10 → step0 = 1, step1 = 1, error = 1 < 1.41
    const ticks = niceTicks(0, 10, 10);
    expect(ticks).toContain(0);
    expect(ticks).toContain(10);
    expect(ticks[1]! - ticks[0]!).toBe(1); // step = 1
  });
});
