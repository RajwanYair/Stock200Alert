import { describe, it, expect } from "vitest";
import { computeDonchian } from "../../../src/domain/donchian";
import type { Candle } from "../../../src/domain/heikin-ashi";

const c = (h: number, l: number, t = 0): Candle => ({
  time: t,
  open: l,
  high: h,
  low: l,
  close: h,
});

describe("donchian", () => {
  it("rejects non-positive period", () => {
    expect(() => computeDonchian([], 0)).toThrow(RangeError);
    expect(() => computeDonchian([], -1)).toThrow(RangeError);
  });

  it("returns empty when fewer candles than period", () => {
    expect(computeDonchian([c(10, 5)], 5)).toEqual([]);
  });

  it("computes upper as max high in window", () => {
    const r = computeDonchian([c(10, 5, 1), c(12, 6, 2), c(11, 7, 3)], 3);
    expect(r).toHaveLength(1);
    expect(r[0]!.upper).toBe(12);
  });

  it("computes lower as min low in window", () => {
    const r = computeDonchian([c(10, 5, 1), c(12, 4, 2), c(11, 7, 3)], 3);
    expect(r[0]!.lower).toBe(4);
  });

  it("middle is the midpoint", () => {
    const r = computeDonchian([c(10, 5, 1), c(12, 4, 2), c(11, 7, 3)], 3);
    expect(r[0]!.middle).toBe(8);
  });

  it("emits one point per candle once warm", () => {
    const candles = Array.from({ length: 10 }, (_, i) => c(10 + i, i, i));
    const r = computeDonchian(candles, 5);
    expect(r).toHaveLength(6);
  });

  it("upper >= lower always", () => {
    const candles = Array.from({ length: 8 }, (_, i) => c(10 + i, 1 + i, i));
    for (const p of computeDonchian(candles, 3)) {
      expect(p.upper).toBeGreaterThanOrEqual(p.lower);
    }
  });
});
