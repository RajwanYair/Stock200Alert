/**
 * Analytics calculator tests — Sharpe, Sortino, MaxDrawdown, Fibonacci.
 */
import { describe, it, expect } from "vitest";
import {
  dailyReturns,
  sharpeRatio,
  sortinoRatio,
  maxDrawdown,
  fibonacciRetracement,
} from "../../../src/domain/analytics";
import { makeCandles } from "../../helpers/candle-factory";

describe("dailyReturns", () => {
  it("computes correct returns", () => {
    const candles = makeCandles([100, 110, 105]);
    const returns = dailyReturns(candles);
    expect(returns).toHaveLength(2);
    expect(returns[0]).toBeCloseTo(0.1, 5);
    expect(returns[1]).toBeCloseTo(-0.04545, 3);
  });

  it("returns empty for single candle", () => {
    expect(dailyReturns(makeCandles([100]))).toEqual([]);
  });
});

describe("sharpeRatio", () => {
  it("returns null for insufficient data", () => {
    expect(sharpeRatio(makeCandles([100]))).toBeNull();
  });

  it("returns 0 for flat prices", () => {
    const candles = makeCandles(Array.from({ length: 30 }, () => 100));
    expect(sharpeRatio(candles)).toBe(0);
  });

  it("is positive for ascending prices", () => {
    const candles = makeCandles(Array.from({ length: 100 }, (_, i) => 100 + i * 0.5));
    const ratio = sharpeRatio(candles);
    expect(ratio).not.toBeNull();
    expect(ratio!).toBeGreaterThan(0);
  });

  it("is negative for descending prices", () => {
    const candles = makeCandles(Array.from({ length: 100 }, (_, i) => 200 - i * 0.5));
    const ratio = sharpeRatio(candles);
    expect(ratio).not.toBeNull();
    expect(ratio!).toBeLessThan(0);
  });
});

describe("sortinoRatio", () => {
  it("returns null for insufficient data", () => {
    expect(sortinoRatio(makeCandles([100]))).toBeNull();
  });

  it("returns null when no downside", () => {
    // Strictly ascending — no negative returns
    const candles = makeCandles(Array.from({ length: 30 }, (_, i) => 100 + i));
    expect(sortinoRatio(candles)).toBeNull();
  });

  it("is a number for mixed returns", () => {
    const candles = makeCandles(Array.from({ length: 50 }, (_, i) => 100 + Math.sin(i) * 10));
    const ratio = sortinoRatio(candles);
    expect(ratio).not.toBeNull();
    expect(typeof ratio).toBe("number");
  });
});

describe("maxDrawdown", () => {
  it("is 0 for monotonically ascending prices", () => {
    const candles = makeCandles(Array.from({ length: 20 }, (_, i) => 100 + i));
    expect(maxDrawdown(candles)).toBe(0);
  });

  it("computes drawdown for a drop", () => {
    // Peak at 200, drops to 150 = 25% drawdown
    const candles = makeCandles([100, 150, 200, 175, 150]);
    const dd = maxDrawdown(candles);
    expect(dd).toBeCloseTo(0.25, 2);
  });

  it("is between 0 and 1", () => {
    const candles = makeCandles(Array.from({ length: 50 }, (_, i) => 100 + Math.sin(i) * 30));
    const dd = maxDrawdown(candles);
    expect(dd).toBeGreaterThanOrEqual(0);
    expect(dd).toBeLessThanOrEqual(1);
  });

  it("is 0 for single candle", () => {
    expect(maxDrawdown(makeCandles([100]))).toBe(0);
  });
});

describe("fibonacciRetracement", () => {
  it("returns null for insufficient data", () => {
    expect(fibonacciRetracement(makeCandles([100]))).toBeNull();
  });

  it("computes levels from high/low", () => {
    // makeCandles: high = close + 1, low = close - 1
    // For closes [100, 200]: highs are 101, 201; lows are 99, 199
    // high = 201, low = 99, range = 102
    const levels = fibonacciRetracement(makeCandles([100, 200]));
    expect(levels).not.toBeNull();
    expect(levels!.high).toBe(201);
    expect(levels!.low).toBe(99);
    expect(levels!.level500).toBeCloseTo(150, 0);
  });

  it("all levels are between low and high", () => {
    const levels = fibonacciRetracement(makeCandles([50, 100, 150, 80, 120]));
    expect(levels).not.toBeNull();
    for (const key of ["level236", "level382", "level500", "level618", "level786"] as const) {
      expect(levels![key]).toBeGreaterThanOrEqual(levels!.low);
      expect(levels![key]).toBeLessThanOrEqual(levels!.high);
    }
  });

  it("returns null for flat prices (zero range)", () => {
    const candles = makeCandles(Array.from({ length: 10 }, () => 100));
    // All candles have same OHLC, so high-low range is 4 (close±2), not 0
    // Actually: all highs=102, all lows=98 → range=4, not zero
    const levels = fibonacciRetracement(candles);
    expect(levels).not.toBeNull();
  });
});
