import { describe, it, expect } from "vitest";
import { computeAroon } from "../../../src/domain/aroon";
import type { Candle } from "../../../src/domain/heikin-ashi";

const c = (i: number, h: number, l: number): Candle => ({
  time: i,
  open: (h + l) / 2,
  high: h,
  low: l,
  close: (h + l) / 2,
});

describe("aroon", () => {
  it("returns [] for too-few candles", () => {
    expect(computeAroon([], 14)).toEqual([]);
    expect(computeAroon([c(0, 1, 0), c(1, 2, 1)], 5)).toEqual([]);
  });

  it("strict uptrend -> Up=100, Down close to 0", () => {
    const data = Array.from({ length: 20 }, (_, i) => c(i, 10 + i, 9 + i));
    const out = computeAroon(data, 5);
    const last = out[out.length - 1]!;
    expect(last.up).toBe(100);
    expect(last.down).toBeLessThanOrEqual(20);
  });

  it("strict downtrend -> Down=100", () => {
    const data = Array.from({ length: 20 }, (_, i) => c(i, 100 - i, 99 - i));
    const out = computeAroon(data, 5);
    const last = out[out.length - 1]!;
    expect(last.down).toBe(100);
  });

  it("oscillator = up - down", () => {
    const data = Array.from({ length: 12 }, (_, i) => c(i, 10 + i, 9 + i));
    for (const p of computeAroon(data, 5)) {
      expect(p.oscillator).toBeCloseTo(p.up - p.down, 6);
    }
  });

  it("values are bounded [0, 100]", () => {
    const data = Array.from({ length: 30 }, (_, i) =>
      c(i, 10 + Math.sin(i) * 5, 5 + Math.cos(i) * 3),
    );
    for (const p of computeAroon(data, 7)) {
      expect(p.up).toBeGreaterThanOrEqual(0);
      expect(p.up).toBeLessThanOrEqual(100);
      expect(p.down).toBeGreaterThanOrEqual(0);
      expect(p.down).toBeLessThanOrEqual(100);
    }
  });

  it("respects period length", () => {
    const data = Array.from({ length: 20 }, (_, i) => c(i, 10 + i, 9 + i));
    expect(computeAroon(data, 5).length).toBe(15);
  });
});
