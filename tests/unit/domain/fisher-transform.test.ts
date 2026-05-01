import { describe, it, expect } from "vitest";
import { computeFisherTransform } from "../../../src/domain/fisher-transform";
import type { Candle } from "../../../src/domain/heikin-ashi";

const c = (i: number, hi: number, lo: number): Candle => ({
  time: i,
  open: (hi + lo) / 2,
  high: hi,
  low: lo,
  close: (hi + lo) / 2,
});

describe("fisher-transform", () => {
  it("rejects bad period / too short", () => {
    expect(computeFisherTransform([], 9)).toEqual([]);
    expect(computeFisherTransform([c(0, 1, 0)], 9)).toEqual([]);
    expect(computeFisherTransform([c(0, 1, 0), c(1, 2, 1)], 0)).toEqual([]);
  });

  it("uptrend -> positive fisher at end", () => {
    const data = Array.from({ length: 50 }, (_, i) => c(i, 100 + i + 1, 100 + i - 1));
    const out = computeFisherTransform(data, 9);
    expect(out[out.length - 1]!.fisher).toBeGreaterThan(0);
  });

  it("downtrend -> negative fisher at end", () => {
    const data = Array.from({ length: 50 }, (_, i) => c(i, 200 - i + 1, 200 - i - 1));
    const out = computeFisherTransform(data, 9);
    expect(out[out.length - 1]!.fisher).toBeLessThan(0);
  });

  it("flat range -> fisher decays toward 0", () => {
    const data = Array.from({ length: 50 }, (_, i) => c(i, 101, 99));
    const out = computeFisherTransform(data, 9);
    expect(Math.abs(out[out.length - 1]!.fisher)).toBeLessThan(1e-6);
  });

  it("trigger lags fisher by one bar", () => {
    const data = Array.from({ length: 30 }, (_, i) => c(i, 100 + i, 99 + i));
    const out = computeFisherTransform(data, 9);
    for (let i = 1; i < out.length; i++) {
      expect(out[i]!.trigger).toBeCloseTo(out[i - 1]!.fisher, 9);
    }
  });

  it("output length = candles - period + 1", () => {
    const data = Array.from({ length: 30 }, (_, i) => c(i, i + 1, i));
    expect(computeFisherTransform(data, 9).length).toBe(22);
  });
});
